import 'dart:convert';

import 'package:ambulance_driver/app/data/services/storage_service.dart';
import 'package:ambulance_driver/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:ambulance_driver/app/modules/authentication/models/login_request.dart';
import 'package:ambulance_driver/app/modules/authentication/models/login_response.dart';
import 'package:ambulance_driver/app/modules/authentication/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// ── Fakes ───────────────────────────────────────────────────────────────────

class FakeAuthService implements AuthService {
  LoginResponse? nextResponse;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    return nextResponse ?? const LoginResponse(accessToken: 'fake-token');
  }

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStorageService implements StorageService {
  final Map<String, String> store = {};

  @override
  Future<String?> read(String key) async => store[key];

  @override
  Future<void> write(String key, String value) async => store[key] = value;

  @override
  Future<void> delete(String key) async => store.remove(key);

  @override
  Future<void> deleteAll() async => store.clear();

  @override
  Future<void> clearSession() async {
    store.remove(StorageService.authTokenKey);
    store.remove(StorageService.refreshTokenKey);
    store.remove(StorageService.userDataKey);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late FakeAuthService fakeAuth;
  late FakeStorageService fakeStorage;
  late AuthenticationController controller;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;

    fakeAuth = FakeAuthService();
    fakeStorage = FakeStorageService();
    controller = AuthenticationController(
      authService: fakeAuth,
      storage: fakeStorage,
    );
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('AuthenticationController', () {
    test('initial state is clean', () {
      expect(controller.isLoading.value, isFalse);
      expect(controller.isPasswordVisible.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('togglePasswordVisibility toggles the flag', () {
      expect(controller.isPasswordVisible.value, isFalse);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isTrue);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isFalse);
    });

    test('token storage round-trip via StorageService', () async {
      // Simulate what _saveToken + _saveUserData do.
      await fakeStorage.write('auth_token', 'tok');
      await fakeStorage.write('refresh_token', 'ref');
      await fakeStorage.write(
        'user_data',
        jsonEncode(
          const UserData(id: '1', name: 'X', email: 'x@x.com').toJson(),
        ),
      );

      expect(await fakeStorage.read('auth_token'), 'tok');
      expect(await fakeStorage.read('refresh_token'), 'ref');
      expect(await fakeStorage.read('user_data'), isNotNull);
    });

    test('logout clears all stored data', () async {
      await fakeStorage.write('auth_token', 'tok');
      await fakeStorage.write('refresh_token', 'ref');
      await controller.logout();

      expect(await fakeStorage.read('auth_token'), isNull);
      expect(await fakeStorage.read('refresh_token'), isNull);
    });
  });
}
