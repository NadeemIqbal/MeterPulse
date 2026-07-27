import 'dart:io';
import 'dart:isolate';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/utils/number_parsing_utils.dart';
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

/// Wraps ML Kit's on-device [TextRecognizer] and extracts the most
/// reading-like number from a captured image. Fully offline.
class OcrDatasource {
  OcrDatasource({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

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
    // Seven-segment decoder first. Every meter this app targets uses a
    // seven-segment LCD, and general text recognition is unreliable on them —
    // measured on a real display it read 228235 from 02282385. The decoder reads
    // segment geometry rather than glyph shapes, so when it is confident it is
    // strictly better; when it declines, ML Kit still gets its turn below.
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
      final decoded = await Isolate.run(() => decodeSevenSegment(bytes));
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
  Future<void> dispose() => _recognizer.close();
}

