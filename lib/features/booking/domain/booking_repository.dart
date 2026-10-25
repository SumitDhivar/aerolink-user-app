import '../../../core/network/api_result.dart';
import 'booking_models.dart';
import 'fare_quote_models.dart';

abstract class BookingRepository {
  Future<ApiResult<FareQuote>> requestFareQuote(FareQuoteRequest request);

  Future<ApiResult<Booking>> createBooking(BookingCreateRequest request);

  Future<ApiResult<Booking>> getBooking(String bookingId);

  Future<ApiResult<BookingList>> listUserBookings({int limit = 20, String? cursor});

  Future<ApiResult<void>> requestMatching(String bookingId);

  Future<ApiResult<Booking>> executeAction({
    required String bookingId,
    required String action, // confirm, cancel
    required String reason,
  });
}
