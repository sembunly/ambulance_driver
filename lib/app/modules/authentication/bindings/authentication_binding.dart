import 'package:get/get.dart';

import '../../../data/providers/api_provider.dart';
import '../../../data/services/storage_service.dart';
import '../controllers/authentication_controller.dart';
import '../services/auth_service.dart';

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(
          () => AuthService(Get.find<ApiProvider>()),
    );
    Get.lazyPut<AuthenticationController>(
          () => AuthenticationController(
        authService: Get.find<AuthService>(),
        storage: Get.find<StorageService>(),
      ),
    );
  }
}

