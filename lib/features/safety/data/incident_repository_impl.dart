import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/incident_models.dart';
import '../domain/incident_repository.dart';
import 'incident_api_service.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentApiService apiService;
  final ApiClient apiClient;

  IncidentRepositoryImpl({
    required this.apiService,
    required this.apiClient,
  });

  @override
  Future<ApiResult<IncidentResponse>> reportIncident(IncidentCreateRequest request) async {
    try {
      final incident = await apiService.reportIncident(request);
      return Success(incident);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/incidents'), error: e),
      ));
    }
  }
}
