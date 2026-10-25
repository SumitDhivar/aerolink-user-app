import 'api_error.dart';

/// Generic Result type representing either Success(T) or Failure(ApiError).
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(data: final data) => data,
        Failure<T>() => null,
      };

  ApiError? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(error: final error) => error,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError error) failure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Failure<T>(error: final error) => failure(error),
    };
  }
}

final class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends ApiResult<T> {
  final ApiError error;
  const Failure(this.error);
}
