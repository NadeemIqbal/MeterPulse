/// Domain-level failures surfaced to the presentation layer.
///
/// Repositories and use cases translate low-level exceptions (Isar errors,
/// platform-channel errors, permission denials) into one of these so cubits
/// can render a consistent, user-facing message without knowing the source.
library;

/// Base type for every recoverable failure in the app.
sealed class Failure {
  const Failure(this.message);

  /// Human-readable, user-facing explanation of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A read/write against the local Isar database failed.
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Could not access local storage.']);
}

/// The camera could not be opened or a capture failed.
class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Could not access the camera.']);
}

/// A required runtime permission (camera) was denied by the user.
class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'Permission was denied. Enable it in system settings.',
  ]);
}

/// On-device text recognition failed to run on the captured image.
class OcrFailure extends Failure {
  const OcrFailure([super.message = 'Could not read the image. Enter the value manually.']);
}

/// User input failed a domain rule (e.g. reading lower than the previous one).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Fallback for anything not otherwise classified.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong. Please try again.']);
}
