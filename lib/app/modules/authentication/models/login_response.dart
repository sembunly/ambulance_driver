class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final UserData? user;

  factory LoginResponse.fromJson(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return LoginResponse(accessToken: raw.trim());
    }
    if (raw is! Map) throw const FormatException('Invalid login response.');
    final body = raw['body'] is Map ? raw['body'] as Map : raw;
    String? findToken(Map value, List<String> keys) {
      for (final key in keys) {
        final token = value[key];
        if (token is String && token.isNotEmpty) return token;
      }
      return null;
    }

    final token = findToken(body, const [
      'accessToken',
      'access_token',
      'token',
      'jwt',
      'idToken',
    ]);
    if (token == null) {
      throw const FormatException(
        'Login succeeded but no access token was returned.',
      );
    }
    final userRaw = body['user'] is Map ? body['user'] as Map : body;
    return LoginResponse(
      accessToken: token,
      refreshToken: findToken(body, const ['refreshToken', 'refresh_token']),
      user: UserData.fromJson(userRaw.cast<String, dynamic>()),
    );
  }
}

class UserData {
  const UserData({this.id, this.name, this.email, this.phone, this.role});

  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['userId']?.toString() ?? json['id']?.toString(),
    name: (json['displayName'] ?? json['name'] ?? json['username'])?.toString(),
    email: json['email']?.toString(),
    phone: (json['phoneNumber'] ?? json['phone'])?.toString(),
    role: json['role']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
  };
}
