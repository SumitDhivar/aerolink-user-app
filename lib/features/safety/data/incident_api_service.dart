import '../../../core/network/api_client.dart';
import '../domain/incident_models.dart';

class IncidentApiService {
  final ApiClient _apiClient;

  IncidentApiService(this._apiClient);

  Future<IncidentResponse> reportIncident(IncidentCreateRequest request) async {
    final response = await _apiClient.dio.post(
      '/incidents',
      data: request.toJson(),
    );
    return IncidentResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
