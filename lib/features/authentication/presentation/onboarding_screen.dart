import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/widgets/app_primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<({String title, String description, IconData icon})> _pages = const [
    (
      title: 'Airport-First Mobility',
      description:
          'Purpose-built for Greater Mumbai and CSMIA Terminals 1 & 2. Predictable pickups at Level P4 without curbside congestion.',
      icon: Icons.connecting_airports_rounded,
    ),
    (
      title: 'Segment-Wise Fare Splitting',
      description:
          'Transparent distance-based pooling. You share the cost of road segments travelled together and never pay for co-passenger detours.',
      icon: Icons.payments_outlined,
    ),
    (
      title: 'Verified Safety & Deadlines',
      description:
          'Strict departure buffer constraints protect your flight check-in deadline. Monitored 24/7 with immediate in-trip emergency escalation.',
      icon: Icons.verified_user_outlined,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(preferenceServiceProvider);
    await prefs.setOnboardingSeen(true);
    if (!mounted) return;
    context.go(RouteNames.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: AppTypography.labelLarge.copyWith(color: AppColors.brandNavy),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: AppColors.brandNavy,
                            borderRadius: AppRadii.border24,
                          ),
                          child: Icon(item.icon, size: 54, color: AppColors.brandAmber),
                        ),
                        const SizedBox(height: AppSpacing.space32),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge.copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.neutral700),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.brandTeal : AppColors.neutral300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space32),
              AppPrimaryButton(
                label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
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
