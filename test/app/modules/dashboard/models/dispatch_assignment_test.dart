import 'package:ambulance_driver/app/modules/dashboard/models/dispatch_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DispatchAssignment', () {
    test('fromJson parses full payload', () {
      final json = <String, dynamic>{
        'dispatchId': 'D-001',
        'dispatchStatus': 'ACCEPTED',
        'acceptedAt': '2026-01-01T12:00:00Z',
        'pickupLocationName': 'Central Park',
        'destinationHospitalName': 'City Hospital',
        'dispatchPriority': 'Critical',
        'distance': '5.2',
        'eta': '8 min',
        'patientName': 'Jane',
        'patientCondition': 'Stable',
        'pickupLatitude': 11.55,
        'pickupLongitude': 104.92,
        'destinationLatitude': 11.56,
        'destinationLongitude': 104.93,
      };

      final a = DispatchAssignment.fromJson(json);

      expect(a.dispatchId, 'D-001');
      expect(a.dispatchStatus, 'ACCEPTED');
      expect(a.acceptedAt, '2026-01-01T12:00:00Z');
      expect(a.pickup, 'Central Park');
      expect(a.hospital, 'City Hospital');
      expect(a.priority, 'Critical');
      expect(a.distance, '5.2');
      expect(a.eta, '8 min');
      expect(a.patientName, 'Jane');
      expect(a.patientCondition, 'Stable');
      expect(a.pickupLatitude, 11.55);
      expect(a.pickupLongitude, 104.92);
      expect(a.destinationLatitude, 11.56);
      expect(a.destinationLongitude, 104.93);
    });

    test('fromJson uses defaults for missing fields', () {
      final a = DispatchAssignment.fromJson(<String, dynamic>{});

      expect(a.dispatchId, '');
      expect(a.dispatchStatus, 'DISPATCHED');
      expect(a.acceptedAt, isNull);
      expect(a.pickup, 'Pickup location');
      expect(a.hospital, 'Destination hospital');
      expect(a.priority, 'Emergency');
      expect(a.distance, '--');
      expect(a.eta, '--');
      expect(a.pickupLatitude, isNull);
    });

    test('coordinate parses string numbers', () {
      final a = DispatchAssignment.fromJson(<String, dynamic>{
        'pickupLatitude': '11.55',
        'pickupLongitude': '104.92',
      });

      expect(a.pickupLatitude, 11.55);
      expect(a.pickupLongitude, 104.92);
    });

    test('coordinate handles fallback keys', () {
      final a = DispatchAssignment.fromJson(<String, dynamic>{
        'destinationHospitalLatitude': 11.56,
        'destinationHospitalLongitude': 104.93,
      });

      expect(a.destinationLatitude, 11.56);
      expect(a.destinationLongitude, 104.93);
    });
  });
}
