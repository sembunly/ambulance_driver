import 'package:get/get.dart';

import '../../../config/app_config.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class SettingsController extends GetxController {
  SettingsController(this._api, this._storage);
  final ApiProvider _api;
  final StorageService _storage;
  final dispatchAlerts = true.obs;
  final locationTracking = true.obs;
  final isLoading = false.obs;

  static const _alertsKey = 'setting_dispatch_alerts';
  static const _trackingKey = 'setting_location_tracking';

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    dispatchAlerts.value = await _storage.read(_alertsKey) != 'false';
    locationTracking.value = await _storage.read(_trackingKey) != 'false';
  }

  Future<void> setDispatchAlerts(bool value) async {
    dispatchAlerts.value = value;
    await _storage.write(_alertsKey, value.toString());
  }

  Future<void> setLocationTracking(bool value) async {
    locationTracking.value = value;
    await _storage.write(_trackingKey, value.toString());
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _api.client.post(AppConfig.driverCheckOut);
      await _api.client.post(AppConfig.logout);
    } catch (_) {
      // Logout remains available offline.
    } finally {
      await _storage.clearSession();
      isLoading.value = false;
      Get.offAllNamed(Routes.authentication);
    }
  }
}
