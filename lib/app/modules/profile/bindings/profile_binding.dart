import 'package:get/get.dart';

import '../../../data/providers/api_provider.dart';
import '../controllers/profile_controller.dart';
import '../services/profile_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileService(Get.find<ApiProvider>()));
    Get.lazyPut(() => ProfileController(Get.find<ProfileService>()));
  }
}
