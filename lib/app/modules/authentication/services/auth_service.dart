import '../../../config/app_config.dart';
import '../../../data/providers/api_provider.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  AuthService(this._api);

  final ApiProvider _api;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _api.client.post(
        AppConfig.login,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (error) {
      throw AuthException(_api.errorMessage(error, 'Login failed.'));
    }
  }

  Future<void> logout() async => _api.client.post(AppConfig.logout);
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
