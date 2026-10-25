import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/booking_models.dart';
import '../domain/booking_repository.dart';
import '../domain/fare_quote_models.dart';
import 'booking_api_service.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingApiService apiService;
  final ApiClient apiClient;

  BookingRepositoryImpl({
    required this.apiService,
    required this.apiClient,
  });

  @override
  Future<ApiResult<FareQuote>> requestFareQuote(FareQuoteRequest request) async {
    try {
      final quote = await apiService.requestFareQuote(request);
      return Success(quote);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/fare-quotes'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<Booking>> createBooking(BookingCreateRequest request) async {
    try {
      final booking = await apiService.createBooking(request);
      return Success(booking);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/bookings'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<Booking>> getBooking(String bookingId) async {
    try {
      final booking = await apiService.getBooking(bookingId);
      return Success(booking);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/bookings/$bookingId'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<BookingList>> listUserBookings({int limit = 20, String? cursor}) async {
    try {
      final list = await apiService.listBookings(limit: limit, cursor: cursor);
      return Success(list);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/bookings'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<void>> requestMatching(String bookingId) async {
    try {
      await apiService.requestMatching(bookingId);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/bookings/$bookingId/match'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<Booking>> executeAction({
    required String bookingId,
    required String action,
    required String reason,
  }) async {
    try {
      final updated = await apiService.executeBookingAction(
        bookingId: bookingId,
        action: action,
        reason: reason,
      );
      return Success(updated);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/bookings/$bookingId/actions'), error: e),
      ));
    }
  }
}
