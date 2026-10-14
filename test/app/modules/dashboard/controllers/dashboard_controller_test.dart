import 'package:ambulance_driver/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ambulance_driver/app/modules/dashboard/models/dispatch_assignment.dart';
import 'package:ambulance_driver/app/modules/dashboard/services/dashboard_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// ── Fakes ───────────────────────────────────────────────────────────────────

class FakeDashboardService implements DashboardService {
  Map<String, dynamic> profileResponse = {};
  DispatchAssignment? assignmentResponse;
  bool checkInCalled = false;

  @override
  Future<Map<String, dynamic>> getDriverProfile() async => profileResponse;

  @override
  Future<void> checkIn() async => checkInCalled = true;

  @override
  Future<void> checkOut() async {}

  @override
  Future<DispatchAssignment?> getActiveAssignment() async => assignmentResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late FakeDashboardService fakeService;
  late DashboardController controller;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;

    fakeService = FakeDashboardService();
    controller = DashboardController(service: fakeService);
  });

  tearDown(() {
    Get.reset();
  });

  group('DashboardController', () {
    test('initial observable defaults', () {
      expect(controller.isOnline.value, isFalse);
      expect(controller.isLoading.value, isFalse);
      expect(controller.driverName.value, 'Driver');
      expect(controller.driverInitials.value, 'D');
      expect(controller.tripsDone.value, 0);
      expect(controller.distanceKm.value, 0);
      expect(controller.activeTime.value, '0h00');
      expect(controller.activeAssignment.value, isNull);
    });

    test('loadDashboard populates driver and vehicle fields', () async {
      fakeService.profileResponse = {
        'driverName': 'Sokha Chan',
        'ambulanceName': 'AMB-042',
        'plateNumber': '2AA-9981',
        'ambulanceType': 'ALS',
        'fuelPercent': 82,
        'equipmentReady': true,
        'tripsDone': 6,
        'distanceKm': 84,
        'activeTime': '5h20',
        'isOnline': true,
      };

      await controller.loadDashboard();

      expect(controller.driverName.value, 'Sokha Chan');
      expect(controller.driverInitials.value, 'SC');
      expect(controller.ambulanceName.value, 'AMB-042');
      expect(controller.plateNumber.value, '2AA-9981');
      expect(controller.ambulanceType.value, 'ALS');
      expect(controller.fuelPercent.value, 82);
      expect(controller.equipmentReady.value, isTrue);
      expect(controller.tripsDone.value, 6);
      expect(controller.distanceKm.value, 84);
      expect(controller.activeTime.value, '5h20');
      expect(controller.isOnline.value, isTrue);
      expect(controller.isLoading.value, isFalse);
    });

    test('loadDashboard computes initials from multi-word name', () async {
      fakeService.profileResponse = {'name': 'Vuthy Heng'};
      await controller.loadDashboard();

      expect(controller.driverInitials.value, 'VH');
    });

    test('loadDashboard clamps fuel to 0-100', () async {
      fakeService.profileResponse = {'fuelPercent': 120};
      await controller.loadDashboard();

      expect(controller.fuelPercent.value, 100);
    });

    test('toggleOnlineStatus calls checkIn when going online', () async {
      await controller.toggleOnlineStatus(true);

      expect(fakeService.checkInCalled, isTrue);
      expect(controller.isOnline.value, isTrue);
    });

    test('toggleOnlineStatus sets offline without calling checkIn', () async {
      controller.isOnline.value = true;
      fakeService.checkInCalled = false;

      await controller.toggleOnlineStatus(false);

      expect(fakeService.checkInCalled, isFalse);
      expect(controller.isOnline.value, isFalse);
    });

    test('loadActiveAssignment stores assignment', () async {
      fakeService.assignmentResponse = const DispatchAssignment(
        dispatchId: 'D-001',
        dispatchStatus: 'ACCEPTED',
        acceptedAt: '2026-01-01T12:00:00Z',
      );

      await controller.loadActiveAssignment();

      expect(controller.activeAssignment.value, isNotNull);
      expect(controller.activeAssignment.value!.dispatchId, 'D-001');
    });

    test('refreshDashboard delegates to loadDashboard', () async {
      fakeService.profileResponse = {'driverName': 'Refresh Test'};
      await controller.refreshDashboard();

      expect(controller.driverName.value, 'Refresh Test');
    });
  });
}
