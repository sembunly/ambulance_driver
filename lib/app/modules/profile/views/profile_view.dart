import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Driver profile'),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(Routes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
    body: Obx(() {
      if (controller.isLoading.value && controller.profile.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.profile.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.errorMessage.value),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: controller.load,
                child: const Text('Try again'),
              ),
            ],
          ),
        );
      }
      final name = controller.value([
        'driverName',
        'fullName',
        'name',
      ], 'Driver');
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 42,
              child: Text(
                name
                    .split(RegExp(r'\s+'))
                    .where((e) => e.isNotEmpty)
                    .take(2)
                    .map((e) => e[0])
                    .join()
                    .toUpperCase(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _row(
              Icons.badge_outlined,
              'Driver ID',
              controller.value(['driverId', 'staffId', 'id']),
            ),
            _row(
              Icons.phone_outlined,
              'Phone',
              controller.value(['phoneNumber', 'phone']),
            ),
            _row(Icons.email_outlined, 'Email', controller.value(['email'])),
            _row(
              Icons.local_shipping_outlined,
              'Ambulance',
              controller.value(['ambulanceName', 'vehicleName']),
            ),
            _row(
              Icons.pin_outlined,
              'Plate',
              controller.value(['plateNumber', 'vehiclePlate']),
            ),
          ],
        ),
      );
    }),
  );

  Widget _row(IconData icon, String label, String value) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    ),
  );
}
