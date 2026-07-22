/// Pure helpers for turning raw OCR text into a candidate meter reading.
///
/// Kept free of any Flutter or ML Kit imports so it can be unit-tested with
/// plain strings. The "confidence" produced here is a *synthesized heuristic*,
/// not a value reported by ML Kit — the on-device recognizer does not expose a
/// per-number confidence, so we approximate one from digit-run length, the
/// number of competing candidates, and (optionally) the meter's expected digit
/// count.
library;

/// Outcome of scanning OCR text for the most reading-like number.
class OcrNumberResult {
  const OcrNumberResult({
    required this.value,
    required this.confidence,
    this.rawMatch,
    this.candidateCount = 0,
  });

  /// No number could be found in the text.
  const OcrNumberResult.none()
      : value = null,
        confidence = 0,
        rawMatch = null,
        candidateCount = 0;

  /// Parsed numeric value, or `null` when no candidate was found.
  final double? value;

  /// Heuristic confidence in the range 0.0–1.0 (see library docs).
  final double confidence;

  /// The raw substring that produced [value] (before comma normalisation).
  final String? rawMatch;

  /// How many numeric candidates were seen in the text.
  final int candidateCount;

  bool get hasValue => value != null;

  /// Confidence expressed as a whole percentage for display.
  int get confidencePercent => (confidence * 100).round();
}

/// Matches an integer or decimal number, allowing `.` or `,` as the separator.
final RegExp _numberPattern = RegExp(r'\d+(?:[.,]\d+)?');

/// Number of significant digits in [raw], ignoring any decimal separator.
int _digitCount(String raw) => raw.replaceAll(RegExp(r'[.,]'), '').length;

/// Extracts the most reading-like number from [text].
///
/// Prefers the longest run of digits (a meter reading is usually the longest
/// number on the dial), normalises a decimal comma to a dot, and attaches a
/// synthesized [OcrNumberResult.confidence]. When [expectedDigits] is provided
/// (from the meter's configuration) it sharpens the confidence toward matches
/// of that length.
OcrNumberResult extractLongestNumericSequence(
  String text, {
  int? expectedDigits,
}) {
  final matches = _numberPattern.allMatches(text).map((m) => m.group(0)!).toList();
  if (matches.isEmpty) return const OcrNumberResult.none();

  // Longest digit run wins; ties resolve to the first occurrence.
  var best = matches.first;
  for (final candidate in matches.skip(1)) {
    if (_digitCount(candidate) > _digitCount(best)) best = candidate;
  }

  final normalised = best.replaceAll(',', '.');
  final value = double.tryParse(normalised);
  if (value == null) return const OcrNumberResult.none();

  return OcrNumberResult(
    value: value,
    rawMatch: best,
    candidateCount: matches.length,
    confidence: _confidenceFor(
      digits: _digitCount(best),
      candidateCount: matches.length,
      expectedDigits: expectedDigits,
    ),
  );
}

/// Blends the heuristic signals into a single 0.05–0.99 confidence.
double _confidenceFor({
  required int digits,
  required int candidateCount,
  int? expectedDigits,
}) {
  var score = 0.5;

  // Agreement with the meter's known digit count is the strongest signal.
  if (expectedDigits != null) {
    final diff = (digits - expectedDigits).abs();
    score += switch (diff) {
      0 => 0.3,
      1 => 0.15,
      _ => -0.2,
    };
  }

  // Fewer competing numbers on the dial means less ambiguity.
  score += switch (candidateCount) {
    1 => 0.2,
    2 => 0.05,
    _ => -0.1,
  };

  // Long digit runs look like real meter readings.
  if (digits >= 4) score += 0.1;

  return score.clamp(0.05, 0.99);
}
