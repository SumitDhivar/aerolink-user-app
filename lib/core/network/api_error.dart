/// Structured error detail item matching backend ErrorDetail schema.
class ApiErrorDetail {
  final String? field;
  final String issue;

  const ApiErrorDetail({this.field, required this.issue});

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      field: json['field'] as String?,
      issue: (json['issue'] as String?) ?? 'Unknown field validation issue',
    );
  }
}

/// Base sealed hierarchy of API errors conforming to ErrorResponse schema.
sealed class ApiError implements Exception {
  final String message;
  final String? code;
  final String? requestId;
  final bool retryable;
  final List<ApiErrorDetail> details;

  const ApiError({
    required this.message,
    this.code,
    this.requestId,
    this.retryable = false,
    this.details = const [],
  });

  @override
  String toString() => 'ApiError(code: $code, message: $message, retryable: $retryable)';
}

class NetworkConnectionError extends ApiError {
  const NetworkConnectionError([String message = 'Network connection unavailable. Please check your data signal.'])
      : super(message: message, code: 'NETWORK_ERROR', retryable: true);
}

class TimeoutError extends ApiError {
  const TimeoutError([String message = 'The request timed out. Please try again.'])
      : super(message: message, code: 'TIMEOUT_ERROR', retryable: true);
}

class UnauthorizedError extends ApiError {
  const UnauthorizedError([String message = 'Your session has expired. Please sign in again.'])
      : super(message: message, code: 'UNAUTHORIZED', retryable: false);
}

class ForbiddenError extends ApiError {
  const ForbiddenError([String message = 'You do not have permission to perform this action.'])
      : super(message: message, code: 'FORBIDDEN', retryable: false);
}

class NotFoundError extends ApiError {
  const NotFoundError([String message = 'The requested resource was not found.'])
      : super(message: message, code: 'NOT_FOUND', retryable: false);
}

class ConflictError extends ApiError {
  const ConflictError(String message, {String? code, super.requestId})
      : super(message: message, code: code ?? 'CONFLICT', retryable: false);
}

class ValidationError extends ApiError {
  const ValidationError(
    String message, {
    String? code,
    super.requestId,
    super.details = const [],
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          retryable: false,
        );
}

class ZoneCoverageError extends ApiError {
  final String resultCode;
  final String nextAction;

  const ZoneCoverageError({
    required super.message,
    required this.resultCode,
    required this.nextAction,
    super.requestId,
  }) : super(
          code: resultCode,
          retryable: false,
        );
}

class ServerError extends ApiError {
  const ServerError([
    String message = 'An unexpected server error occurred. Our team has been notified.',
    String? requestId,
  ]) : super(message: message, code: 'SERVER_ERROR', requestId: requestId, retryable: true);
}
