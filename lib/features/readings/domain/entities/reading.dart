import 'package:equatable/equatable.dart';

/// A single meter reading. Photos are referenced by file path, never bytes.
class Reading extends Equatable {
  const Reading({
    this.id,
    required this.meterId,
    this.billingCycleId,
    required this.readingValue,
    required this.readingDate,
    this.photoPath,
    this.ocrConfidence,
    this.ocrRawText,
    this.isManualEntry = false,
    this.notes,
    required this.createdAt,
  });

  final int? id;
  final int meterId;
  final int? billingCycleId;
  final double readingValue;
  final DateTime readingDate;
  final String? photoPath;

  /// Synthesized OCR confidence 0–1, or null when entered manually.
  final double? ocrConfidence;
  final String? ocrRawText;
  final bool isManualEntry;
  final String? notes;
  final DateTime createdAt;

  Reading copyWith({int? id, int? billingCycleId}) {
    return Reading(
      id: id ?? this.id,
      meterId: meterId,
      billingCycleId: billingCycleId ?? this.billingCycleId,
      readingValue: readingValue,
      readingDate: readingDate,
      photoPath: photoPath,
      ocrConfidence: ocrConfidence,
      ocrRawText: ocrRawText,
      isManualEntry: isManualEntry,
      notes: notes,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        meterId,
        billingCycleId,
        readingValue,
        readingDate,
        photoPath,
        ocrConfidence,
        ocrRawText,
        isManualEntry,
        notes,
        createdAt,
      ];
}
