import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/calculation_engine/date_math.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/file_storage_service.dart';
import '../../../../core/services/image_capture_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/usecases/add_reading.dart';

enum CaptureStage {
  idle,
  requestingPermission,
  permissionDenied,
  capturing,
  processing,
  ready,
  saving,
  saved,
  error,
}

class ReadingCaptureState extends Equatable {
  const ReadingCaptureState({
    this.stage = CaptureStage.idle,
    this.imagePath,
    this.detectedValue,
    this.confidence,
    this.rawText,
    this.cameFromOcr = false,
    this.error,
    this.savedReadingId,
  });

  final CaptureStage stage;

  /// Temp path of the captured/picked image (persisted only on save).
  final String? imagePath;

  /// Value ML Kit extracted (null when OCR found nothing or entry is manual).
  final double? detectedValue;
  final double? confidence;
  final String? rawText;
  final bool cameFromOcr;

  final String? error;
  final int? savedReadingId;

  int? get confidencePercent =>
      confidence == null ? null : (confidence! * 100).round();

  /// Changes stage while preserving the captured image and OCR data.
  ReadingCaptureState copyWith({
    CaptureStage? stage,
    String? error,
    int? savedReadingId,
  }) {
    return ReadingCaptureState(
      stage: stage ?? this.stage,
      imagePath: imagePath,
      detectedValue: detectedValue,
      confidence: confidence,
      rawText: rawText,
      cameFromOcr: cameFromOcr,
      error: error,
      savedReadingId: savedReadingId ?? this.savedReadingId,
    );
  }

  @override
  List<Object?> get props => [
        stage,
        imagePath,
        detectedValue,
        confidence,
        rawText,
        cameFromOcr,
        error,
        savedReadingId,
      ];
}

/// Drives the capture → OCR → edit → save flow. Call [attach] with the meter
/// before use, and [checkForLostImage] when the screen (re)opens.
///
/// Every path is defensive: picker/OCR calls are wrapped in try/catch (the
/// system camera can die on some devices) and every post-`await` `emit` is
/// guarded by [isClosed] so a result arriving after the screen was torn down
/// never crashes the app.
class ReadingCaptureCubit extends Cubit<ReadingCaptureState> {
  ReadingCaptureCubit({
    required PermissionService permissionService,
    required ImageCaptureService imageCaptureService,
    required FileStorageService fileStorageService,
    required OcrDatasource ocrDatasource,
    required AddReading addReading,
    required ReadingRepository readingRepository,
    required BillingCycleRepository cycleRepository,
  })  : _permissions = permissionService,
        _capture = imageCaptureService,
        _storage = fileStorageService,
        _ocr = ocrDatasource,
        _addReading = addReading,
        _readings = readingRepository,
        _cycles = cycleRepository,
        super(const ReadingCaptureState());

  final PermissionService _permissions;
  final ImageCaptureService _capture;
  final FileStorageService _storage;
  final OcrDatasource _ocr;
  final AddReading _addReading;
  final ReadingRepository _readings;
  final BillingCycleRepository _cycles;

  late Meter _meter;

  void attach(Meter meter) => _meter = meter;

  /// Whether the UI should default the "start a new cycle" toggle to on: true
  /// only when the current cycle is due (today is on/after its expected reading
  /// date). Keeps ordinary mid-cycle readings accumulating in one cycle so
  /// consumption deltas are computed correctly.
  Future<bool> shouldSuggestNewCycle() async {
    try {
      final cycle = await _cycles.getOpenCycle(_meter.id!);
      final due = cycle?.expectedReadingDate;
      if (due == null) return false; // no cycle yet, or none scheduled
      return daysUntil(due, from: DateTime.now()) <= 0;
    } catch (_) {
      return false;
    }
  }

  static const String _cameraFailedMessage =
      'The camera closed unexpectedly. Try again, pick from gallery, or enter '
      'the reading manually.';

  /// Recovers a photo captured just before Android destroyed the activity
  /// (e.g. the system camera process was killed mid-capture). Safe to call on
  /// every open; does nothing when there's nothing to recover.
  Future<void> checkForLostImage() async {
    try {
      final path = await _capture.retrieveLostImage();
      if (path != null && !isClosed) await _runOcr(path);
    } catch (_) {
      // Nothing recoverable — stay on the start screen.
    }
  }

