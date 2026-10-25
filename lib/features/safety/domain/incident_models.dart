/// Incident creation payload matching OpenAPI IncidentCreateRequest schema.
class IncidentCreateRequest {
  final String category; // safety, legal, payment, driver, passenger, route, privacy, security, operational, other
  final String description;
  final String source; // passenger
  final String? bookingId;
  final String? tripId;
  final String severity; // critical, high, medium, low

  const IncidentCreateRequest({
    required this.category,
    required this.description,
    this.source = 'passenger',
    this.bookingId,
    this.tripId,
    this.severity = 'medium',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'category': category,
      'description': description,
      'source': source,
      'severity': severity,
    };
    if (bookingId != null) map['booking_id'] = bookingId;
    if (tripId != null) map['trip_id'] = tripId;
    return map;
  }
}

/// Incident response representation matching OpenAPI Incident schema.
class IncidentResponse {
  final String id;
  final String category;
  final String description;
  final String source;
  final String severity;
  final String status;
  final String? bookingId;
  final String? tripId;
  final DateTime createdAt;

  const IncidentResponse({
    required this.id,
    required this.category,
    required this.description,
    required this.source,
    required this.severity,
    required this.status,
    this.bookingId,
    this.tripId,
    required this.createdAt,
  });

  bool get isCritical => severity == 'critical';

  factory IncidentResponse.fromJson(Map<String, dynamic> json) {
    return IncidentResponse(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      source: (json['source'] as String?) ?? 'passenger',
      severity: (json['severity'] as String?) ?? 'medium',
      status: (json['status'] as String?) ?? 'detected',
      bookingId: json['booking_id'] as String?,
      tripId: json['trip_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
