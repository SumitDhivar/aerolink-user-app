import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_error.dart';
import 'auth_interceptor.dart';
import 'idempotency_interceptor.dart';

/// Centralized API Client wrapping Dio with consistent error parsing.
class ApiClient {
  late final Dio dio;

  ApiClient({
    String? baseUrl,
    required SecureStorageService secureStorage,
    void Function()? onSessionExpired,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.defaultBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage, onSessionExpired: onSessionExpired),
      IdempotencyInterceptor(),
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    ]);
  }

  /// Map raw DioException to typed domain ApiError.
  ApiError mapDioException(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return const TimeoutError();
    }

    if (exception.type == DioExceptionType.connectionError ||
        exception.error is SocketException) {
      return const NetworkConnectionError();
    }

    final response = exception.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;

      String message = 'An error occurred';
      String? code;
      String? requestId;
      List<ApiErrorDetail> details = [];

      if (data is Map<String, dynamic>) {
        message = (data['message'] as String?) ??
            (data['detail'] as String?) ??
            message;
        code = data['code'] as String?;
        requestId = data['request_id'] as String?;

        if (data['details'] is List) {
          details = (data['details'] as List)
              .whereType<Map<String, dynamic>>()
              .map(ApiErrorDetail.fromJson)
              .toList();
        }
      }

      switch (statusCode) {
        case 400:
          return ValidationError(message, code: code, requestId: requestId, details: details);
        case 401:
          return const UnauthorizedError();
        case 403:
          return ForbiddenError(message);
        case 404:
          return NotFoundError(message);
        case 409:
          return ConflictError(message, code: code, requestId: requestId);
        case 422:
          return ValidationError(
            message,
            code: code ?? 'UNPROCESSABLE_ENTITY',
            requestId: requestId,
            details: details,
          );
        case 500:
        case 502:
        case 503:
          return ServerError(message, requestId);
        default:
          return ServerError(message, requestId);
      }
    }

    return const NetworkConnectionError();
  }
}
