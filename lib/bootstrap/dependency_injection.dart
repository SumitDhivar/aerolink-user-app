import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/preference_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/authentication/data/auth_api_service.dart';
import '../features/authentication/data/auth_repository_impl.dart';
import '../features/authentication/domain/auth_repository.dart';
import '../features/booking/data/booking_api_service.dart';
import '../features/booking/data/booking_repository_impl.dart';
import '../features/booking/domain/booking_repository.dart';
import '../features/coverage/data/coverage_api_service.dart';
import '../features/coverage/data/coverage_repository_impl.dart';
import '../features/coverage/domain/coverage_repository.dart';
import '../features/flight/data/flight_api_service.dart';
import '../features/flight/data/flight_repository_impl.dart';
import '../features/flight/domain/flight_repository.dart';
import '../features/payments/data/payment_api_service.dart';
import '../features/payments/data/payment_repository_impl.dart';
import '../features/payments/domain/payment_repository.dart';
import '../features/safety/data/incident_api_service.dart';
import '../features/safety/data/incident_repository_impl.dart';
import '../features/safety/domain/incident_repository.dart';
import '../features/trips/data/trip_api_service.dart';
import '../features/trips/data/trip_repository_impl.dart';
import '../features/trips/domain/trip_repository.dart';

// Storage Providers
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final preferenceServiceProvider = Provider<PreferenceService>((ref) {
  throw UnimplementedError('preferenceServiceProvider must be initialized in bootstrap');
});

// Network Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(
    secureStorage: secureStorage,
    onSessionExpired: () {
      // Session invalidation listener
    },
  );
});

// Authentication Providers
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiService(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    apiService: apiService,
    apiClient: apiClient,
    secureStorage: secureStorage,
  );
});

// Coverage Providers
final coverageApiServiceProvider = Provider<CoverageApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CoverageApiService(apiClient);
});

final coverageRepositoryProvider = Provider<CoverageRepository>((ref) {
  final apiService = ref.watch(coverageApiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return CoverageRepositoryImpl(
    apiService: apiService,
    apiClient: apiClient,
  );
});

// Flight Providers
final flightApiServiceProvider = Provider<FlightApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FlightApiService(apiClient);
});

final flightRepositoryProvider = Provider<FlightRepository>((ref) {
  final apiService = ref.watch(flightApiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return FlightRepositoryImpl(
    apiService: apiService,
    apiClient: apiClient,
  );
});

// Booking Providers
final bookingApiServiceProvider = Provider<BookingApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingApiService(apiClient);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiService = ref.watch(bookingApiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepositoryImpl(
    apiService: apiService,
    apiClient: apiClient,
  );
});

// Trip Providers
final tripApiServiceProvider = Provider<TripApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TripApiService(apiClient);
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final apiService = ref.watch(tripApiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return TripRepositoryImpl(
    apiService: apiService,
    apiClient: apiClient,
  );
});

// Payment Providers
final paymentApiServiceProvider = Provider<PaymentApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentApiService(apiClient);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiService = ref.watch(paymentApiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRepositoryImpl(
    apiService: apiService,
    apiClient: apiClient,
  );
});

// Safety Providers
final incidentApiServiceProvider = Provider<IncidentApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return IncidentApiService(apiClient);
});

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  final apiService = ref.watch(incidentApiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return IncidentRepositoryImpl(
    apiService: apiService,
    apiClient: apiClient,
  );
});
