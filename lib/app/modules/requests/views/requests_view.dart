import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/requests_controller.dart';

class RequestsView extends GetView<RequestsController> {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Incoming dispatch')),
    body: Obx(() {
      if (controller.isLoading.value && controller.assignment.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final assignment = controller.assignment.value;
      if (assignment == null) {
        return RefreshIndicator(
          onRefresh: controller.loadAssignment,
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * .25),
              const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage.value.isEmpty
                    ? 'No incoming dispatch requests'
                    : controller.errorMessage.value,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _priority(assignment.priority),
                const SizedBox(height: 16),
                _tile(Icons.trip_origin, 'Pickup', assignment.pickup),
                _tile(
                  Icons.local_hospital_outlined,
                  'Destination',
                  assignment.hospital,
                ),
                _tile(Icons.person_outline, 'Patient', assignment.patientName),
                _tile(
                  Icons.medical_information_outlined,
                  'Condition',
                  assignment.patientCondition,
                ),
                if (assignment.distance != '--')
                  _tile(Icons.route_outlined, 'Distance', assignment.distance),
                if (assignment.eta != '--')
                  _tile(Icons.schedule, 'ETA', assignment.eta),
                if (controller.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.reject,
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.accept,
                      child: controller.isLoading.value
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }),
  );

  Widget _priority(String value) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.emergency, color: Colors.red),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _tile(IconData icon, String label, String value) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(
      label,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    ),
    subtitle: Text(
      value,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
