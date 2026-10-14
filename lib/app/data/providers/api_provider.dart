import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../services/storage_service.dart';

class ApiProvider {
  ApiProvider(this._storage, {Dio? client})
    : client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {'Accept': 'application/json'},
              contentType: Headers.jsonContentType,
            ),
          ) {
    this.client.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final apiUri = Uri.parse(AppConfig.apiBaseUrl);
          final isBackendRequest =
              options.uri.host == apiUri.host &&
              options.uri.port == apiUri.port;
          if (isBackendRequest && !options.path.endsWith(AppConfig.login)) {
            final token = await _storage.read(StorageService.authTokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final apiUri = Uri.parse(AppConfig.apiBaseUrl);
          final requestUri = error.requestOptions.uri;
          final isBackendRequest =
              requestUri.host == apiUri.host && requestUri.port == apiUri.port;
          if (isBackendRequest &&
              error.response?.statusCode == 401 &&
              !error.requestOptions.path.endsWith(AppConfig.login)) {
            await _storage.clearSession();
          }
          handler.next(error);
        },
      ),
    );
  }

  final StorageService _storage;
  final Dio client;

  dynamic unwrap(dynamic raw) {
    var value = raw;
    if (value is Map && value['body'] != null) value = value['body'];
    if (value is Map && value['data'] != null) value = value['data'];
    return value;
  }

  String errorMessage(Object error, [String fallback = 'Request failed.']) {
    if (error is Map) {
      final body = error['body'];
      final header = error['header'];
      return (error['message'] ??
              (body is Map ? body['message'] : null) ??
              (header is Map ? header['errorText'] : null) ??
              fallback)
          .toString();
    }
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final body = data['body'];
        final header = data['header'];
        return (data['message'] ??
                (body is Map ? body['message'] : null) ??
                (header is Map ? header['errorText'] : null) ??
                fallback)
            .toString();
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'The EMS server timed out. Please try again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect to the EMS server.';
      }
    }
    return fallback;
  }
}
