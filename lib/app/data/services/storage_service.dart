import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<String?> read(String key) => _secureStorage.read(key: key);

  Future<void> write(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  Future<void> delete(String key) => _secureStorage.delete(key: key);
}
