import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/image_crop.dart';

/// Outcome of an in-app meter capture.
class MeterCaptureResult {
  const MeterCaptureResult({required this.croppedPath, required this.fullPath});

  /// The LCD region only — what OCR should read.
  final String croppedPath;

  /// The whole frame, kept as the reading's photo so the user still has context.
  final String fullPath;
}

/// Full-screen camera framed on a meter's LCD.
///
/// Replaces the system-camera handoff for readings. `image_picker` returns
/// whatever the camera app produced, with no control over framing, so OCR had to
/// read the entire nameplate and pick a number out of the voltage, frequency,
/// imp/kWh rate, serial and model printed there. Here the user aligns the
/// display inside a reticle and only that region is recognised.
///
/// The preview is deliberately letterboxed to the sensor's aspect ratio rather
/// than filling the screen: the reticle is stored as fractions of the frame, and
/// they only map onto the captured photo if the preview shows the entire frame.
/// A cover-fit preview hides part of the sensor and would silently shift the
/// crop away from what the user framed.
class MeterCameraPage extends StatefulWidget {
  const MeterCameraPage({super.key, this.hint});

  /// Guidance shown above the reticle, e.g. which display mode to wait for.
  final String? hint;

  @override
  State<MeterCameraPage> createState() => _MeterCameraPageState();
}

