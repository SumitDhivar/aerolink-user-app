/// Flight status context matching OpenAPI FlightStatus schema.
class FlightStatus {
  final String flightNumber;
  final String flightDate;
  final String status; // scheduled, active, landed, cancelled, incident, diverted, unknown, unavailable
  final DateTime? estimatedDeparture;
  final DateTime? estimatedArrival;
  final String? terminal;
  final String? gate;
  final String freshness; // live, cached, stale, unavailable
  final String source; // provider, default, unverified_manual

  const FlightStatus({
    required this.flightNumber,
    required this.flightDate,
    required this.status,
    this.estimatedDeparture,
    this.estimatedArrival,
    this.terminal,
    this.gate,
    required this.freshness,
    required this.source,
  });

  bool get isAvailable => status != 'unavailable' && status != 'unknown';
  bool get isStale => freshness == 'stale';

  factory FlightStatus.fromJson(Map<String, dynamic> json) {
    return FlightStatus(
      flightNumber: json['flight_number'] as String,
      flightDate: json['flight_date'] as String,
      status: (json['status'] as String?) ?? 'unknown',
      estimatedDeparture: json['estimated_departure'] != null
          ? DateTime.tryParse(json['estimated_departure'] as String)
          : null,
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.tryParse(json['estimated_arrival'] as String)
          : null,
      terminal: json['terminal'] as String?,
      gate: json['gate'] as String?,
      freshness: (json['freshness'] as String?) ?? 'unavailable',
      source: (json['source'] as String?) ?? 'provider',
    );
  }
}
