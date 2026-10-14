import 'package:get/get.dart';

import '../../../data/providers/api_provider.dart';
import '../../../data/services/location_service.dart';
import '../controllers/requests_controller.dart';
import '../services/requests_service.dart';

class RequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RequestsService(Get.find<ApiProvider>()));
    Get.lazyPut(
      () => RequestsController(
        service: Get.find<RequestsService>(),
        locationService: Get.find<LocationService>(),
      ),
    );
  }
}
