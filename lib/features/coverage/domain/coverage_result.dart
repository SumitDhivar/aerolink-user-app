/// Geographic coordinates payload matching Coordinates schema.
class Coordinates {
  final double latitude;
  final double longitude;
  final double? accuracyM;

  const Coordinates({
    required this.latitude,
    required this.longitude,
    this.accuracyM,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyM: (json['accuracy_m'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (accuracyM != null) {
      map['accuracy_m'] = accuracyM;
    }
    return map;
  }
}

/// Location input representation matching LocationInput schema.
class LocationInput {
  final Coordinates coordinates;
  final bool confirmedPin;
  final String? placeId;

  const LocationInput({
    required this.coordinates,
    this.confirmedPin = false,
    this.placeId,
  });

  factory LocationInput.fromJson(Map<String, dynamic> json) {
    return LocationInput(
      coordinates: Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      confirmedPin: (json['confirmed_pin'] as bool?) ?? false,
      placeId: json['place_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'coordinates': coordinates.toJson(),
      'confirmed_pin': confirmedPin,
    };
    if (placeId != null) {
      map['place_id'] = placeId;
    }
    return map;
  }

  LocationInput copyWith({
    Coordinates? coordinates,
    bool? confirmedPin,
    String? placeId,
  }) {
    return LocationInput(
      coordinates: coordinates ?? this.coordinates,
      confirmedPin: confirmedPin ?? this.confirmedPin,
      placeId: placeId ?? this.placeId,
    );
  }
}

/// Coverage eligibility response matching CoverageCheckResponse schema.
class CoverageCheckResponse {
  final bool eligible;
  final String resultCode; // ELIGIBLE, OUTSIDE_ACTIVE_ZONE, LOCATION_UNCERTAIN, NO_ACTIVE_ZONE, INVALID_LOCATION
  final String? zoneId;
  final int? zoneVersion;
  final String nextAction; // none, refresh_location, confirm_pin, submit_expansion_request
  final DateTime checkedAt;

  const CoverageCheckResponse({
    required this.eligible,
    required this.resultCode,
    this.zoneId,
    this.zoneVersion,
    required this.nextAction,
    required this.checkedAt,
  });

  bool get isEligible => eligible && resultCode == 'ELIGIBLE';
  bool get isUncertain => resultCode == 'LOCATION_UNCERTAIN';
  bool get isOutside => resultCode == 'OUTSIDE_ACTIVE_ZONE' || resultCode == 'NO_ACTIVE_ZONE';

  factory CoverageCheckResponse.fromJson(Map<String, dynamic> json) {
    return CoverageCheckResponse(
      eligible: (json['eligible'] as bool?) ?? false,
      resultCode: (json['result_code'] as String?) ?? 'UNKNOWN',
      zoneId: json['zone_id'] as String?,
      zoneVersion: json['zone_version'] as int?,
      nextAction: (json['next_action'] as String?) ?? 'none',
      checkedAt: json['checked_at'] != null
          ? DateTime.parse(json['checked_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}

/// Service expansion request model matching ExpansionRequest schema.
class ExpansionRequest {
  final LocationInput location;
  final String direction; // airport_arrival, airport_departure, both
  final String? requestedTimeWindow;
  final bool consent;

  const ExpansionRequest({
    required this.location,
    required this.direction,
    this.requestedTimeWindow,
    this.consent = true,
  });

  Map<String, dynamic> toJson() => {
        'location': location.toJson(),
        'direction': direction,
        'requested_time_window': requestedTimeWindow,
        'consent': consent,
      };
}
