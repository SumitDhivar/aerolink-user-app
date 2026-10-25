/// Application runtime configuration.
class AppConfig {
  AppConfig._();

  static const String appName = 'AeroLink';
  static const String appVersion = '1.0.0-pilot';

  /// Base API URL for FastAPI backend.
  /// Overridable via `--dart-define=API_BASE_URL=...`
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 20000;

  // CSMIA Geolocation reference constants
  static const String initialAirportCode = 'BOM';
  static const String initialAirportName =
      'Chhatrapati Shivaji Maharaj International Airport (CSMIA)';

  // Terminal 2 P4 Pickup Coordinates
  static const double csmiaT2Lat = 19.0886;
  static const double csmiaT2Lng = 72.8680;

  // Terminal 1 Pickup Coordinates
  static const double csmiaT1Lat = 19.0968;
  static const double csmiaT1Lng = 72.8526;
}
