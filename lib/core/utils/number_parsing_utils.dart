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
    this.alternativeValues = const [],
  });

  /// No number could be found in the text.
  const OcrNumberResult.none()
      : value = null,
        confidence = 0,
        rawMatch = null,
        candidateCount = 0,
        alternativeValues = const [];

  /// Parsed numeric value, or `null` when no candidate was found.
  final double? value;

  /// Heuristic confidence in the range 0.0–1.0 (see library docs).
  final double confidence;

  /// The raw substring that produced [value] (before comma normalisation).
  final String? rawMatch;

  /// How many numeric candidates were seen in the text.
  final int candidateCount;

  /// Alternative detected values found on the meter dial, sorted by rank.
  final List<double> alternativeValues;

  bool get hasValue => value != null;

  /// Confidence expressed as a whole percentage for display.
  int get confidencePercent => (confidence * 100).round();
}

/// Structured line context extracted from OCR text blocks.
class OcrLineContext {
  const OcrLineContext({
    required this.lineText,
    this.blockText,
  });

  final String lineText;
  final String? blockText;
}

/// Matches an integer or decimal number, allowing `.` or `,` as the separator.
final RegExp _numberPattern = RegExp(r'\d+(?:[.,]\d+)?');

/// Number of significant digits in [raw], ignoring any decimal separator.
int _digitCount(String raw) => raw.replaceAll(RegExp(r'[.,]'), '').length;

/// Disqualifying keywords that indicate a line is a serial number, specs, or date.
const List<String> _disqualifyingKeywords = [
  'SN',
  'S/N',
  'SERIAL',
  'NO.',
  'NO:',
  'MODEL',
  'TYPE',
  'VOLTS',
  '230V',
  '110V',
  '50HZ',
  '60HZ',
  'IMP/KWH',
  'IMP/KW',
  'IMPKWH',
  'IMP',
  '5(60)A',
  '10(40)A',
  '240V',
  '220V',
  // Recognition mangles the nameplate ("Reverse Poww Tote", "3200impkWh"), so
  // these are matched on real observed output rather than the ideal print.
  'IEC',
  'IEC 62053',
  '62053',
  'HXE',
  'PVT',
  'LIMITED',
  'ELECTRONICS',
  'PAKISTAN',
  'REVERSE',
  'NEUTRAL',
  'EARTH',
  'PHASE',
  'WIRE',
  'STATIC',
  'CLASS',
  'MADE IN',
  'DATE',
  'YEAR',
  'BARCODE',
  'TEL',
  'IP54',
  'IEC',
  'APPROVED',
  'MANUFACTURER',
];

/// Keywords that strongly suggest a meter reading / display dial line.
const List<String> _readingKeywords = [
  'KWH',
  'KW.H',
  'M3',
  'M³',
  'GAL',
  'LITER',
  'TOTAL',
  'POS',
  '1.8.0',
  'READING',
  'INDEX',
  'VALUE',
  'USAGE',
  'CONSUMPTION',
  'KVARH',
];

/// Candidate score container for ranking OCR matches.
class _ScoredCandidate {
  _ScoredCandidate({
    required this.rawMatch,
    required this.value,
    required this.score,
  });

  final String rawMatch;
  final double value;
  final double score;
}

