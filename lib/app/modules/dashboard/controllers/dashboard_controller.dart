import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../models/dispatch_assignment.dart';
import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _service;

  DashboardController({required DashboardService service}) : _service = service;

  // ── Online status ─────────────────────────────────────────────────────
  final isOnline = false.obs;
  final isLoading = false.obs;
  final activeAssignment = Rxn<DispatchAssignment>();

  // ── Driver ────────────────────────────────────────────────────────────
  final driverName = 'Driver'.obs;
  final driverInitials = 'D'.obs;

  // ── Ambulance ─────────────────────────────────────────────────────────
  final ambulanceName = '—'.obs;
  final plateNumber = '—'.obs;
  final ambulanceType = '—'.obs;
  final fuelPercent = 0.obs;
  final equipmentReady = false.obs;

  // ── Today stats ───────────────────────────────────────────────────────
  final tripsDone = 0.obs;
  final distanceKm = 0.obs;
  final activeTime = '0h00'.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadDashboard();

    // If returning from tracking, skip the active-dispatch redirect.
    final arguments = Get.arguments;
    final returningFromTracking =
        arguments is Map && arguments['skipActiveDispatchRedirect'] == true;
    if (!returningFromTracking) loadActiveAssignment();
  }

  // ── Data loading ──────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final profile = await _service.getDriverProfile();

      dynamic value(List<String> keys) {
        for (final key in keys) {
          if (profile[key] != null) return profile[key];
        }
        return null;
      }

      String? stringValue(List<String> keys) => value(keys)?.toString();

      int? intValue(List<String> keys) {
        final item = value(keys);
        return item is num
            ? item.toInt()
            : int.tryParse(item?.toString() ?? '');
      }

      // Driver
      final name = stringValue(['driverName', 'name', 'fullName']);
      if (name != null && name.isNotEmpty) {
        driverName.value = name;
        driverInitials.value = name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();
      }

      // Ambulance
      final ambulance = stringValue(['ambulanceName', 'vehicleName']);
      if (ambulance != null) ambulanceName.value = ambulance;
      final plate = stringValue(['plateNumber', 'vehiclePlate']);
      if (plate != null) plateNumber.value = plate;
      final type = stringValue(['ambulanceType', 'vehicleType']);
      if (type != null) ambulanceType.value = type;

      final fuel = intValue(['fuelPercent', 'fuelPercentage']);
      if (fuel != null) fuelPercent.value = fuel.clamp(0, 100);
      final ready = value(['equipmentReady', 'isEquipmentReady']);
      if (ready is bool) equipmentReady.value = ready;

      // Today stats
      final trips = intValue(['tripsDone', 'completedTrips', 'tripCount']);
      if (trips != null) tripsDone.value = trips;
      final distance = intValue(['distanceKm', 'totalDistanceKm']);
      if (distance != null) distanceKm.value = distance;
      final duration = stringValue(['activeTime', 'activeDuration']);
      if (duration != null) activeTime.value = duration;

      // Online
      final online = value(['isOnline', 'online']);
      if (online is bool) isOnline.value = online;
    } catch (e) {
      Get.snackbar('Error', 'Unable to load dashboard.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Toggle online / offline ───────────────────────────────────────────

  Future<void> toggleOnlineStatus(bool value) async {
    try {
      isLoading.value = true;
      if (value) {
        await _service.checkIn();
        isOnline.value = true;
        await loadActiveAssignment();
      } else {
        await _service.checkOut();
        isOnline.value = false;
      }

      if (!Get.testMode) {
        Get.snackbar(
          value ? 'Online' : 'Offline',
          value
              ? 'You are now receiving emergency requests.'
              : 'You are no longer receiving requests.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isOnline.value = false;
      if (!Get.testMode) {
        Get.snackbar(
          'Error',
          'Could not update driver status.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Active assignment ─────────────────────────────────────────────────

  Future<void> loadActiveAssignment() async {
    try {
      final assignment = await _service.getActiveAssignment();
      activeAssignment.value = assignment;

      if (assignment == null) {
        // No active assignment — stay on dashboard.
        if (Get.currentRoute != Routes.dashboard) {
          Get.offAllNamed(Routes.dashboard);
        }
        return;
      }

      final status = assignment.dispatchStatus.trim().toUpperCase();
      final accepted =
          assignment.acceptedAt?.trim().isNotEmpty == true ||
          status != 'DISPATCHED';

      // Route to tracking or requests once those modules are migrated.
      // For now, log the status — the stubs exist as route placeholders.
      final route = accepted ? Routes.tracking : Routes.requests;
      if (Get.currentRoute != route) {
        Get.offNamed(route);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Pull-to-refresh ───────────────────────────────────────────────────

  Future<void> refreshDashboard() async => loadDashboard();
}
