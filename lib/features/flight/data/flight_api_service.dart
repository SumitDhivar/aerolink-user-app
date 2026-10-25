import '../../../core/network/api_client.dart';
import '../domain/flight_status.dart';

class FlightApiService {
  final ApiClient _apiClient;

  FlightApiService(this._apiClient);

  Future<FlightStatus> getFlightStatus({
    required String flightNumber,
    required String flightDate,
  }) async {
    final response = await _apiClient.dio.get(
      '/flight-status',
      queryParameters: {
        'flight_number': flightNumber.trim().toUpperCase(),
        'flight_date': flightDate,
      },
    );
    return FlightStatus.fromJson(response.data as Map<String, dynamic>);
  }
}
