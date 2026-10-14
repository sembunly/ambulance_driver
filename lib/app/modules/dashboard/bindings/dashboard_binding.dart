import 'package:get/get.dart';

import '../../../data/providers/api_provider.dart';
import '../controllers/dashboard_controller.dart';
import '../services/dashboard_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardService>(
      () => DashboardService(Get.find<ApiProvider>()),
      fenix: true,
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(service: Get.find<DashboardService>()),
    );
  }
}
