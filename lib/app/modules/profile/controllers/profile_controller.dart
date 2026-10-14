import 'package:get/get.dart';

import '../services/profile_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._service);
  final ProfileService _service;
  final profile = <String, dynamic>{}.obs;
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
      profile.assignAll(await _service.load());
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String value(List<String> keys, [String fallback = '—']) {
    for (final key in keys) {
      final item = profile[key]?.toString().trim();
      if (item != null && item.isNotEmpty) return item;
    }
    return fallback;
  }
}
