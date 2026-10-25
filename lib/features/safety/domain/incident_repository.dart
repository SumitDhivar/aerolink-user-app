import '../../../core/network/api_result.dart';
import 'incident_models.dart';

abstract class IncidentRepository {
  Future<ApiResult<IncidentResponse>> reportIncident(IncidentCreateRequest request);
}
