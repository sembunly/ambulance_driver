import 'package:dio/dio.dart';

import '../../config/app_config.dart';

class ApiProvider {
  ApiProvider({Dio? client})
    : client = client ?? Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  final Dio client;
}
