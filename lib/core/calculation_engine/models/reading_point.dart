import 'package:equatable/equatable.dart';

/// A plain `(value, date)` pair handed to the calculation engine.
///
/// The engine operates on these instead of Isar `ReadingModel`s so all
/// consumption maths stays pure and unit-testable with hand-built fixtures.
class ReadingPoint extends Equatable {
  const ReadingPoint({required this.value, required this.date});

  /// Raw meter value as read from the dial.
  final double value;

  /// The date the reading was taken (time-of-day is ignored by the engine).
  final DateTime date;

  @override
  List<Object?> get props => [value, date];
}
