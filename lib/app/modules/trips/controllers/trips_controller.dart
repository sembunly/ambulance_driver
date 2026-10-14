import 'package:get/get.dart';

import '../../dashboard/models/dispatch_assignment.dart';
import '../services/trips_service.dart';

class TripsController extends GetxController {
  TripsController(this._service);
  final TripsService _service;
  final activeTrip = Rxn<DispatchAssignment>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      activeTrip.value = await _service.activeTrip();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
