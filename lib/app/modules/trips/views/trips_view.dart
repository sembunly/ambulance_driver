import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/trips_controller.dart';

class TripsView extends GetView<TripsController> {
  const TripsView({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(children: [_active(context), const _HistoryEmpty()]),
    ),
  );

  Widget _active(BuildContext context) => Obx(() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    final trip = controller.activeTrip.value;
    if (trip == null) {
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * .25),
            const Icon(Icons.route_outlined, size: 56, color: Colors.grey),
            const Center(child: Text('No active trip')),
            if (controller.errorMessage.isNotEmpty)
              Center(child: Text(controller.errorMessage.value)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.patientName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('Pickup: ${trip.pickup}'),
                  const SizedBox(height: 8),
                  Text('Destination: ${trip.hospital}'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        Get.toNamed(Routes.tracking, arguments: trip),
                    icon: const Icon(Icons.navigation),
                    label: const Text('Open live tracking'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text('No trip history available'),
          SizedBox(height: 6),
          Text(
            'The current EMS API does not expose a trip-history endpoint.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
