import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/utils/number_parsing_utils.dart';

/// Result of running OCR over a meter photo.
class OcrScanResult {
  const OcrScanResult({
    required this.rawText,
    required this.value,
    required this.confidence,
  });

  /// All text ML Kit recognised (kept for debugging poor scans).
  final String rawText;

  /// Best numeric candidate, or null if none was found.
  final double? value;

  /// Synthesized confidence 0–1 (see [extractLongestNumericSequence]).
  final double confidence;
}

/// Wraps ML Kit's on-device [TextRecognizer] and extracts the most
/// reading-like number from a captured image. Fully offline.
class OcrDatasource {
  OcrDatasource({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  /// Runs recognition on the image at [imagePath] and returns the parsed
  /// candidate. [expectedDigits] (from the meter, if known) sharpens the
  /// confidence estimate.
  Future<OcrScanResult> scanReading(
    String imagePath, {
    int? expectedDigits,
  }) async {
    final input = InputImage.fromFilePath(imagePath);
    final recognised = await _recognizer.processImage(input);
    final parsed = extractLongestNumericSequence(
      recognised.text,
      expectedDigits: expectedDigits,
    );
    return OcrScanResult(
      rawText: recognised.text,
      value: parsed.value,
      confidence: parsed.confidence,
    );
  }

  /// Releases native resources. Call when the recognizer is no longer needed.
  Future<void> dispose() => _recognizer.close();
}
