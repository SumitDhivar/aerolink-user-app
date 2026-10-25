/// Itinerary stop representation matching OpenAPI TripStopSchema.
class TripStop {
  final String stopId;
  final int sequence;
  final String type; // pickup, dropoff, airport
  final String label;
  final String status; // pending, arrived, completed, skipped
  final DateTime estimatedTime;
  final DateTime? actualTime;

  const TripStop({
    required this.stopId,
    required this.sequence,
    required this.type,
    required this.label,
    required this.status,
    required this.estimatedTime,
    this.actualTime,
  });

  bool get isCompleted => status == 'completed';
  bool get isArrived => status == 'arrived';
  bool get isPending => status == 'pending';

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      stopId: json['stop_id'] as String,
      sequence: json['sequence'] as int,
      type: json['type'] as String,
      label: json['label'] as String,
      status: (json['status'] as String?) ?? 'pending',
      estimatedTime: DateTime.parse(json['estimated_time'] as String),
      actualTime: json['actual_time'] != null
          ? DateTime.tryParse(json['actual_time'] as String)
          : null,
    );
  }
}

/// Trip detail representation conforming to OpenAPI TripSchema.
class Trip {
  final String id;
  final String status; // scheduled, dispatched, driver_en_route, arrived_pickup, in_progress, completed, cancelled, safety_hold
  final String direction; // airport_arrival, airport_departure
  final List<TripStop> stops;
  final String? driverId;
  final String? vehicleId;
  final Map<String, dynamic> routeSummary;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Trip({
    required this.id,
    required this.status,
    required this.direction,
    required this.stops,
    this.driverId,
    this.vehicleId,
    this.routeSummary = const {},
    this.startedAt,
    this.completedAt,
  });

  bool get isActive =>
      status == 'dispatched' ||
      status == 'driver_en_route' ||
      status == 'arrived_pickup' ||
      status == 'in_progress';

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isSafetyHold => status == 'safety_hold';

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      status: (json['status'] as String?) ?? 'scheduled',
      direction: json['direction'] as String,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => TripStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      driverId: json['driver_id'] as String?,
      vehicleId: json['vehicle_id'] as String?,
      routeSummary: (json['route_summary'] as Map<String, dynamic>?) ?? const {},
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }
}
