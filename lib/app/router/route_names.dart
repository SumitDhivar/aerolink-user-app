/// Route path and name constants.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  // Shell tabs
  static const String home = '/home';
  static const String trips = '/trips';
  static const String safety = '/safety';
  static const String profile = '/profile';

  // Booking & Journey Subroutes
  static const String planRide = '/plan-ride';
  static const String locationPicker = '/location-picker';
  static const String flightSearch = '/flight-search';
  static const String journeyReview = '/journey-review';
  static const String matching = '/matching/:bookingId';
  static const String activeTrip = '/active-trip/:tripId';
  static const String liveTracking = '/live-tracking/:tripId';
  static const String payment = '/payment/:paymentId';
  static const String expansionRequest = '/expansion-request';

  static String matchingPath(String bookingId) => '/matching/$bookingId';
  static String activeTripPath(String tripId) => '/active-trip/$tripId';
  static String liveTrackingPath(String tripId) => '/live-tracking/$tripId';
  static String paymentPath(String paymentId) => '/payment/$paymentId';
}
