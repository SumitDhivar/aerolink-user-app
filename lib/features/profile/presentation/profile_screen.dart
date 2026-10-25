import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../authentication/presentation/auth_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _preferredLanguage = 'English';
  bool _smsUpdates = true;
  bool _flightAlerts = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Passenger Profile & Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Identification Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.brandNavy,
                        child: Text(
                          user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'P',
                          style: AppTypography.titleLarge.copyWith(color: AppColors.surfaceWhite),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Passenger',
                              style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Account Status: ${user?.accountStatus ?? "Active"}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                            ),
                            const SizedBox(height: 6),
                            AppStatusBadge(
                              label: user?.verificationStatus ?? 'Not Started',
                              variant: user?.isVerified == true ? BadgeVariant.success : BadgeVariant.info,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Verification Context Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_user_rounded, color: AppColors.brandTeal, size: 22),
                          SizedBox(width: AppSpacing.space8),
                          Text(
                            'Identity & Verification',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Text(
                        'Verified passengers receive priority pool matching and advance airport booking privileges. Document verification is audited per regulatory guidelines.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Preferences Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('App Preferences', style: AppTypography.titleSmall),
                      const SizedBox(height: AppSpacing.space12),

                      DropdownButtonFormField<String>(
                        initialValue: _preferredLanguage,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Language',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'English', child: Text('English')),
                          DropdownMenuItem(value: 'Hindi', child: Text('Hindi (हिन्दी)')),
                          DropdownMenuItem(value: 'Marathi', child: Text('Marathi (मराठी)')),
                        ],
                        onChanged: (v) => setState(() => _preferredLanguage = v!),
                      ),
                      const SizedBox(height: AppSpacing.space16),

                      SwitchListTile(
                        title: const Text('SMS Trip Notifications'),
                        subtitle: const Text('Driver arrival alerts and pickup OTP'),
                        value: _smsUpdates,
                        activeTrackColor: AppColors.brandTeal,
                        onChanged: (v) => setState(() => _smsUpdates = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(color: AppColors.neutral200),
                      SwitchListTile(
                        title: const Text('Automated Flight Alerts'),
                        subtitle: const Text('Terminal gate changes & landing delay recalculations'),
                        value: _flightAlerts,
                        activeTrackColor: AppColors.brandTeal,
                        onChanged: (v) => setState(() => _flightAlerts = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),

              // Sign Out Button
              AppPrimaryButton(
                label: 'Sign Out',
                backgroundColor: AppColors.neutral800,
                icon: const Icon(Icons.logout_rounded, size: 20),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(RouteNames.auth);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
