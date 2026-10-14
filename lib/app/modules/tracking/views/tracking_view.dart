import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../routes/app_pages.dart';
import '../controllers/tracking_controller.dart';

class TrackingView extends GetView<TrackingController> {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Live tracking'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.offAllNamed(
          Routes.dashboard,
          arguments: const {'skipActiveDispatchRedirect': true},
        ),
      ),
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final position = controller.driverPosition.value;
      if (position == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  size: 56,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: controller.startTracking,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      }
      final assignment = controller.assignment.value;
      return Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: position, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: controller.markers,
            polylines: controller.polylines,
          ),
          if (assignment != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: SafeArea(
                top: false,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.patientName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Pickup: ${assignment.pickup}'),
                        const SizedBox(height: 4),
                        Text('Destination: ${assignment.hospital}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }),
  );
}
