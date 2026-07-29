import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/utils/number_parsing_utils.dart';
import '../../../../core/utils/seven_segment_cnn.dart';
import '../../../../core/utils/seven_segment_decoder.dart';

/// Result of running OCR over a meter photo.
class OcrScanResult {
  const OcrScanResult({
    required this.rawText,
    required this.value,
    required this.confidence,
    this.alternativeValues = const [],
  });

  /// All text ML Kit recognised (kept for debugging poor scans).
  final String rawText;

  /// Best numeric candidate, or null if none was found.
  final double? value;

  /// Synthesized confidence 0–1.
  final double confidence;

  /// Alternative candidate values detected on the meter display.
  final List<double> alternativeValues;
}

/// Reads a meter value from an image, fully offline.
///
/// Runs three recognisers in descending order of demonstrated accuracy on
/// seven-segment displays: the learned per-digit CNN, then the geometric decoder,
/// then ML Kit's general text recognition as a last resort. See [scanReading].
class OcrDatasource {
  OcrDatasource({TextRecognizer? recognizer, SevenSegmentCnn? cnn})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin),
        // Nullable so tests and non-Flutter contexts can opt out: loading the
        // model needs the asset bundle, which a plain unit test has no access to.
        _cnn = cnn ?? SevenSegmentCnn();

  final TextRecognizer _recognizer;
  final SevenSegmentCnn? _cnn;

  /// Runs recognition on the image at [imagePath] and returns the parsed
  /// candidate. Optional meter context (unit, meterNumber, previousReadingValue)
  /// sharpens the detection accuracy.
  Future<OcrScanResult> scanReading(
    String imagePath, {
    int? expectedDigits,
    String? unit,
    String? meterNumber,
    double? previousReadingValue,
  }) async {
    // Three recognisers, tried in descending order of demonstrated accuracy on
    // seven-segment LCDs. Every meter this app targets uses one, and general text
    // recognition is structurally weak on them — ML Kit read 228235 from a display
    // showing 02282385, which is the known limit of that model class rather than a
    // bug. So the specialised readers go first and ML Kit becomes the last resort.
    //
    // 1. Learned per-digit CNN: trained on degraded seven-segment images, so it
    //    tolerates the glare and skew that shift a bar out of a fixed sampling
    //    window.
    final cnnResult = await _tryCnn(
      imagePath,
      previousReadingValue: previousReadingValue,
      expectedDigits: expectedDigits,
    );
    if (cnnResult != null) return cnnResult;

    // 2. Geometric decoder: no model needed and exact on clean panels, but it
    //    samples fixed windows and so is the more brittle of the two.
    final segmentResult = await _trySevenSegment(
      imagePath,
      previousReadingValue: previousReadingValue,
      expectedDigits: expectedDigits,
    );
    if (segmentResult != null) return segmentResult;

    final input = InputImage.fromFilePath(imagePath);
    final recognised = await _recognizer.processImage(input);

    final lines = <OcrLineContext>[];
    for (final block in recognised.blocks) {
      for (final line in block.lines) {
        lines.add(OcrLineContext(
          lineText: line.text,
          blockText: block.text,
        ));
      }
    }

    final parsed = lines.isNotEmpty
        ? extractMeterReadingFromLines(
            lines,
            expectedDigits: expectedDigits,
            unit: unit,
            meterNumber: meterNumber,
            previousReadingValue: previousReadingValue,
          )
        : extractLongestNumericSequence(
            recognised.text,
            expectedDigits: expectedDigits,
            unit: unit,
            meterNumber: meterNumber,
            previousReadingValue: previousReadingValue,
          );

    return OcrScanResult(
      rawText: recognised.text,
      value: parsed.value,
      confidence: parsed.confidence,
      alternativeValues: parsed.alternativeValues,
    );
  }

  /// Runs the learned classifier, returning a result only when it earns priority.
  ///
  /// Acceptance mirrors the geometric decoder's: a confident read wins outright,
  /// and a middling one wins only if it agrees with the meter's history. The
  /// threshold applies to the *weakest* digit, since one shaky cell invalidates
  /// the whole number.
  Future<OcrScanResult?> _tryCnn(
    String imagePath, {
    double? previousReadingValue,
    int? expectedDigits,
  }) async {
    final cnn = _cnn;
    if (cnn == null || cnn.isUnavailable) return null;
    try {
      final bytes = await File(imagePath).readAsBytes();
      final result = await cnn.readDisplay(bytes);
      if (result?.value == null) return null;

      final value = result!.value!;
      final digitsMatch =
          expectedDigits == null || result.digits.length == expectedDigits;
      final movedForwardPlausibly = previousReadingValue == null ||
          (value >= previousReadingValue &&
              value - previousReadingValue <= 5000);

      final trustworthy = result.confidence >= 0.90 ||
          (result.confidence >= 0.60 && movedForwardPlausibly && digitsMatch);
      if (!trustworthy) return null;

      return OcrScanResult(
        rawText: 'cnn: ${result.digits} '
            '(min conf ${result.confidence.toStringAsFixed(2)})',
        value: value,
        confidence: result.confidence,
      );
    } catch (e) {
      debugPrint('OcrDatasource: CNN path failed, deferring: $e');
      return null;
    }
  }

  /// Decodes on a background isolate.
  ///
  /// `static` for the same reason as the camera page's crop helper: an
  /// `Isolate.run` closure inside an instance method shares that method's context
  /// and can transitively capture `this`, which is unsendable and makes the
  /// isolate call fail at runtime. A static method has no `this` to capture.
  static Future<SevenSegmentResult?> _decodeOffThread(Uint8List bytes) =>
      Isolate.run(() => decodeSevenSegment(bytes));

  /// Runs the seven-segment decoder, returning a result only when it is worth
  /// preferring over general OCR.
  ///
  /// A confident decode is accepted outright. A middling one is accepted only if
  /// it agrees with the meter's history — a reading containing a `1` scores lower
  /// by construction, so a plausible value with modest confidence is still a
  /// better bet than ML Kit guessing at segment glyphs. Anything else defers.
  Future<OcrScanResult?> _trySevenSegment(
    String imagePath, {
    double? previousReadingValue,
    int? expectedDigits,
  }) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      // Decoding and scanning is CPU-bound; keep it off the UI isolate.
      final decoded = await _decodeOffThread(bytes);
      if (decoded?.value == null) return null;

      final value = decoded!.value!;
      final digitsMatch =
          expectedDigits == null || decoded.digits.length == expectedDigits;
      final movedForwardPlausibly = previousReadingValue == null ||
          (value >= previousReadingValue &&
              value - previousReadingValue <= 5000);

      final trustworthy = decoded.confidence >= 0.6 ||
          (movedForwardPlausibly && digitsMatch);
      if (!trustworthy) return null;

      return OcrScanResult(
        rawText: 'seven-segment: ${decoded.digits}',
        value: value,
        confidence: decoded.confidence,
      );
    } catch (_) {
      // Any failure just defers to ML Kit rather than failing the scan.
      return null;
    }
  }

  /// Releases native resources. Call when the recognizer is no longer needed.
  Future<void> dispose() async {
    _cnn?.dispose();
    await _recognizer.close();
  }
}

