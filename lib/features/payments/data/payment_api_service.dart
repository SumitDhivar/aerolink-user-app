import '../../../core/network/api_client.dart';
import '../domain/payment_models.dart';

class PaymentApiService {
  final ApiClient _apiClient;

  PaymentApiService(this._apiClient);

  Future<Payment> initiatePayment(PaymentCreateRequest request) async {
    final response = await _apiClient.dio.post(
      '/payments',
      data: request.toJson(),
    );
    return Payment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Payment> getPayment(String paymentId) async {
    final response = await _apiClient.dio.get('/payments/$paymentId');
    return Payment.fromJson(response.data as Map<String, dynamic>);
  }
}
