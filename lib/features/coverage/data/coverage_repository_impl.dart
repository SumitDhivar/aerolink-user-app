import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/coverage_repository.dart';
import '../domain/coverage_result.dart';
import 'coverage_api_service.dart';

class CoverageRepositoryImpl implements CoverageRepository {
  final CoverageApiService apiService;
  final ApiClient apiClient;

  CoverageRepositoryImpl({
    required this.apiService,
    required this.apiClient,
  });

  @override
  Future<ApiResult<CoverageCheckResponse>> checkCoverage({
    required LocationInput location,
    required String purpose,
    DateTime? checkedAt,
  }) async {
    try {
      final result = await apiService.checkCoverage(
        location: location,
        purpose: purpose,
        checkedAt: checkedAt,
      );
      return Success(result);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/coverage/check'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<String>> submitExpansionRequest(ExpansionRequest request) async {
    try {
      final reqId = await apiService.submitExpansionRequest(request);
      return Success(reqId);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/coverage/expansion-requests'), error: e),
      ));
    }
  }
}
