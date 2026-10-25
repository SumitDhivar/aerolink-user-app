import '../../../core/network/api_client.dart';
import '../domain/booking_models.dart';
import '../domain/fare_quote_models.dart';

class BookingApiService {
  final ApiClient _apiClient;

  BookingApiService(this._apiClient);

  Future<FareQuote> requestFareQuote(FareQuoteRequest request) async {
    final response = await _apiClient.dio.post(
      '/fare-quotes',
      data: request.toJson(),
    );
    return FareQuote.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Booking> createBooking(BookingCreateRequest request) async {
    final response = await _apiClient.dio.post(
      '/bookings',
      data: request.toJson(),
    );
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Booking> getBooking(String bookingId) async {
    final response = await _apiClient.dio.get('/bookings/$bookingId');
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingList> listBookings({int limit = 20, String? cursor}) async {
    final response = await _apiClient.dio.get(
      '/bookings',
      queryParameters: {
        'limit': limit,
        'cursor': ?cursor,
      },
    );
    return BookingList.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> requestMatching(String bookingId) async {
    await _apiClient.dio.post('/bookings/$bookingId/match');
  }

  Future<Booking> executeBookingAction({
    required String bookingId,
    required String action,
    required String reason,
  }) async {
    final response = await _apiClient.dio.post(
      '/bookings/$bookingId/actions',
      data: {
        'action': action,
        'reason': reason,
      },
    );
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }
}
