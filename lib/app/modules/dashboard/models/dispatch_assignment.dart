class DispatchAssignment {
  const DispatchAssignment({
    required this.dispatchId,
    this.dispatchStatus = 'DISPATCHED',
    this.acceptedAt,
    this.pickup = 'Pickup location',
    this.hospital = 'Destination hospital',
    this.priority = 'Emergency',
    this.distance = '--',
    this.eta = '--',
    this.patientName = 'Patient',
    this.patientCondition = 'Not provided',
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
  });

  final String dispatchId;
  final String dispatchStatus;
  final String? acceptedAt;
  final String pickup;
  final String hospital;
  final String priority;
  final String distance;
  final String eta;
  final String patientName;
  final String patientCondition;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;

  factory DispatchAssignment.fromJson(Map<String, dynamic> json) {
    String value(List<String> keys, String fallback) {
      for (final key in keys) {
        if (json[key] != null) return json[key].toString();
      }
      return fallback;
    }

    double? coordinate(List<String> keys) {
      for (final key in keys) {
        final rawValue = json[key];
        if (rawValue is num) return rawValue.toDouble();
        if (rawValue != null) {
          final parsed = double.tryParse(rawValue.toString());
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    return DispatchAssignment(
      dispatchId: value(['dispatchId'], ''),
      dispatchStatus: value(['dispatchStatus'], 'DISPATCHED'),
      acceptedAt: json['acceptedAt']?.toString(),
      pickup: value(['pickupLocationName'], 'Pickup location'),
      hospital: value(['destinationHospitalName'], 'Destination hospital'),
      priority: value(['dispatchPriority'], 'Emergency'),
      distance: value(['distance', 'distanceKm'], '--'),
      eta: value(['eta', 'estimatedArrival', 'etaMinutes'], '--'),
      patientName: value(['patientName'], 'Patient'),
      patientCondition: value(['patientCondition'], 'Not provided'),
      pickupLatitude: coordinate(['pickupLatitude']),
      pickupLongitude: coordinate(['pickupLongitude']),
      destinationLatitude: coordinate([
        'destinationLatitude',
        'destinationHospitalLatitude',
      ]),
      destinationLongitude: coordinate([
        'destinationLongitude',
        'destinationHospitalLongitude',
      ]),
    );
  }
}
