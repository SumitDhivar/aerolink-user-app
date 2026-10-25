import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../authentication/presentation/auth_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;
    final displayName = user?.displayName ?? 'Passenger';

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: const BoxDecoration(
                color: AppColors.brandTeal,
                borderRadius: AppRadii.border4,
              ),
              child: const Icon(Icons.flight_takeoff_rounded, size: 20, color: AppColors.surfaceWhite),
            ),
            const SizedBox(width: AppSpacing.space8),
            const Text('AeroLink', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space16),
            child: Center(
              child: AppStatusBadge(
                label: user?.verificationStatus ?? 'Active',
                variant: user?.isVerified == true ? BadgeVariant.success : BadgeVariant.info,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting & Context Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.brandNavy,
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.surfaceWhite),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $displayName',
                              style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            Text(
                              'CSMIA Pilot Corridor Active',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.brandTealDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Main Airport Corridor Booking Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.border16,
                  side: const BorderSide(color: AppColors.neutral200, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space8),
                            decoration: const BoxDecoration(
                              color: AppColors.infoContainer,
                              borderRadius: AppRadii.border8,
                            ),
                            child: const Icon(
                              Icons.connecting_airports_rounded,
                              color: AppColors.brandNavy,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chhatrapati Shivaji Maharaj',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.neutral900,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'International Airport (CSMIA / BOM)',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space20),
                      const Divider(color: AppColors.neutral200, height: 1),
                      const SizedBox(height: AppSpacing.space16),

                      Text(
                        'Where are you travelling?',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral800),
                      ),
                      const SizedBox(height: AppSpacing.space12),

                      // Quick Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.space16,
                                  horizontal: AppSpacing.space12,
                                ),
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.border12),
                                side: const BorderSide(color: AppColors.brandNavy, width: 1.5),
                              ),
                              onPressed: () => context.push(
                                '${RouteNames.planRide}?direction=airport_arrival',
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.flight_land_rounded, color: AppColors.brandNavy, size: 28),
                                  const SizedBox(height: AppSpacing.space8),
                                  Text(
                                    'From Airport',
                                    style: AppTypography.labelLarge.copyWith(color: AppColors.brandNavy),
                                  ),
                                  Text(
                                    'Arrivals Pickup',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.space16,
                                  horizontal: AppSpacing.space12,
                                ),
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.border12),
                                side: const BorderSide(color: AppColors.brandTeal, width: 1.5),
                              ),
                              onPressed: () => context.push(
                                '${RouteNames.planRide}?direction=airport_departure',
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.flight_takeoff_rounded, color: AppColors.brandTeal, size: 28),
                                  const SizedBox(height: AppSpacing.space8),
                                  Text(
                                    'To Airport',
                                    style: AppTypography.labelLarge.copyWith(color: AppColors.brandTeal),
                                  ),
                                  Text(
                                    'Departures Drop',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space20),

                      AppPrimaryButton(
                        label: 'Plan Journey',
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        onPressed: () => context.push(RouteNames.planRide),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space20),

              // Candidate Pilot Corridors Section
              Text(
                'Pilot Corridor Areas',
                style: AppTypography.titleSmall.copyWith(color: AppColors.neutral800),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Service eligibility is validated against active versioned polygons.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: AppSpacing.space12),

              _buildCorridorTile(
                title: 'Powai / Eastern Suburbs',
                subtitle: 'Hiranandani, Chandivali, Kanjurmarg',
                context: context,
              ),
              const SizedBox(height: AppSpacing.space8),
              _buildCorridorTile(
                title: 'Andheri & Western Suburbs',
                subtitle: 'Andheri East, MIDC, Sahar Road',
                context: context,
              ),
              const SizedBox(height: AppSpacing.space8),
              _buildCorridorTile(
                title: 'Thane Urban Corridor',
                subtitle: 'Cadbury Junction, Ghodbunder Rd',
                context: context,
              ),
              const SizedBox(height: AppSpacing.space20),

              // Operational Transparency Notice
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppRadii.border8,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.neutral700, size: 20),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: Text(
                        'AeroLink operates only within approved CSMIA zones. Fares are calculated deterministically using segment-wise distance splitting.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorridorTile({
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.space8),
          decoration: const BoxDecoration(
            color: AppColors.infoContainer,
            borderRadius: AppRadii.border8,
          ),
          child: const Icon(Icons.location_on_outlined, color: AppColors.brandTeal, size: 22),
        ),
        title: Text(title, style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900)),
        subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.neutral500),
        onTap: () => context.push(RouteNames.planRide),
      ),
    );
  }
}
