import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper over `permission_handler` for the one runtime permission Phase
/// 1 needs: the camera. Because the manifest declares `CAMERA`, image_picker
/// requires it to be granted before a camera capture, so callers must request
/// it here first.
class PermissionService {
  const PermissionService();

  /// Requests camera access, returning true if granted.
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Whether the user has permanently denied the camera (needs a trip to app
  /// settings to re-enable).
  Future<bool> isCameraPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Opens the system app-settings page so the user can flip a denied
  /// permission back on.
  Future<bool> openSettings() => openAppSettings();
}
