import 'package:image_picker/image_picker.dart';

/// Captures a photo (or picks one) for reading/bill workflows.
///
/// Uses image_picker's system-camera capture rather than an in-app
/// `CameraController` preview — far simpler and more robust for Phase 1, and it
/// returns a temp file we run OCR on before deciding to persist it. Images are
/// downscaled/compressed on capture to keep storage small.
class ImageCaptureService {
  ImageCaptureService(this._picker);

  final ImagePicker _picker;

  static const double _maxWidth = 1600;
  static const int _quality = 85;

  /// Opens the camera; returns the captured file's temp path, or null if the
  /// user backed out.
  Future<String?> captureFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxWidth,
      imageQuality: _quality,
      preferredCameraDevice: CameraDevice.rear,
    );
    return file?.path;
  }

  /// Picks an existing image from the gallery; returns its temp path or null.
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxWidth,
      imageQuality: _quality,
    );
    return file?.path;
  }

  /// Recovers an image that was captured after Android destroyed the app's
  /// activity mid-capture (common when the camera app or camera HAL is killed).
  /// Returns the recovered file path, or null if there is nothing to recover.
  ///
  /// This is the officially recommended `retrieveLostData` pattern; without it
  /// a capture during an activity-recreation is silently lost.
  Future<String?> retrieveLostImage() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;
      return response.file?.path;
    } catch (_) {
      return null;
    }
  }
}
