import '../../../config/app_config.dart';
import '../../../data/providers/api_provider.dart';
import '../models/dispatch_assignment.dart';

class DashboardService {
  DashboardService(this._api);

  final ApiProvider _api;

  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      final response = await _api.client.get(AppConfig.driverProfile);
      final value = _api.unwrap(response.data);
      if (value is! Map) {
        throw const DashboardApiException('Invalid driver profile response.');
      }
      return value.cast<String, dynamic>();
    } catch (error) {
      if (error is DashboardApiException) rethrow;
      throw DashboardApiException(
        _api.errorMessage(error, 'Failed to load profile.'),
      );
    }
  }

  Future<void> checkIn() async => _postStatus(AppConfig.driverCheckIn);

  Future<void> checkOut() async => _postStatus(AppConfig.driverCheckOut);

  Future<void> _postStatus(String path) async {
    try {
      await _api.client.post(path);
    } catch (error) {
      throw DashboardApiException(
        _api.errorMessage(error, 'Unable to update driver status.'),
      );
    }
  }

  Future<DispatchAssignment?> getActiveAssignment() async {
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
      throw DashboardApiException(
        _api.errorMessage(error, 'Failed to load active assignment.'),
      );
    }
  }
}

class DashboardApiException implements Exception {
  const DashboardApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
