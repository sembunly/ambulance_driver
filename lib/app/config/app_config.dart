class AppConfig {
  static const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.102.24:8085/ems-api',
  );
  // ── Auth ─────────────────────────────────────────────────────────────────
  static const login = '/api/v1/auth/login';
  static const logout = '/api/v1/auth/logout';
  static const refreshToken = '/api/v1/auth/refresh';

  // ── Driver App ───────────────────────────────────────────────────────────
  static const driverProfile = '/api/v1/driver-app/profile';
  static const driverCheckIn = '/api/v1/driver-app/check-in';
  static const driverCheckOut = '/api/v1/driver-app/check-out';
  static const activeAssignments = '/api/v1/driver-app/assignments/active';
  static const acceptDispatch = '/api/v1/driver-app/dispatches/accept';
  static const rejectDispatch = '/api/v1/driver-app/dispatches/reject';
}
