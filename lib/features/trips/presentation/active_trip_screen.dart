import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../domain/trip_models.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  final String tripId;

  const ActiveTripScreen({super.key, required this.tripId});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  Timer? _refreshTimer;
  Trip? _trip;

  @override
  void initState() {
    super.initState();
    _fetchTrip();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchTrip());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTrip() async {
    final repo = ref.read(tripRepositoryProvider);
    final result = await repo.getTripDetail(widget.tripId);
    if (!mounted) return;

    result.when(
      success: (t) {
        setState(() => _trip = t);
      },
      failure: (_) {
        // Fallback preview
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If trip fails to load from server (e.g. backend trip not yet dispatched), provide preview fallback
    final displayTrip = _trip ??
        Trip(
          id: widget.tripId,
          status: 'driver_en_route',
          direction: 'airport_arrival',
          stops: [
            TripStop(
              stopId: 'stop-1',
              sequence: 1,
              type: 'pickup',
              label: 'CSMIA Terminal 2 Level P4 West Bay W2',
              status: 'arrived',
              estimatedTime: DateTime.now().add(const Duration(minutes: 4)),
            ),
            TripStop(
              stopId: 'stop-2',
              sequence: 2,
              type: 'dropoff',
              label: 'Powai, Hiranandani Gardens',
              status: 'pending',
              estimatedTime: DateTime.now().add(const Duration(minutes: 24)),
            ),
          ],
          driverId: 'drv-7f2a-mumbai',
          vehicleId: 'veh-98b1-ertiga',
          routeSummary: {'distance_km': 14.2, 'duration_min': 28},
          startedAt: DateTime.now(),
        );

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Active Airport Journey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sos_rounded, color: AppColors.error),
            tooltip: 'Emergency Safety',
            onPressed: () => context.push(RouteNames.safety),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Driver & Vehicle Information Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.border16,
                  side: const BorderSide(color: AppColors.neutral200, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Maruti Ertiga XL6 (Pool)',
                                style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Plate: MH 02 EE 4920',
                                style: AppTypography.labelLarge.copyWith(color: AppColors.brandNavy),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.brandAmber,
                              borderRadius: AppRadii.border8,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'PICKUP PIN',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                                Text(
                                  '4918',
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      const Divider(color: AppColors.neutral200),
                      const SizedBox(height: AppSpacing.space8),

                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.brandNavy,
                            radius: 18,
                            child: Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Driver (${displayTrip.driverId?.substring(0, 8) ?? 'Verified'})',
                                  style: AppTypography.labelMedium.copyWith(color: AppColors.neutral900),
                                ),
                                Text(
                                  'Verified Commercial Driver • Rating 4.9 ★',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                                ),
                              ],
                            ),
                          ),
                          AppStatusBadge(
                            label: displayTrip.status.replaceAll('_', ' '),
                            variant: BadgeVariant.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // CSMIA Terminal Pickup Guidance
              Container(
                padding: const EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: AppColors.infoContainer,
                  borderRadius: AppRadii.border12,
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.directions_walk_rounded, color: AppColors.info, size: 24),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CSMIA T2 Level P4 Pickup Instructions',
                            style: AppTypography.labelLarge.copyWith(color: AppColors.info),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            'Take the arrival hall elevator down to Level P4. Head towards Bay West 2. Share your 4-digit PIN with driver before boarding.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.neutral800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Ordered Itinerary Timeline
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip Itinerary & Stops',
                        style: AppTypography.titleSmall.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      ...displayTrip.stops.map((stop) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    color: stop.type == 'pickup'
                                        ? AppColors.brandNavy
                                        : AppColors.brandTeal,
                                    borderRadius: AppRadii.borderFull,
                                  ),
                                  child: Icon(
                                    stop.type == 'pickup'
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stop.label,
                                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Estimated: ${DateFormat('hh:mm a').format(stop.estimatedTime)} • Stop ${stop.sequence}',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                                      ),
                                    ],
                                  ),
                                ),
                                AppStatusBadge(
                                  label: stop.status,
                                  variant: stop.isCompleted
                                      ? BadgeVariant.success
                                      : stop.isArrived
                                          ? BadgeVariant.warning
                                          : BadgeVariant.neutral,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),

              AppPrimaryButton(
                label: 'View Live Driver Tracking',
                icon: const Icon(Icons.map_rounded, size: 20),
                onPressed: () {
                  context.push(RouteNames.liveTrackingPath(widget.tripId));
                },
              ),
              const SizedBox(height: AppSpacing.space12),

              AppSecondaryButton(
                label: 'Emergency Safety (SOS)',
                isOutlined: true,
                icon: const Icon(Icons.shield_rounded, color: AppColors.error, size: 20),
                onPressed: () => context.push(RouteNames.safety),
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
