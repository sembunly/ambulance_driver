import '../../../config/app_config.dart';
import '../../../data/providers/api_provider.dart';

class ProfileService {
  ProfileService(this._api);
  final ApiProvider _api;

  Future<Map<String, dynamic>> load() async {
    try {
      final response = await _api.client.get(AppConfig.driverProfile);
      final value = _api.unwrap(response.data);
      if (value is Map) return value.cast<String, dynamic>();
      throw const FormatException('Invalid profile response.');
    } catch (error) {
      throw ProfileException(
        _api.errorMessage(error, 'Unable to load driver profile.'),
      );
    }
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);
  final String message;
  @override
  String toString() => message;
}
