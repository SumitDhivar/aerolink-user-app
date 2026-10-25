import '../../../core/network/api_client.dart';
import '../domain/trip_models.dart';

class TripApiService {
  final ApiClient _apiClient;

  TripApiService(this._apiClient);

  Future<Trip> getTrip(String tripId) async {
    final response = await _apiClient.dio.get('/trips/$tripId');
    return Trip.fromJson(response.data as Map<String, dynamic>);
  }
}
