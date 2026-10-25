import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_status_badge.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final String tripId;

  const LiveTrackingScreen({super.key, required this.tripId});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;

  // Waypoints connecting CSMIA T2 to Powai
  final List<LatLng> _routePoints = const [
    LatLng(AppConfig.csmiaT2Lat, AppConfig.csmiaT2Lng), // CSMIA T2
    LatLng(19.0980, 72.8750), // Sahar Elevated Access
    LatLng(19.1080, 72.8880), // Western Express / JVLR junction
    LatLng(19.1140, 72.8980), // JVLR near Powai Lake
    LatLng(19.1176, 72.9060), // Powai Hiranandani
  ];

  late LatLng _driverPosition;
  int _currentWaypointIndex = 0;
  Timer? _movementTimer;
  DateTime _lastTelemetryUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _driverPosition = _routePoints.first;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Simulate smooth movement between route nodes
    _movementTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _currentWaypointIndex = (_currentWaypointIndex + 1) % _routePoints.length;
        _driverPosition = _routePoints[_currentWaypointIndex];
        _lastTelemetryUpdate = DateTime.now();
      });
      _mapController.move(_driverPosition, 13.5);
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondsAgo = DateTime.now().difference(_lastTelemetryUpdate).inSeconds;
    final isStale = secondsAgo > 30;

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sos_rounded, color: AppColors.error),
            onPressed: () => context.push(RouteNames.safety),
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap Vector / Raster Tile Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _driverPosition,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aerolink.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: AppColors.brandNavy,
                    strokeWidth: 4.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // CSMIA T2 Airport Pickup Marker
                  Marker(
                    point: _routePoints.first,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.brandNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 22),
                    ),
                  ),
                  // Destination Marker
                  Marker(
                    point: _routePoints.last,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.brandTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  // Animated Driver Marker
                  Marker(
                    point: _driverPosition,
                    width: 50,
                    height: 50,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_animationController.value * 0.15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.brandAmber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.directions_car_rounded, color: AppColors.neutral900, size: 28),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Floating Top Status Card (ETA & Telematics Freshness)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: Card(
                color: AppColors.surfaceWhite.withValues(alpha: 0.95),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        decoration: const BoxDecoration(
                          color: AppColors.brandNavy,
                          borderRadius: AppRadii.border8,
                        ),
                        child: const Icon(Icons.timer_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Driver Arriving in 6 mins',
                              style: AppTypography.titleSmall.copyWith(color: AppColors.neutral900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isStale
                                  ? 'GPS delayed. Showing last known signal.'
                                  : 'Live route progress (FastAPI verified)',
                              style: AppTypography.bodySmall.copyWith(
                                color: isStale ? AppColors.warning : AppColors.brandTealDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppStatusBadge(
                        label: isStale ? 'Stale' : 'Live',
                        variant: isStale ? BadgeVariant.warning : BadgeVariant.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadii.sheetTop24,
                boxShadow: [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Maruti Ertiga XL6', style: AppTypography.titleSmall),
                            Text('MH 02 EE 4920', style: AppTypography.labelLarge.copyWith(color: AppColors.brandNavy)),
                          ],
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                          label: const Text('Call Driver'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Connecting to masked number proxy...')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppPrimaryButton(
                      label: 'Complete Trip & View Receipt',
                      onPressed: () {
                        context.push(RouteNames.paymentPath(widget.tripId));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
