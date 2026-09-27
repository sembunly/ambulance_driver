import 'package:get/get.dart';

import 'data/providers/api_provider.dart';
import 'data/services/storage_service.dart';

class DependencyInjection {
  static void init() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ApiProvider>(ApiProvider(), permanent: true);
  }
}
