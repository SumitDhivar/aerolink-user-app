import '../../../core/network/api_result.dart';
import 'trip_models.dart';

abstract class TripRepository {
  Future<ApiResult<Trip>> getTripDetail(String tripId);
}
