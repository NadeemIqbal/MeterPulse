import 'dart:io';
import 'dart:isolate';

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

  static const NormalizedRoi _roi = NormalizedRoi.meterDisplay;

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
        // High rather than max: the LCD is a small part of the frame and gets
        // upscaled after cropping, while max resolution slows capture and
        // decoding noticeably on mid-range hardware.
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _error = null;
      });
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _error = e.description ?? 'Could not open the camera.');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not open the camera.');
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

      // Decoding a full-resolution JPEG blocks long enough to drop frames, so
      // it runs on its own isolate.
      final cropped = await Isolate.run(() => cropImageToRoi(bytes, roi));

      var croppedPath = shot.path;
      if (cropped != null) {
        croppedPath = '${shot.path}_lcd.jpg';
        await File(croppedPath).writeAsBytes(cropped, flush: true);
      }

      if (!mounted) return;
      Navigator.of(context).pop(
        MeterCaptureResult(croppedPath: croppedPath, fullPath: shot.path),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _capturing = false;
        _error = 'Could not take the photo. Try again.';
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller),
                  CustomPaint(painter: _ReticlePainter(_roi)),
                  _reticleHint(),
                ],
              ),
            ),
          ),
        ),
        _shutterBar(),
      ],
    );
  }

  Widget _reticleHint() {
    final hint = widget.hint;
    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.maxHeight * _roi.top;
        return Positioned(
          left: 0,
          right: 0,
          top: (top - 56).clamp(8.0, constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                const Text(
                  'Line up the meter display inside the box',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 13,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shutterBar() => Container(
        color: Colors.black,
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
      Paint()..color = Colors.black54,
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
