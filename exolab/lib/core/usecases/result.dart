import 'package:exolab/core/failureHandlers/failureHandler.dart';

/// Lightweight Either-like type (no external package needed).
sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    final self = this;
    return switch (self) {
      Err<T>() => onFailure(self.failure),
      Ok<T>() => onSuccess(self.value),
    };
  }
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
