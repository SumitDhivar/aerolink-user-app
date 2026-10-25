import '../../../core/network/api_result.dart';
import 'coverage_result.dart';

abstract class CoverageRepository {
  Future<ApiResult<CoverageCheckResponse>> checkCoverage({
    required LocationInput location,
    required String purpose, // origin, destination, pickup, dropoff
    DateTime? checkedAt,
  });

  Future<ApiResult<String>> submitExpansionRequest(ExpansionRequest request);
}
