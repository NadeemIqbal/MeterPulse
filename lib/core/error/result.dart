import 'failures.dart';

/// A lightweight success/failure wrapper returned by use cases.
///
/// Preferred over throwing across the domain boundary: cubits pattern-match on
/// the result and never have to reason about which exception types a use case
/// might throw. Use [Ok] for success and [Err] for a typed [Failure].
///
/// ```dart
/// switch (await getMeters()) {
///   case Ok(:final value): emit(Loaded(value));
///   case Err(:final failure): emit(ErrorState(failure.message));
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Whether this result represents success.
  bool get isOk => this is Ok<T>;

  /// The value if [Ok], otherwise `null`.
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };
}

/// Successful result carrying a [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

/// Failed result carrying a typed [failure].
final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [action], wrapping the value in [Ok] or any thrown error in [Err].
///
/// Keeps use cases to a single line: `guard(() => repo.getMeters())`. Provide
/// [onError] to classify the failure; defaults to [DatabaseFailure] since most
/// guarded calls are Isar reads/writes.
Future<Result<T>> guard<T>(
  Future<T> Function() action, {
  Failure Function(Object error)? onError,
}) async {
  try {
    return Ok(await action());
  } catch (error) {
    return Err(onError?.call(error) ?? const DatabaseFailure());
  }
}
