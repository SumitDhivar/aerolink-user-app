import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../domain/booking_models.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const MatchingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  Timer? _pollingTimer;
  Booking? _booking;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBooking();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchBooking());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBooking() async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getBooking(widget.bookingId);
    if (!mounted) return;

    result.when(
      success: (b) {
        setState(() {
          _booking = b;
          _isLoading = false;
        });

        if (b.isCancelled || b.isCompleted) {
          _pollingTimer?.cancel();
        }
      },
      failure: (err) {
        setState(() {
          _errorMessage = err.message;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _cancelBooking() async {
    final reasonController = TextEditingController(text: 'Changed travel plans');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.border16),
        title: const Text('Cancel Booking Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this booking? If a driver has already been dispatched, cancellation terms apply.',
            ),
            const SizedBox(height: AppSpacing.space16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.executeAction(
      bookingId: widget.bookingId,
      action: 'cancel',
      reason: reasonController.text.trim(),
    );

    if (!mounted) return;
    result.when(
      success: (updated) {
        setState(() => _booking = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request cancelled.')),
        );
      },
      failure: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Ride Matching Status'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const AppLoadingView(message: 'Connecting to ride matching engine...')
            : _errorMessage != null
                ? AppErrorView(message: _errorMessage!, onRetry: _fetchBooking)
                : _booking == null
                    ? const Center(child: Text('Booking not found'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.space24),
                        child: Column(
                          children: [
                            // Radar Scan / Pool Graphic
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: _booking!.isCancelled
                                    ? AppColors.neutral200
                                    : AppColors.brandNavy.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _booking!.isCancelled
                                    ? Icons.cancel_outlined
                                    : _booking!.isDriverAssigned || _booking!.isConfirmed
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.radar_rounded,
                                size: 54,
                                color: _booking!.isCancelled
                                    ? AppColors.neutral600
                                    : AppColors.brandNavy,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space20),

                            Text(
                              _booking!.isCancelled
                                  ? 'Booking Cancelled'
                                  : _booking!.isDriverAssigned || _booking!.isConfirmed
                                      ? 'Ride Match Confirmed!'
                                      : 'Finding Compatible Co-Riders...',
                              textAlign: TextAlign.center,
                              style: AppTypography.titleLarge.copyWith(color: AppColors.neutral900),
                            ),
                            const SizedBox(height: AppSpacing.space8),
                            Text(
                              'Booking Reference: #${_booking!.id.substring(0, 8).toUpperCase()}',
                              style: AppTypography.labelMedium.copyWith(color: AppColors.neutral600),
                            ),
                            const SizedBox(height: AppSpacing.space16),

                            AppStatusBadge(
                              label: _booking!.status.replaceAll('_', ' '),
                              variant: _booking!.isCancelled
                                  ? BadgeVariant.error
                                  : _booking!.isConfirmed || _booking!.isDriverAssigned
                                      ? BadgeVariant.success
                                      : BadgeVariant.info,
                            ),
                            const SizedBox(height: AppSpacing.space32),

                            // Lifecycle Steps Card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.space16),
                                child: Column(
                                  children: [
                                    _buildTimelineStep(
                                      title: 'Booking Intent Created',
                                      subtitle: 'Verified active zone parameters snapshot recorded',
                                      isDone: true,
                                    ),
                                    const Divider(color: AppColors.neutral200),
                                    _buildTimelineStep(
                                      title: 'Corridor Optimization Scan',
                                      subtitle: 'Grouping compatible routes within Mumbai pilot corridor',
                                      isDone: _booking!.isMatching ||
                                          _booking!.isMatched ||
                                          _booking!.isConfirmed ||
                                          _booking!.isDriverAssigned,
                                      isActive: _booking!.isMatching,
                                    ),
                                    const Divider(color: AppColors.neutral200),
                                    _buildTimelineStep(
                                      title: 'Driver & Vehicle Assignment',
                                      subtitle: 'Allocating verified commercial airport vehicle',
                                      isDone: _booking!.isDriverAssigned || _booking!.isConfirmed,
                                      isActive: _booking!.isMatched,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space32),

                            if (!_booking!.isCancelled) ...[
                              if (_booking!.isConfirmed || _booking!.isDriverAssigned) ...[
                                AppPrimaryButton(
                                  label: 'View Trip Itinerary & Tracking',
                                  icon: const Icon(Icons.navigation_rounded, size: 20),
                                  onPressed: () {
                                    context.push(RouteNames.activeTripPath(_booking!.id));
                                  },
                                ),
                                const SizedBox(height: AppSpacing.space12),
                              ],
                              AppSecondaryButton(
                                label: 'Cancel Booking',
                                isOutlined: true,
                                onPressed: _cancelBooking,
                              ),
                            ] else ...[
                              AppPrimaryButton(
                                label: 'Return to Home',
                                onPressed: () => context.go(RouteNames.home),
                              ),
                            ],
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isDone,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : isActive
                    ? Icons.timelapse_rounded
                    : Icons.radio_button_unchecked_rounded,
            color: isDone
                ? AppColors.success
                : isActive
                    ? AppColors.brandTeal
                    : AppColors.neutral400,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: isDone || isActive ? AppColors.neutral900 : AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
