import '../../../config/app_config.dart';
import '../../../data/providers/api_provider.dart';
import '../../dashboard/models/dispatch_assignment.dart';

class TripsService {
  TripsService(this._api);
  final ApiProvider _api;

  Future<DispatchAssignment?> activeTrip() async {
    try {
      final response = await _api.client.get(AppConfig.activeAssignments);
      final value = _api.unwrap(response.data);
      if (value is List && value.isNotEmpty && value.first is Map) {
        return DispatchAssignment.fromJson(
          (value.first as Map).cast<String, dynamic>(),
        );
      }
      if (value is Map && value.isNotEmpty) {
        return DispatchAssignment.fromJson(value.cast<String, dynamic>());
      }
      return null;
    } catch (error) {
      throw TripsException(
        _api.errorMessage(error, 'Unable to load active trip.'),
      );
    }
  }
}

class TripsException implements Exception {
  const TripsException(this.message);
  final String message;
  @override
  String toString() => message;
}
