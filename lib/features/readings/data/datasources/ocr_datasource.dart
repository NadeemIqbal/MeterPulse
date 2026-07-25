import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/utils/number_parsing_utils.dart';

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

  /// Releases native resources. Call when the recognizer is no longer needed.
  Future<void> dispose() => _recognizer.close();
}