/// Extracts the most meter-reading-like number using structured OCR lines and
/// meter context (unit, meter serial number, previous reading value).
OcrNumberResult extractMeterReadingFromLines(
  List<OcrLineContext> lines, {
  String? unit,
  String? meterNumber,
  double? previousReadingValue,
  int? expectedDigits,
}) {
  if (lines.isEmpty) return const OcrNumberResult.none();

  final candidates = <_ScoredCandidate>[];

  for (final lineCtx in lines) {
    final lineUpper = lineCtx.lineText.toUpperCase();
    final blockUpper = lineCtx.blockText?.toUpperCase() ?? '';

    final matches = _numberPattern.allMatches(lineCtx.lineText);
    for (final match in matches) {
      final raw = match.group(0)!;
      final normalised = raw.replaceAll(',', '.');
      final value = double.tryParse(normalised);
      if (value == null) continue;

      // Ignore candidates matching the meter's serial number.
      if (meterNumber != null && meterNumber.isNotEmpty) {
        final cleanMeterNo = meterNumber.replaceAll(RegExp(r'\D'), '');
        final cleanRaw = raw.replaceAll(RegExp(r'\D'), '');
        if (cleanMeterNo.isNotEmpty &&
            (cleanRaw == cleanMeterNo || cleanRaw.contains(cleanMeterNo))) {
          continue;
        }
      }

      var score = 0.5;
      final digits = _digitCount(raw);

      // Penalize pure long integers (>7 digits without decimal) - serial/barcode numbers.
      if (!raw.contains('.') && !raw.contains(',') && digits >= 8) {
        score -= 0.6;
      } else if (digits >= 4 && digits <= 7) {
        score += 0.25;
      }

      // Check for disqualifying keywords on line or in block.
      final isDisqualified = _disqualifyingKeywords.any(
        (kw) => lineUpper.contains(kw) || blockUpper.contains(kw),
      );
      if (isDisqualified) {
        score -= 0.45;
      }

      // Check for unit or reading keywords.
      // Unit and reading-keyword bonuses only count on a line that is not
      // already disqualified. "3200impkWh" *contains* the unit precisely because
      // it is the pulse constant, and rewarding that let the nameplate outrank
      // the register: the constant collected +0.35 for the unit and +0.25 for the
      // reading keyword, swamping its own penalties.
      if (!isDisqualified) {
        final isUnitMatch = unit != null &&
            unit.isNotEmpty &&
            (lineUpper.contains(unit.toUpperCase()) ||
                blockUpper.contains(unit.toUpperCase()));
        if (isUnitMatch) score += 0.35;

        final isReadingKeyword = _readingKeywords.any(
          (kw) => lineUpper.contains(kw) || blockUpper.contains(kw),
        );
        if (isReadingKeyword) score += 0.25;
      }

      // Check leading zero pattern (e.g. 00124.5).
      if (raw.startsWith('0') && raw.length >= 3 && !raw.startsWith('0.')) {
        score += 0.15;
      }

      // Compare against expected digits if configured.
      if (expectedDigits != null) {
        final diff = (digits - expectedDigits).abs();
        score += switch (diff) {
          0 => 0.3,
          1 => 0.15,
          _ => -0.2,
        };
      }

      // Compare against the previous reading. A cumulative register moves
      // forward by a modest amount, so proximity is the single strongest signal
      // available — and its absence has to *cost* a candidate, not merely fail to
      // reward it. Rewarding only the plausible left nameplate constants
      // (3200imp/kWh, 240V, 50Hz, IEC 62053) tied at their base score, so noise
      // won by accident whenever the real reading was missed.
      if (previousReadingValue != null) {
        if (value >= previousReadingValue &&
            (value - previousReadingValue) <= 5000) {
          score += 0.4;
        } else if (value < previousReadingValue &&
            (previousReadingValue - value) <= 10) {
          // Just below: most likely a misread digit on a genuine reading.
          score += 0.1;
        } else if (previousReadingValue > 0 &&
            value < previousReadingValue * 0.5) {
          // Less than half the running total: impossible for a cumulative
          // register short of replacement. Weighted to overwhelm any combination
          // of positive heuristics, because being confidently wrong here writes a
          // bad reading into the user's history.
          score -= 1.2;
        } else if (previousReadingValue > 0 &&
            value > previousReadingValue * 2) {
          // More than double the total in one interval — a standards number
          // ("IEC 62053") or a misread, not a reading.
          score -= 1.0;
        } else if ((value - previousReadingValue).abs() > 100000) {
          score -= 0.4;
        } else if (value > previousReadingValue + 5000) {
          // Forward, but implausibly far for one reading interval.
          score -= 0.3;
        }
      }

      candidates.add(_ScoredCandidate(
        rawMatch: raw,
        value: value,
        score: score,
      ));
    }
  }

  if (candidates.isEmpty) return const OcrNumberResult.none();

  // Deduplicate candidates by value, keeping highest score.
  final uniqueMap = <double, _ScoredCandidate>{};
  for (final c in candidates) {
    if (!uniqueMap.containsKey(c.value) || c.score > uniqueMap[c.value]!.score) {
      uniqueMap[c.value] = c;
    }
  }

  final sorted = uniqueMap.values.toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  final best = sorted.first;
  final alternatives = sorted.skip(1).map((c) => c.value).toList();

  final finalConfidence = (best.score).clamp(0.05, 0.99);

  return OcrNumberResult(
    value: best.value,
    confidence: finalConfidence,
    rawMatch: best.rawMatch,
    candidateCount: sorted.length,
    alternativeValues: alternatives,
  );
}

/// Extracts the most reading-like number from raw [text], with backwards-compatibility.
OcrNumberResult extractLongestNumericSequence(
  String text, {
  int? expectedDigits,
  String? unit,
  String? meterNumber,
  double? previousReadingValue,
}) {
  final lines = text
      .split('\n')
      .map((l) => OcrLineContext(lineText: l.trim(), blockText: text))
      .toList();

  return extractMeterReadingFromLines(
    lines,
    expectedDigits: expectedDigits,
    unit: unit,
    meterNumber: meterNumber,
    previousReadingValue: previousReadingValue,
  );
}

