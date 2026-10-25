import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initialize());
  }

  Future<void> _initialize() async {
    final prefs = ref.read(preferenceServiceProvider);
    final authController = ref.read(authControllerProvider.notifier);

    // Verify session
    await authController.checkAuthStatus();

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState is Authenticated) {
      context.go(RouteNames.home);
    } else {
      if (!prefs.isOnboardingSeen) {
        context.go(RouteNames.onboarding);
      } else {
        context.go(RouteNames.auth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.brandTeal,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppColors.surfaceWhite,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              Text(
                'AeroLink',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.surfaceWhite,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'CSMIA Mumbai • Ride Pooling Marketplace',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral300,
                ),
              ),
              const SizedBox(height: AppSpacing.space40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandTeal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
