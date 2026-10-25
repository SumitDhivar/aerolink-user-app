import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Interceptor that automatically injects JWT Bearer token into outgoing requests.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final void Function()? onSessionExpired;

  AuthInterceptor(this._secureStorage, {this.onSessionExpired});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If authorization header is already explicitly provided, do not overwrite
    if (!options.headers.containsKey('Authorization')) {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.clearAuthData();
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}