  /// Requests camera permission, captures a photo, and runs OCR on it.
  Future<void> captureFromCamera() async {
    try {
      emit(const ReadingCaptureState(stage: CaptureStage.requestingPermission));
      final granted = await _permissions.requestCamera();
      if (isClosed) return;
      if (!granted) {
        emit(const ReadingCaptureState(stage: CaptureStage.permissionDenied));
        return;
      }
      emit(const ReadingCaptureState(stage: CaptureStage.capturing));
      final path = await _capture.captureFromCamera();
      if (isClosed) return;
      if (path == null) {
        emit(const ReadingCaptureState()); // user backed out
        return;
      }
      await _runOcr(path);
    } catch (_) {
      if (!isClosed) {
        emit(const ReadingCaptureState(
          stage: CaptureStage.error,
          error: _cameraFailedMessage,
        ));
      }
    }
  }

  /// Picks an existing photo and runs OCR on it.
  Future<void> pickFromGallery() async {
    try {
      emit(const ReadingCaptureState(stage: CaptureStage.capturing));
      final path = await _capture.pickFromGallery();
      if (isClosed) return;
      if (path == null) {
        emit(const ReadingCaptureState());
        return;
      }
      await _runOcr(path);
    } catch (_) {
      if (!isClosed) {
        emit(const ReadingCaptureState(
          stage: CaptureStage.error,
          error: 'Could not open the gallery. Try again or enter manually.',
        ));
      }
    }
  }

  /// Skips the camera entirely and opens the editor for manual entry.
  void enterManually() {
    emit(const ReadingCaptureState(stage: CaptureStage.ready));
  }

  /// Opens the system app-settings page so a permanently-denied camera
  /// permission can be re-enabled.
  Future<void> openSettings() => _permissions.openSettings();

  Future<void> _runOcr(String path) async {
    emit(ReadingCaptureState(stage: CaptureStage.processing, imagePath: path));
    try {
      final result = await _ocr.scanReading(path);
      if (isClosed) return;
      emit(ReadingCaptureState(
        stage: CaptureStage.ready,
        imagePath: path,
        detectedValue: result.value,
        confidence: result.value == null ? null : result.confidence,
        rawText: result.rawText,
        cameFromOcr: result.value != null,
      ));
    } catch (_) {
      // OCR failed — still let the user type the value against the photo.
      if (isClosed) return;
      emit(ReadingCaptureState(stage: CaptureStage.ready, imagePath: path));
    }
  }

  /// Whether [value] is lower than the previous reading with no rollover
  /// configured — a possible meter reset or typo the UI should confirm.
  Future<bool> hasAnomaly(double value) async {
    final latest = await _readings.getLatestReading(_meter.id!);
    return unitsConsumed(
      value,
      latest?.readingValue,
      rolloverMax: _meter.rolloverValue,
    ).isAnomaly;
  }

  /// Persists the reading (and updates cycle state via [AddReading]).
  Future<void> save({
    required double value,
    required DateTime date,
    String? notes,
    bool startNewCycle = false,
  }) async {
    final current = state;
    emit(current.copyWith(stage: CaptureStage.saving));

    try {
      final photoPath = current.imagePath == null
          ? null
          : await _storage.persistImage(current.imagePath!);

      final isManual = !current.cameFromOcr ||
          current.detectedValue == null ||
          current.detectedValue != value;

      final reading = Reading(
        meterId: _meter.id!,
        readingValue: value,
        readingDate: date,
        photoPath: photoPath,
        ocrConfidence: current.cameFromOcr ? current.confidence : null,
        ocrRawText: current.rawText,
        isManualEntry: isManual,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final result = await _addReading(
        reading: reading,
        meter: _meter,
        startNewCycle: startNewCycle,
      );
      if (isClosed) return;

      switch (result) {
        case Ok(:final value):
          emit(current.copyWith(
            stage: CaptureStage.saved,
            savedReadingId: value,
          ));
        case Err(:final failure):
          // Keep the user in the editor (with their input) and surface the
          // message; the `error` stage is reserved for pre-editor failures.
          emit(current.copyWith(
            stage: CaptureStage.ready,
            error: failure.message,
          ));
      }
    } catch (_) {
      if (!isClosed) {
        emit(current.copyWith(
          stage: CaptureStage.ready,
          error: 'Could not save the reading. Please try again.',
        ));
      }
    }
  }
}
