import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const authTokenKey = 'auth_token';
  static const refreshTokenKey = 'refresh_token';
  static const userDataKey = 'user_data';

  StorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<String?> read(String key) => _secureStorage.read(key: key);

  Future<void> write(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  Future<void> delete(String key) => _secureStorage.delete(key: key);

  Future<void> deleteAll() => _secureStorage.deleteAll();

  Future<void> clearSession() async {
    await delete(authTokenKey);
    await delete(refreshTokenKey);
    await delete(userDataKey);
  }
}
