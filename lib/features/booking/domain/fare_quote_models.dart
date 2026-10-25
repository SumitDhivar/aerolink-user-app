import '../../coverage/domain/coverage_result.dart';

/// Itemized fare line component.
class FareQuoteComponent {
  final String code;
  final String description;
  final double amount;

  const FareQuoteComponent({
    required this.code,
    required this.description,
    required this.amount,
  });

  factory FareQuoteComponent.fromJson(Map<String, dynamic> json) {
    return FareQuoteComponent(
      code: json['code'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

/// Segment allocation record representing segment-wise distance splitting per FR-FARE-002.
class SegmentAllocation {
  final String segmentId;
  final double distanceKm;
  final int passengerCountOnSegment;
  final double passengerAmount;

  const SegmentAllocation({
    required this.segmentId,
    required this.distanceKm,
    required this.passengerCountOnSegment,
    required this.passengerAmount,
  });

  factory SegmentAllocation.fromJson(Map<String, dynamic> json) {
    return SegmentAllocation(
      segmentId: json['segment_id'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      passengerCountOnSegment: json['passenger_count_on_segment'] as int,
      passengerAmount: (json['passenger_amount'] as num).toDouble(),
    );
  }
}

/// Request payload to compute fare quote matching OpenAPI FareQuoteRequest.
class FareQuoteRequest {
  final String direction; // airport_arrival, airport_departure
  final LocationInput origin;
  final LocationInput destination;
  final DateTime requestedTime;
  final int partySize;
  final String luggageProfile; // light, standard, heavy, custom
  final String bookingMode; // on_demand, advance

  const FareQuoteRequest({
    required this.direction,
    required this.origin,
    required this.destination,
    required this.requestedTime,
    this.partySize = 1,
    this.luggageProfile = 'standard',
    this.bookingMode = 'on_demand',
  });

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'origin': origin.toJson(),
        'destination': destination.toJson(),
        'requested_time': requestedTime.toIso8601String(),
        'party_size': partySize,
        'luggage_profile': luggageProfile,
        'booking_mode': bookingMode,
      };
}

/// Passenger fare quote payload conforming to OpenAPI FareQuote.
class FareQuote {
  final String quoteId;
  final String currency;
  final double total;
  final String status; // estimate, expired, superseded
  final String policyVersion;
  final DateTime expiresAt;
  final List<FareQuoteComponent> components;
  final List<SegmentAllocation> segmentAllocations;

  const FareQuote({
    required this.quoteId,
    this.currency = 'INR',
    required this.total,
    required this.status,
    required this.policyVersion,
    required this.expiresAt,
    this.components = const [],
    this.segmentAllocations = const [],
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  factory FareQuote.fromJson(Map<String, dynamic> json) {
    return FareQuote(
      quoteId: json['quote_id'] as String,
      currency: (json['currency'] as String?) ?? 'INR',
      total: (json['total'] as num).toDouble(),
      status: (json['status'] as String?) ?? 'estimate',
      policyVersion: (json['policy_version'] as String?) ?? 'v1.0-pilot',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      components: (json['components'] as List<dynamic>?)
              ?.map((e) => FareQuoteComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      segmentAllocations: (json['segment_allocations'] as List<dynamic>?)
              ?.map((e) => SegmentAllocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