class _MeterCameraPageState extends State<MeterCameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  bool _capturing = false;
  bool _torchOn = false;

  /// Derived from the live preview's aspect ratio once the controller is up, so
  /// the band is LCD-shaped on any sensor rather than a fixed fraction that
  /// happens to swallow the nameplate rows on some.
  NormalizedRoi _roi = NormalizedRoi.meterDisplay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Android reclaims the camera when the app backgrounds; the old controller
    // is dead on return and must be rebuilt rather than reused.
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      _start();
    }
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera is available on this device.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        // The LCD occupies a small slice of the frame, and after cropping only
        // those pixels remain for the recognizer — so capture resolution sets the
        // ceiling on accuracy. `high` gave a 1920x1080 still, leaving a tightly
        // cropped display only a few hundred pixels wide. Upscaling cannot invent
        // detail, so capture more of it.
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      // Portrait preview: controller.value.aspectRatio is the sensor's
      // width/height, so invert it to get the on-screen box's aspect.
      final previewAspect = 1 / controller.value.aspectRatio;
      final roi = NormalizedRoi.forDisplay(previewAspect: previewAspect);

      setState(() {
        _controller = controller;
        _roi = roi;
        _error = null;
      });

      await _meterOnReticle(controller, roi);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _error = e.description ?? 'Could not open the camera.');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not open the camera.');
    }
  }

  /// Points autofocus and auto-exposure at the reticle instead of the whole
  /// frame.
  ///
  /// Metering the full scene lets a pale meter body dominate, so a backlit LCD
  /// blows out to a white slab and focus favours the body rather than the glass —
  /// both directly cost OCR accuracy. Focus/exposure points are normalized 0–1,
  /// the same space the ROI already uses.
  Future<void> _meterOnReticle(
    CameraController controller,
    NormalizedRoi roi,
  ) async {
    final centre = Offset(roi.left + roi.width / 2, roi.top + roi.height / 2);
    // Each call is individually optional — plenty of devices support only some,
    // and an unsupported one must not abort the rest or fail the screen.
    for (final action in <Future<void> Function()>[
      () => controller.setFocusMode(FocusMode.auto),
      () => controller.setExposureMode(ExposureMode.auto),
      () => controller.setFocusPoint(centre),
      () => controller.setExposurePoint(centre),
    ]) {
      try {
        await action();
      } catch (_) {}
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setFlashMode(_torchOn ? FlashMode.off : FlashMode.torch);
      setState(() => _torchOn = !_torchOn);
    } catch (_) {
      // Some devices refuse torch control; leave the button inert rather than
      // failing the capture.
    }
  }

  /// Crops on a background isolate.
  ///
  /// Deliberately `static`. An `Isolate.run` closure written inline in `_capture`
  /// captured `this`: a closure in an instance method shares that method's
  /// context, and because `_capture` also touches `_controller`, `setState` and
  /// `mounted`, the context transitively held the State object. Sending it failed
  /// with "object is unsendable - Class: _Future … <- Instance of
  /// '_MeterCameraPageState'", so every crop silently fell through to the inline
  /// path and janked the UI thread. A static method has no `this` to capture.
  static Future<Uint8List?> _cropOffThread(
    Uint8List bytes,
    NormalizedRoi roi,
  ) =>
      Isolate.run(() => cropImageToRoi(bytes, roi, expectPortrait: true));

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final shot = await controller.takePicture();
      final bytes = await File(shot.path).readAsBytes();

      // A little margin so slightly-off alignment does not clip digits, which
      // hurts recognition far more than surrounding space does.
      final roi = _roi.inflated(0.06);

      // Decoding a full-resolution JPEG blocks long enough to drop frames, so it
      // runs on its own isolate. Guarded separately from the capture: cropping is
      // an optimisation for OCR accuracy, and losing it must degrade to reading
      // the full frame rather than throwing away a photo the user just took.
      // The reticle was drawn over a portrait preview, so the region is measured
      // in portrait. Android's still is landscape and may lack the EXIF rotation
      // that would correct it, hence stating the expectation explicitly.
      //
      // Tried off-thread first because decoding a full-resolution JPEG drops
      // frames, then retried inline. Losing the crop is not a cosmetic
      // degradation: it hands the recognizer the entire nameplate, where "240V",
      // "50Hz" and "3200imp/kWh" outrank the actual reading. A moment of jank is
      // vastly preferable, so the inline attempt is a guaranteed second chance
      // rather than an optimisation.
      Uint8List? cropped;
      try {
        cropped = await _cropOffThread(bytes, roi);
      } catch (e) {
        debugPrint('MeterCameraPage: crop isolate failed: $e');
      }
      if (cropped == null) {
        try {
          cropped = cropImageToRoi(bytes, roi, expectPortrait: true);
          debugPrint('MeterCameraPage: inline crop $lastDiagnostics '
              '-> ${cropped?.length} bytes');
        } catch (e) {
          debugPrint('MeterCameraPage: inline crop failed too: $e');
        }
      }
      debugPrint('MeterCameraPage: roi=(${roi.left},${roi.top},'
          '${roi.width},${roi.height}) cropBytes=${cropped?.length} '
          'srcBytes=${bytes.length}');

      var croppedPath = shot.path;
      if (cropped != null) {
        // Sibling file with a .jpg extension rather than appending to the
        // existing name: ML Kit and the platform decoder both key off the
        // extension, and "…jpg_lcd.jpg" is fragile.
        final dir = File(shot.path).parent.path;
        final stem = shot.path.split('/').last.split('.').first;
        croppedPath = '$dir/${stem}_lcd.jpg';
        await File(croppedPath).writeAsBytes(cropped, flush: true);
      }

      if (!mounted) return;
      Navigator.of(context).pop(
        MeterCaptureResult(croppedPath: croppedPath, fullPath: shot.path),
      );
    } catch (e, stack) {
      // Report before swallowing. A bare `catch (_)` here meant a capture
      // failure surfaced only as "Could not take the photo", with nothing in the
      // logs to say which step broke — the error has to reach the log even
      // though the UI stays friendly.
      debugPrint('MeterCameraPage: capture failed: $e');
      debugPrintStack(stackTrace: stack, label: 'MeterCameraPage.capture');
      if (!mounted) return;
      setState(() {
        _capturing = false;
        _error = 'Could not take the photo ($e). Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan meter'),
        actions: [
          if (controller != null && controller.value.isInitialized)
            IconButton(
              tooltip: _torchOn ? 'Torch off' : 'Torch on',
              icon: Icon(_torchOn
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_off_rounded),
              onPressed: _toggleTorch,
            ),
        ],
      ),
      body: _error != null
          ? _errorView(_error!)
          : controller == null || !controller.value.isInitialized
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _cameraView(controller),
    );
  }

  Widget _errorView(String message) => Center(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off_rounded,
                  color: Colors.white70, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  setState(() => _error = null);
                  _start();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );

  Widget _cameraView(CameraController controller) {
    return Column(
      children: [
        Expanded(
          child: Center(
            // Letterboxed, not cover-fit — see the class doc: the reticle
            // fractions must describe the same area in preview and photo.
            child: AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              // One LayoutBuilder wrapping the Stack, so the hint's Positioned
              // is a *direct* Stack child. Returning a Positioned from inside a
              // LayoutBuilder that is itself the Stack's child applies
              // StackParentData to a render object expecting BoxParentData: it
              // throws on every build and leaves the overlay's layout corrupt.
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),
                    CustomPaint(painter: _ReticlePainter(_roi)),
                    // Anchored by its *bottom* to just above the reticle, so the
                    // pill cannot overlap the box however many lines it wraps to.
                    // Positioning by `top` minus a guessed height put a two-line
                    // hint straight over the reticle's upper edge.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: (constraints.maxHeight * (1 - _roi.top) + 10)
                          .clamp(0.0, constraints.maxHeight - 40),
                      child: _hintText(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _shutterBar(),
      ],
    );
  }

  Widget _hintText() {
    final hint = widget.hint;
    // An opaque plate rather than text shadows: shadows fail over exactly the
    // bright, glare-lit meters where the guidance matters most.
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Names the real constraint: the digits must be *large*, not merely
            // inside the box. Distance is what decides whether OCR can read them.
            const Text(
              'Move closer until the digits fill the box',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            if (hint != null) ...[
              const SizedBox(height: 2),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SafeArea is load-bearing, not cosmetic. Without it the shutter sits inside
  // Android's gesture-navigation strip, where the system's swipe-up monitor
  // steals the touch — observed in logcat as "[Gesture Monitor] swipe-up is
  // stealing input gesture", with the app sent to the launcher instead of taking
  // a photo. The button was simply not pressable.
  Widget _shutterBar() => Container(
        color: Colors.black,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
          child: _capturing
              ? const SizedBox(
                  height: 64,
                  width: 64,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : GestureDetector(
                  onTap: _capture,
                  child: Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white24, width: 4),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.black, size: 30),
                  ),
                ),
            ),
          ),
        ),
      );
}

/// Dims everything outside the reticle and draws corner brackets around it.
class _ReticlePainter extends CustomPainter {
  const _ReticlePainter(this.roi);

  final NormalizedRoi roi;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      roi.left * size.width,
      roi.top * size.height,
      roi.width * size.width,
      roi.height * size.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Punch the reticle out of a translucent scrim so the target area is the
    // only part of the frame at full brightness.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(rrect),
      ),
      // 0.34, not black54. At 54% nothing outside the reticle can be brighter
      // than mid-grey, which reads as a sheet laid over the whole viewfinder
      // rather than emphasis on the target.
      Paint()..color = Colors.black.withValues(alpha: 0.34),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white70,
    );

    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.cyanAccent;
    final len = rect.shortestSide * 0.22;

    for (final (corner, dx, dy) in [
      (rect.topLeft, 1.0, 1.0),
      (rect.topRight, -1.0, 1.0),
      (rect.bottomLeft, 1.0, -1.0),
      (rect.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(corner, corner.translate(len * dx, 0), bracket);
      canvas.drawLine(corner, corner.translate(0, len * dy), bracket);
    }
  }

  @override
  bool shouldRepaint(_ReticlePainter oldDelegate) => oldDelegate.roi != roi;
}
