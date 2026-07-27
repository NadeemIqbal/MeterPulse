import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/calculation_engine/date_math.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/file_storage_service.dart';
import '../../../../core/services/image_capture_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../../core/utils/meter_display_mode.dart';
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
    this.previousReading,
    this.alternativeCandidates = const [],
    this.assessment,
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

  /// Previous reading on this meter, if any.
  final Reading? previousReading;

  /// Alternative numeric candidates found on the meter display.
  final List<double> alternativeCandidates;

  /// Verdict on whether [detectedValue] looks like the meter's energy total
  /// rather than one of the other values the display cycles through.
  final ReadingAssessment? assessment;

  int? get confidencePercent =>
      confidence == null ? null : (confidence! * 100).round();

  /// Changes stage while preserving the captured image and OCR data.
  ReadingCaptureState copyWith({
    CaptureStage? stage,
    String? error,
    int? savedReadingId,
    Reading? previousReading,
    List<double>? alternativeCandidates,
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
      previousReading: previousReading ?? this.previousReading,
      alternativeCandidates:
          alternativeCandidates ?? this.alternativeCandidates,
      assessment: assessment,
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
        previousReading,
        alternativeCandidates,
        assessment,
      ];
}

/// Drives the capture → OCR → edit → save flow. Call [attach] with the meter
/// before use, and [checkForLostImage] when the screen (re)opens.
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
  Reading? _previousReading;

  Future<void> attach(Meter meter) async {
    _meter = meter;
    try {
      _previousReading = await _readings.getLatestReading(meter.id!);
      emit(state.copyWith(previousReading: _previousReading));
    } catch (_) {}
  }

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
      emit(ReadingCaptureState(
        stage: CaptureStage.requestingPermission,
        previousReading: _previousReading,
      ));
      final granted = await _permissions.requestCamera();
      if (isClosed) return;
      if (!granted) {
        emit(ReadingCaptureState(
          stage: CaptureStage.permissionDenied,
          previousReading: _previousReading,
        ));
        return;
      }
      emit(ReadingCaptureState(
        stage: CaptureStage.capturing,
        previousReading: _previousReading,
      ));
      final path = await _capture.captureFromCamera();
      if (isClosed) return;
      if (path == null) {
        emit(ReadingCaptureState(previousReading: _previousReading)); // user backed out
        return;
      }
      await _runOcr(path);
    } catch (_) {
      if (!isClosed) {
        emit(ReadingCaptureState(
          stage: CaptureStage.error,
          error: _cameraFailedMessage,
          previousReading: _previousReading,
        ));
      }
    }
  }

  /// Requests camera permission for the in-app camera, which manages its own
  /// preview rather than delegating to the system camera app.
  Future<bool> requestCameraPermission() => _permissions.requestCamera();

  /// Moves to the permission-denied screen after a refused request.
  void markPermissionDenied() {
    emit(ReadingCaptureState(
      stage: CaptureStage.permissionDenied,
      previousReading: _previousReading,
    ));
  }

  /// Handles the result of the in-app camera: OCR reads the cropped LCD while
  /// the full frame is kept as the reading's photo.
  Future<void> useInAppCapture({
    required String croppedPath,
    required String fullPath,
  }) async {
    await _runOcr(fullPath, ocrPath: croppedPath);
  }

  /// Picks an existing photo and runs OCR on it.
  Future<void> pickFromGallery() async {
    try {
      emit(ReadingCaptureState(
        stage: CaptureStage.capturing,
        previousReading: _previousReading,
      ));
      final path = await _capture.pickFromGallery();
      if (isClosed) return;
      if (path == null) {
        emit(ReadingCaptureState(previousReading: _previousReading));
        return;
      }
      await _runOcr(path);
    } catch (_) {
      if (!isClosed) {
        emit(ReadingCaptureState(
          stage: CaptureStage.error,
          error: 'Could not open the gallery. Try again or enter manually.',
          previousReading: _previousReading,
        ));
      }
    }
  }

  /// Skips the camera entirely and opens the editor for manual entry.
  void enterManually() {
    emit(ReadingCaptureState(
      stage: CaptureStage.ready,
      previousReading: _previousReading,
    ));
  }

  /// Opens the system app-settings page so a permanently-denied camera
  /// permission can be re-enabled.
  Future<void> openSettings() => _permissions.openSettings();

  /// Runs OCR and opens the editor.
  ///
  /// [path] is the photo kept with the reading. [ocrPath] is what gets
  /// recognised — for an in-app capture that is the cropped LCD, so the parser
  /// never sees the voltage, frequency, imp/kWh rate or serial printed on the
  /// nameplate. Defaults to [path] for gallery picks and recovered images.
  Future<void> _runOcr(String path, {String? ocrPath}) async {
    emit(ReadingCaptureState(
      stage: CaptureStage.processing,
      imagePath: path,
      previousReading: _previousReading,
    ));
    try {
      // A cumulative register keeps its digit width from one reading to the next,
      // so the previous reading's length is a strong prior against short
      // nameplate constants (240, 50) and long ones (62053) alike.
      final prev = _previousReading?.readingValue;
      final expectedDigits = prev?.toStringAsFixed(0).length;

      final result = await _ocr.scanReading(
        ocrPath ?? path,
        unit: _meter.unit,
        meterNumber: _meter.meterNumber,
        previousReadingValue: prev,
        expectedDigits: expectedDigits,
      );
      if (isClosed) return;

      // Diagnostic: what the recognizer actually saw. If nameplate text such as
      // "3200imp/kWh", "240V" or "50Hz" appears here, the crop is not isolating
      // the LCD — a very different problem from the recognizer struggling with
      // seven-segment glyphs, and the two demand opposite fixes.
      debugPrint('OCR[${ocrPath ?? path}] raw="${result.rawText.replaceAll('\n', ' | ')}"');
      debugPrint('OCR value=${result.value} alts=${result.alternativeValues}');

      // The display cycles through serial, kWh, both MD registers and
      // instantaneous kW, all rendered identically. Recognising the digits
      // cleanly says nothing about which of those produced them, so judge the
      // value against the meter's history before presenting it as a reading.
      final assessment = result.value == null
          ? null
          : assessReading(
              result.value!,
              previousValue: _previousReading?.readingValue,
              daysElapsed: _previousReading == null
                  ? null
                  : DateTime.now()
                      .difference(_previousReading!.readingDate)
                      .inDays,
              expectedMonthlyUnits: _meter.expectedMonthlyUnits,
              meterNumber: _meter.meterNumber,
            );

      emit(ReadingCaptureState(
        stage: CaptureStage.ready,
        imagePath: path,
        detectedValue: result.value,
        confidence: result.value == null ? null : result.confidence,
        rawText: result.rawText,
        cameFromOcr: result.value != null,
        previousReading: _previousReading,
        alternativeCandidates: result.alternativeValues,
        assessment: assessment,
      ));
    } catch (_) {
      // OCR failed — still let the user type the value against the photo.
      if (isClosed) return;
      emit(ReadingCaptureState(
        stage: CaptureStage.ready,
        imagePath: path,
        previousReading: _previousReading,
      ));
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
