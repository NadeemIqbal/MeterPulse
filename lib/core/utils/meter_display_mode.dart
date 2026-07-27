/// Reasoning about *which* value a cycling meter display is currently showing.
///
/// Pure Dart so it can be unit-tested with plain numbers.
///
/// Electronic meters rotate their LCD through several readings. A K-Electric
/// single-phase unit cycles, per the "Display Sequence" printed on its face:
///
///   1. Serial No. (the K-Electric number)
///   2. KWH — the cumulative energy reading, the only one worth recording
///   3. Prev Month MD — previous month's maximum demand, in kW
///   4. Curr Month MD — this month's maximum demand, in kW
///   5. Instantaneous KW — what the premises is drawing right now
///
/// Every one of those is a plausible-looking number in the same place on the
/// glass. Cropping to the display sharpens recognition but says nothing about
/// which mode produced the digits, so a good crop alone just makes a wrong
/// reading *more* confident. This classifies the candidate instead.
library;

/// What a scanned number appears to represent.
enum MeterDisplayMode {
  /// A cumulative energy total — the reading to record.
  energyTotal,

  /// A maximum-demand or instantaneous power figure, in kW.
  demandOrPower,

  /// The meter's serial number.
  serialNumber,

  /// Not enough signal to tell.
  unknown,
}

/// Why a candidate was accepted or rejected, for display to the user.
enum ReadingPlausibility {
  /// Consistent with the previous reading: forward movement, sane magnitude.
  plausible,

  /// Below the previous reading. Either the wrong display mode was captured or
  /// a digit was misread — a cumulative meter cannot run backwards.
  wentBackwards,

  /// Forward, but by an implausibly large amount for the elapsed period.
  implausibleJump,

  /// Looks like a demand/power value rather than an energy total.
  wrongMode,

  /// No previous reading to compare against, so nothing to contradict.
  unverified,
}

/// Verdict on a scanned candidate.
class ReadingAssessment {
  const ReadingAssessment({
    required this.mode,
    required this.plausibility,
    this.message,
  });

  final MeterDisplayMode mode;
  final ReadingPlausibility plausibility;

  /// Human-readable explanation, null when the reading looks fine.
  final String? message;

  /// Whether the value should be accepted without questioning the user.
  bool get isClean =>
      plausibility == ReadingPlausibility.plausible ||
      plausibility == ReadingPlausibility.unverified;
}

/// Classifies [value] against the meter's history.
///
/// [previousValue] is the last recorded reading, [daysElapsed] the gap since it
/// was taken, and [expectedMonthlyUnits] the meter's configured typical usage —
/// all optional, and the assessment degrades to [ReadingPlausibility.unverified]
/// rather than guessing when they are missing.
ReadingAssessment assessReading(
  double value, {
  double? previousValue,
  int? daysElapsed,
  double? expectedMonthlyUnits,
  String? meterNumber,
}) {
  // A digit-for-digit match with the serial number means mode 1 was captured.
  if (meterNumber != null && meterNumber.isNotEmpty) {
    final serialDigits = meterNumber.replaceAll(RegExp(r'\D'), '');
    final valueDigits = value.toStringAsFixed(0);
    if (serialDigits.isNotEmpty && serialDigits == valueDigits) {
      return const ReadingAssessment(
        mode: MeterDisplayMode.serialNumber,
        plausibility: ReadingPlausibility.wrongMode,
        message: 'That looks like the meter serial number, not the reading. '
            'Wait for the display to cycle to KWH.',
      );
    }
  }

  if (previousValue == null) {
    return const ReadingAssessment(
      mode: MeterDisplayMode.unknown,
      plausibility: ReadingPlausibility.unverified,
    );
  }

  // A cumulative register never decreases. Landing well below the previous
  // reading almost always means a demand or instantaneous value was captured:
  // those are small numbers (a few kW) against a five-or-six-digit total.
  if (value < previousValue) {
    final looksLikePower = previousValue > 0 && value < previousValue * 0.25;
    if (looksLikePower) {
      return ReadingAssessment(
        mode: MeterDisplayMode.demandOrPower,
        plausibility: ReadingPlausibility.wrongMode,
        message: 'That looks like a demand or instantaneous kW value, not the '
            'meter total. Wait for the display to cycle to KWH, then capture '
            'again.',
      );
    }
    return ReadingAssessment(
      mode: MeterDisplayMode.energyTotal,
      plausibility: ReadingPlausibility.wentBackwards,
      message: 'This is lower than the last reading '
          '(${_short(previousValue)}). A meter total cannot go down — check the '
          'digits, or whether the meter was replaced.',
    );
  }

  // Forward, but by how much? Compare against the meter's own typical rate when
  // configured, otherwise against a generous ceiling.
  final delta = value - previousValue;
  final days = (daysElapsed == null || daysElapsed <= 0) ? 1 : daysElapsed;
  final ceiling = expectedMonthlyUnits != null && expectedMonthlyUnits > 0
      // Ten times the expected daily rate leaves room for genuinely heavy use
      // without waving through an extra digit.
      ? (expectedMonthlyUnits / 30) * days * 10
      : 1000.0 * days;

  if (delta > ceiling) {
    return ReadingAssessment(
      mode: MeterDisplayMode.energyTotal,
      plausibility: ReadingPlausibility.implausibleJump,
      message: 'That is ${_short(delta)} units in $days '
          '${days == 1 ? 'day' : 'days'}, which is far more than usual for this '
          'meter. Check for a misread digit.',
    );
  }

  return const ReadingAssessment(
    mode: MeterDisplayMode.energyTotal,
    plausibility: ReadingPlausibility.plausible,
  );
}

String _short(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
