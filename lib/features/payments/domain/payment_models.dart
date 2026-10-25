/// Payment initiation payload matching OpenAPI PaymentCreateRequest.
class PaymentCreateRequest {
  final String bookingId;
  final String fareQuoteId;
  final String method;

  const PaymentCreateRequest({
    required this.bookingId,
    required this.fareQuoteId,
    this.method = 'razorpay_checkout',
  });

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'fare_quote_id': fareQuoteId,
        'method': method,
      };
}

/// Payment representation matching OpenAPI PaymentSchema.
class Payment {
  final String id;
  final String status; // created, pending_provider, authorized, captured, failed, refunded, etc.
  final double amount;
  final String currency;
  final String? providerReference;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.status,
    required this.amount,
    this.currency = 'INR',
    this.providerReference,
    required this.updatedAt,
  });

  bool get isCaptured => status == 'captured';
  bool get isAuthorized => status == 'authorized';
  bool get isPending => status == 'created' || status == 'pending_provider';
  bool get isFailed => status == 'failed';

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      status: (json['status'] as String?) ?? 'created',
      amount: (json['amount'] as num).toDouble(),
      currency: (json['currency'] as String?) ?? 'INR',
      providerReference: json['provider_reference'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
