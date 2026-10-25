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
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../booking/domain/booking_models.dart';

class TripHistoryScreen extends ConsumerStatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  ConsumerState<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends ConsumerState<TripHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Booking> _bookings = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.listUserBookings();

    if (!mounted) return;
    result.when(
      success: (list) {
        setState(() {
          _bookings = list.items;
          _isLoading = false;
        });
      },
      failure: (err) {
        setState(() {
          _errorMessage = err.message;
          _isLoading = false;
        });
      },
    );
  }

  List<Booking> _filterBookings(int tabIndex) {
    switch (tabIndex) {
      case 1: // Upcoming / Active
        return _bookings.where((b) => b.isRequested || b.isMatching || b.isConfirmed || b.isInProgress).toList();
      case 2: // Completed
        return _bookings.where((b) => b.isCompleted).toList();
      case 3: // Cancelled
        return _bookings.where((b) => b.isCancelled).toList();
      default:
        return _bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('My Airport Bookings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.brandTeal,
          labelColor: AppColors.surfaceWhite,
          unselectedLabelColor: AppColors.neutral300,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Done'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const AppLoadingView(message: 'Loading your booking history...')
            : _errorMessage != null
                ? AppErrorView(message: _errorMessage!, onRetry: _loadBookings)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingsList(_filterBookings(0)),
                      _buildBookingsList(_filterBookings(1)),
                      _buildBookingsList(_filterBookings(2)),
                      _buildBookingsList(_filterBookings(3)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> items) {
    if (items.isEmpty) {
      return AppEmptyView(
        title: 'No Bookings Found',
        message: 'You have no recorded airport journeys in this category.',
        actionLabel: 'Plan a Ride',
        onAction: () => context.go(RouteNames.home),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isArrival = item.direction == 'airport_arrival';

        return Card(
          child: InkWell(
            borderRadius: AppRadii.border12,
            onTap: () {
              if (item.isConfirmed || item.isInProgress) {
                context.push(RouteNames.activeTripPath(item.id));
              } else {
                context.push(RouteNames.matchingPath(item.id));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isArrival ? Icons.flight_land_rounded : Icons.flight_takeoff_rounded,
                            color: isArrival ? AppColors.brandNavy : AppColors.brandTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isArrival ? 'CSMIA Arrival' : 'CSMIA Departure',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.neutral900),
                          ),
                        ],
                      ),
                      AppStatusBadge(
                        label: item.status.replaceAll('_', ' '),
                        variant: item.isConfirmed || item.isCompleted
                            ? BadgeVariant.success
                            : item.isCancelled
                                ? BadgeVariant.error
                                : BadgeVariant.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    DateFormat('EEE, dd MMM yyyy • hh:mm a').format(item.requestedTime.toLocal()),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  const Divider(color: AppColors.neutral200),
                  const SizedBox(height: AppSpacing.space8),

                  Row(
                    children: [
                      const Icon(Icons.circle, color: AppColors.brandNavy, size: 8),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          item.origin.placeId ?? 'Origin Pin (${item.origin.coordinates.latitude.toStringAsFixed(2)})',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.brandTeal, size: 10),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          item.destination.placeId ??
                              'Destination Pin (${item.destination.coordinates.latitude.toStringAsFixed(2)})',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
