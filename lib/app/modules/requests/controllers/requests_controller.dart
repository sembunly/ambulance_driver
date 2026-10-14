import 'package:get/get.dart';

import '../../../data/services/location_service.dart';
import '../../../routes/app_pages.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../dashboard/models/dispatch_assignment.dart';
import '../services/requests_service.dart';

class RequestsController extends GetxController {
  RequestsController({
    required RequestsService service,
    required LocationService locationService,
  }) : _service = service,
       _locationService = locationService;

  final RequestsService _service;
  final LocationService _locationService;
  final assignment = Rxn<DispatchAssignment>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<DashboardController>()) {
      assignment.value = Get.find<DashboardController>().activeAssignment.value;
    }
    if (assignment.value == null) loadAssignment();
  }

  Future<void> loadAssignment() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      assignment.value = await _service.getActiveAssignment();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> accept() async {
    final current = assignment.value;
    if (current == null) return;
    isLoading.value = true;
    try {
      final location = await _locationService.getCurrentLocation();
      await _service.accept(
        dispatchId: current.dispatchId,
        latitude: location.latitude,
        longitude: location.longitude,
        locationAddress: location.address,
      );
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().activeAssignment.value = current;
      }
      Get.offNamed(Routes.tracking, arguments: current);
      Get.snackbar(
        'Dispatch accepted',
        'Live navigation is ready.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      errorMessage.value = error.toString();
      Get.snackbar(
        'Unable to accept dispatch',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reject() async {
    final current = assignment.value;
    if (current == null) return;
    isLoading.value = true;
    try {
      await _service.reject(current.dispatchId);
      assignment.value = null;
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().activeAssignment.value = null;
      }
      Get.offAllNamed(
        Routes.dashboard,
        arguments: const {'skipActiveDispatchRedirect': true},
      );
      Get.snackbar(
        'Dispatch rejected',
        'Dispatch declined.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
