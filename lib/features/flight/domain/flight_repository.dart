import '../../../core/network/api_result.dart';
import 'flight_status.dart';

abstract class FlightRepository {
  Future<ApiResult<FlightStatus>> getFlightStatus({
    required String flightNumber,
    required String flightDate, // YYYY-MM-DD
  });
}
