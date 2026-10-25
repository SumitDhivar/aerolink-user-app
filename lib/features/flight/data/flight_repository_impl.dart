import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/flight_repository.dart';
import '../domain/flight_status.dart';
import 'flight_api_service.dart';

class FlightRepositoryImpl implements FlightRepository {
  final FlightApiService apiService;
  final ApiClient apiClient;

  FlightRepositoryImpl({
    required this.apiService,
    required this.apiClient,
  });

  @override
  Future<ApiResult<FlightStatus>> getFlightStatus({
    required String flightNumber,
    required String flightDate,
  }) async {
    try {
      final status = await apiService.getFlightStatus(
        flightNumber: flightNumber,
        flightDate: flightDate,
      );
      return Success(status);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/flight-status'), error: e),
      ));
    }
  }
}
