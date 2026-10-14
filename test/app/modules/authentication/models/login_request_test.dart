import 'package:ambulance_driver/app/modules/authentication/models/login_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequest', () {
    test('toJson returns correct map', () {
      final request = LoginRequest(
        phoneNumber: '012345678',
        password: 'secret123',
      );

      expect(request.toJson(), {
        'phoneNumber': '012345678',
        'password': 'secret123',
      });
    });

    test('preserves field values', () {
      final request = LoginRequest(phoneNumber: '0123', password: 'pw');

      expect(request.phoneNumber, '0123');
      expect(request.password, 'pw');
    });
  });
}
