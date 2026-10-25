import '../../coverage/domain/coverage_result.dart';

/// Immutable zone snapshot captured at booking creation per FR-ZONE-006.
class ZoneVersionSnapshot {
  final String zoneId;
  final int version;

  const ZoneVersionSnapshot({required this.zoneId, required this.version});

  factory ZoneVersionSnapshot.fromJson(Map<String, dynamic> json) {
    return ZoneVersionSnapshot(
      zoneId: json['zone_id'] as String,
      version: json['version'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'version': version,
      };
}

/// Request to create booking intent matching OpenAPI BookingCreateRequest.
class BookingCreateRequest {
  final String direction; // airport_arrival, airport_departure
  final LocationInput origin;
  final LocationInput destination;
  final DateTime requestedTime;
  final String bookingMode; // on_demand, advance
  final int partySize;
  final String luggageProfile;
  final String? flightNumber;
  final String? flightDate; // YYYY-MM-DD
  final String fareQuoteId;
  final String? passengerNote;

  const BookingCreateRequest({
    required this.direction,
    required this.origin,
    required this.destination,
    required this.requestedTime,
    required this.bookingMode,
    this.partySize = 1,
    this.luggageProfile = 'standard',
    this.flightNumber,
    this.flightDate,
    required this.fareQuoteId,
    this.passengerNote,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'direction': direction,
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'requested_time': requestedTime.toIso8601String(),
      'booking_mode': bookingMode,
      'party_size': partySize,
      'luggage_profile': luggageProfile,
      'fare_quote_id': fareQuoteId,
    };
    if (flightNumber != null && flightNumber!.isNotEmpty) {
      map['flight_number'] = flightNumber;
    }
    if (flightDate != null && flightDate!.isNotEmpty) {
      map['flight_date'] = flightDate;
    }
    if (passengerNote != null && passengerNote!.isNotEmpty) {
      map['passenger_note'] = passengerNote;
    }
    return map;
  }
}

/// Booking model matching OpenAPI Booking schema.
class Booking {
  final String id;
  final String status;
  final String direction;
  final DateTime requestedTime;
  final LocationInput origin;
  final LocationInput destination;
  final List<ZoneVersionSnapshot> zoneVersions;
  final String fareQuoteId;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.status,
    required this.direction,
    required this.requestedTime,
    required this.origin,
    required this.destination,
    this.zoneVersions = const [],
    required this.fareQuoteId,
    required this.createdAt,
  });

  bool get isRequested => status == 'requested';
  bool get isMatching => status == 'matching';
  bool get isMatched => status == 'matched';
  bool get isConfirmed => status == 'confirmed';
  bool get isDriverAssigned => status == 'driver_assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isFailed => status == 'match_failed' || status == 'payment_failed';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      status: (json['status'] as String?) ?? 'requested',
      direction: json['direction'] as String,
      requestedTime: DateTime.parse(json['requested_time'] as String),
      origin: LocationInput.fromJson(json['origin'] as Map<String, dynamic>),
      destination: LocationInput.fromJson(json['destination'] as Map<String, dynamic>),
      zoneVersions: (json['zone_versions'] as List<dynamic>?)
              ?.map((e) => ZoneVersionSnapshot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fareQuoteId: json['fare_quote_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Paginated booking list matching BookingList schema.
class BookingList {
  final List<Booking> items;
  final String? nextCursor;

  const BookingList({required this.items, this.nextCursor});

  factory BookingList.fromJson(Map<String, dynamic> json) {
    return BookingList(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextCursor: json['next_cursor'] as String?,
    );
  }
}
