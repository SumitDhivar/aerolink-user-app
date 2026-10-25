import '../../../core/network/api_client.dart';
import '../domain/coverage_result.dart';

class CoverageApiService {
  final ApiClient _apiClient;

  CoverageApiService(this._apiClient);

  Future<CoverageCheckResponse> checkCoverage({
    required LocationInput location,
    required String purpose,
    DateTime? checkedAt,
  }) async {
    final now = checkedAt ?? DateTime.now().toUtc();
    final response = await _apiClient.dio.post(
      '/coverage/check',
      data: {
        'location': location.toJson(),
        'purpose': purpose,
        'checked_at': now.toIso8601String(),
      },
    );
    return CoverageCheckResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> submitExpansionRequest(ExpansionRequest request) async {
    final response = await _apiClient.dio.post(
      '/coverage/expansion-requests',
      data: request.toJson(),
    );
    return (response.data['request_id'] as String?) ?? 'submitted';
  }
}
