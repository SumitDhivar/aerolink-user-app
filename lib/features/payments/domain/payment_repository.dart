import '../../../core/network/api_result.dart';
import 'payment_models.dart';

abstract class PaymentRepository {
  Future<ApiResult<Payment>> initiatePayment(PaymentCreateRequest request);

  Future<ApiResult<Payment>> getPaymentStatus(String paymentId);
}
