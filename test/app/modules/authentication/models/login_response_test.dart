import 'package:ambulance_driver/app/modules/authentication/models/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson parses a successful response', () {
      final json = <String, dynamic>{
        'success': true,
        'token': 'jwt-token',
        'refresh_token': 'refresh-jwt',
        'message': 'OK',
        'user': {
          'id': 1,
          'name': 'John',
          'email': 'john@test.com',
          'phone': '0812345',
          'role': 'driver',
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'jwt-token');
      expect(response.refreshToken, 'refresh-jwt');
      expect(response.user, isNotNull);
      expect(response.user!.id, '1');
      expect(response.user!.name, 'John');
      expect(response.user!.email, 'john@test.com');
      expect(response.user!.phone, '0812345');
      expect(response.user!.role, 'driver');
    });

    test('fromJson rejects a response without an access token', () {
      expect(
        () => LoginResponse.fromJson(<String, dynamic>{'success': false}),
        throwsFormatException,
      );
    });
  });

  group('UserData', () {
    test('fromJson / toJson round-trips', () {
      final json = <String, dynamic>{
        'id': '42',
        'name': 'Jane',
        'email': 'jane@test.com',
        'phone': '0899999',
        'role': 'driver',
      };

      final user = UserData.fromJson(json);
      final output = user.toJson();

      expect(output, json);
    });

    test('handles null values gracefully', () {
      final user = UserData.fromJson(<String, dynamic>{});

      expect(user.id, isNull);
      expect(user.name, isNull);
      expect(user.email, isNull);
      expect(user.phone, isNull);
      expect(user.role, isNull);
    });
  });
}
