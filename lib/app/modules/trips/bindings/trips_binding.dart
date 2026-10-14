import 'package:get/get.dart';

import '../../../data/providers/api_provider.dart';
import '../controllers/trips_controller.dart';
import '../services/trips_service.dart';

class TripsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TripsService(Get.find<ApiProvider>()));
    Get.lazyPut(() => TripsController(Get.find<TripsService>()));
  }
}
