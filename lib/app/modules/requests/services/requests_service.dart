import '../../../config/app_config.dart';
import '../../../data/providers/api_provider.dart';
import '../../dashboard/models/dispatch_assignment.dart';

class RequestsService {
  RequestsService(this._api);
  final ApiProvider _api;

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
      throw RequestsException(
        _api.errorMessage(error, 'Unable to load dispatch request.'),
      );
    }
  }

  Future<void> accept({
    required String dispatchId,
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) => _update(
    path: AppConfig.acceptDispatch,
    dispatchId: dispatchId,
    statusCode: 'ACCEPTED',
    latitude: latitude,
    longitude: longitude,
    locationAddress: locationAddress,
  );

  Future<void> reject(String dispatchId) => _update(
    path: AppConfig.rejectDispatch,
    dispatchId: dispatchId,
    statusCode: 'REJECTED',
  );

  Future<void> _update({
    required String path,
    required String dispatchId,
    required String statusCode,
    double latitude = 0,
    double longitude = 0,
    String locationAddress = '',
  }) async {
    if (dispatchId.trim().isEmpty || dispatchId == '0') {
      throw const RequestsException(
        'The active dispatch has no valid dispatch ID.',
      );
    }
    try {
      final response = await _api.client.post(
        path,
        data: {
          'dispatchId': dispatchId,
          'statusCode': statusCode,
          'reason': '',
          'note': '',
          'latitude': latitude,
          'longitude': longitude,
          'locationAddress': locationAddress,
        },
      );
      final raw = response.data;
      if (raw is Map && raw['success'] == false) {
        throw RequestsException(
          _api.errorMessage(raw, 'The backend rejected the dispatch update.'),
        );
      }
      final body = raw is Map ? raw['body'] : null;
      if (body is Map && body['status'] == false) {
        throw RequestsException(
          (body['message'] ?? 'The backend rejected the dispatch update.')
              .toString(),
        );
      }
    } catch (error) {
      if (error is RequestsException) rethrow;
      throw RequestsException(
        _api.errorMessage(error, 'Unable to update dispatch.'),
      );
    }
  }
}

class RequestsException implements Exception {
  const RequestsException(this.message);
  final String message;
  @override
  String toString() => message;
}
