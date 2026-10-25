import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/payment_models.dart';
import '../domain/payment_repository.dart';
import 'payment_api_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentApiService apiService;
  final ApiClient apiClient;

  PaymentRepositoryImpl({
    required this.apiService,
    required this.apiClient,
  });

  @override
  Future<ApiResult<Payment>> initiatePayment(PaymentCreateRequest request) async {
    try {
      final payment = await apiService.initiatePayment(request);
      return Success(payment);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/payments'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<Payment>> getPaymentStatus(String paymentId) async {
    try {
      final payment = await apiService.getPayment(paymentId);
      return Success(payment);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/payments/$paymentId'), error: e),
      ));
    }
  }
}
