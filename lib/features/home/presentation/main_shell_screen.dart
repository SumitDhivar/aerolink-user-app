import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RouteNames.home)) return 0;
    if (location.startsWith(RouteNames.trips)) return 1;
    if (location.startsWith(RouteNames.safety)) return 2;
    if (location.startsWith(RouteNames.profile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.trips);
        break;
      case 2:
        context.go(RouteNames.safety);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        backgroundColor: AppColors.surfaceWhite,
        indicatorColor: AppColors.brandTeal.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.airport_shuttle_outlined),
            selectedIcon: Icon(Icons.airport_shuttle_rounded, color: AppColors.brandTeal),
            label: 'Ride',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.brandTeal),
            label: 'My Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety_rounded, color: AppColors.brandTeal),
            label: 'Safety',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.brandTeal),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
