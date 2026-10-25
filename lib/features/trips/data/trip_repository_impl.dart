import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/trip_models.dart';
import '../domain/trip_repository.dart';
import 'trip_api_service.dart';

class TripRepositoryImpl implements TripRepository {
  final TripApiService apiService;
  final ApiClient apiClient;

  TripRepositoryImpl({
    required this.apiService,
    required this.apiClient,
  });

  @override
  Future<ApiResult<Trip>> getTripDetail(String tripId) async {
    try {
      final trip = await apiService.getTrip(tripId);
      return Success(trip);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/trips/$tripId'), error: e),
      ));
    }
  }
}
