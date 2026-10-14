import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: Obx(
      () => ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Dispatch alerts'),
            subtitle: const Text('Show alerts for incoming emergency requests'),
            value: controller.dispatchAlerts.value,
            onChanged: controller.setDispatchAlerts,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.location_on_outlined),
            title: const Text('Live location'),
            subtitle: const Text('Track location while an active trip is open'),
            value: controller.locationTracking.value,
            onChanged: controller.setLocationTracking,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            trailing: controller.isLoading.value
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: controller.isLoading.value ? null : controller.logout,
          ),
        ],
      ),
    ),
  );
}
