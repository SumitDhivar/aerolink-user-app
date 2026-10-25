import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Interceptor that attaches an Idempotency-Key header to mutative requests (POST, PATCH)
/// unless one has already been explicitly supplied.
class IdempotencyInterceptor extends Interceptor {
  final Uuid _uuid = const Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    if (method == 'POST' || method == 'PATCH') {
      if (!options.headers.containsKey('Idempotency-Key')) {
        options.headers['Idempotency-Key'] = _uuid.v4();
      }
    }
    handler.next(options);
  }
}
