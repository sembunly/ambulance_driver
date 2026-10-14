import 'package:get/get.dart';

import '../../../data/providers/api_provider.dart';
import '../../../data/services/storage_service.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SettingsController(
        Get.find<ApiProvider>(),
        Get.find<StorageService>(),
      ),
    );
  }
}
