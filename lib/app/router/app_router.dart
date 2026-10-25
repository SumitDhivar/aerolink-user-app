import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/auth_screen.dart';
import '../../features/authentication/presentation/onboarding_screen.dart';
import '../../features/authentication/presentation/splash_screen.dart';
import '../../features/booking/presentation/journey_review_screen.dart';
import '../../features/booking/presentation/matching_screen.dart';
import '../../features/coverage/presentation/expansion_request_screen.dart';
import '../../features/coverage/presentation/location_picker_screen.dart';
import '../../features/flight/presentation/flight_search_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/main_shell_screen.dart';
import '../../features/home/presentation/plan_ride_screen.dart';
import '../../features/payments/presentation/payment_status_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/safety/presentation/safety_support_screen.dart';
import '../../features/trips/presentation/active_trip_screen.dart';
import '../../features/trips/presentation/live_tracking_screen.dart';
import '../../features/trips/presentation/trip_history_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),

      // Shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.trips,
            builder: (context, state) => const TripHistoryScreen(),
          ),
          GoRoute(
            path: RouteNames.safety,
            builder: (context, state) => const SafetySupportScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Focused subroutes outside shell
      GoRoute(
        path: RouteNames.planRide,
        builder: (context, state) {
          final direction = state.uri.queryParameters['direction'] ?? 'airport_arrival';
          return PlanRideScreen(initialDirection: direction);
        },
      ),
      GoRoute(
        path: RouteNames.locationPicker,
        builder: (context, state) {
          final direction = state.uri.queryParameters['direction'] ?? 'airport_arrival';
          final terminal = state.uri.queryParameters['terminal'] ?? 'T2';
          final mode = state.uri.queryParameters['mode'] ?? 'on_demand';
          return LocationPickerScreen(
            direction: direction,
            terminal: terminal,
            bookingMode: mode,
          );
        },
      ),
      GoRoute(
        path: RouteNames.expansionRequest,
        builder: (context, state) {
          final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '19.1176') ?? 19.1176;
          final lng = double.tryParse(state.uri.queryParameters['lng'] ?? '72.9060') ?? 72.9060;
          final direction = state.uri.queryParameters['direction'] ?? 'airport_arrival';
          final label = state.uri.queryParameters['label'] ?? 'Unknown Area';
          return ExpansionRequestScreen(
            latitude: lat,
            longitude: lng,
            direction: direction,
            label: label,
          );
        },
      ),
      GoRoute(
        path: RouteNames.flightSearch,
        builder: (context, state) {
          final direction = state.uri.queryParameters['direction'] ?? 'airport_arrival';
          final terminal = state.uri.queryParameters['terminal'] ?? 'T2';
          final mode = state.uri.queryParameters['mode'] ?? 'on_demand';
          final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '19.1176') ?? 19.1176;
          final lng = double.tryParse(state.uri.queryParameters['lng'] ?? '72.9060') ?? 72.9060;
          final label = state.uri.queryParameters['label'] ?? 'Destination';
          return FlightSearchScreen(
            direction: direction,
            terminal: terminal,
            mode: mode,
            lat: lat,
            lng: lng,
            label: label,
          );
        },
      ),
      GoRoute(
        path: RouteNames.journeyReview,
        builder: (context, state) {
          final direction = state.uri.queryParameters['direction'] ?? 'airport_arrival';
          final terminal = state.uri.queryParameters['terminal'] ?? 'T2';
          final mode = state.uri.queryParameters['mode'] ?? 'on_demand';
          final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '19.1176') ?? 19.1176;
          final lng = double.tryParse(state.uri.queryParameters['lng'] ?? '72.9060') ?? 72.9060;
          final label = state.uri.queryParameters['label'] ?? 'Destination';
          final flight = state.uri.queryParameters['flight'];
          final flightDate = state.uri.queryParameters['flightDate'];

          return JourneyReviewScreen(
            direction: direction,
            terminal: terminal,
            mode: mode,
            lat: lat,
            lng: lng,
            label: label,
            flight: flight,
            flightDate: flightDate,
          );
        },
      ),
      GoRoute(
        path: RouteNames.matching,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return MatchingScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RouteNames.activeTrip,
        builder: (context, state) {
          final tripId = state.pathParameters['tripId'] ?? '';
          return ActiveTripScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: RouteNames.liveTracking,
        builder: (context, state) {
          final tripId = state.pathParameters['tripId'] ?? '';
          return LiveTrackingScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: RouteNames.payment,
        builder: (context, state) {
          final paymentId = state.pathParameters['paymentId'] ?? '';
          return PaymentStatusScreen(paymentId: paymentId);
        },
      ),
    ],
  );
});
