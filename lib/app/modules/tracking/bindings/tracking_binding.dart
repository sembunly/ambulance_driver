import 'package:get/get.dart';

import '../../../data/services/location_service.dart';
import '../../../data/providers/api_provider.dart';
import '../controllers/tracking_controller.dart';

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => TrackingController(
        Get.find<LocationService>(),
        Get.find<ApiProvider>(),
      ),
    );
  }
}
