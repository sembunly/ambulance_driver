import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocation {
  const DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
  final double latitude;
  final double longitude;
  final String address;
}

class LocationService {
  Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Location permission is required for dispatch tracking.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it in system settings.',
      );
    }
  }

  Future<DriverLocation> getCurrentLocation() async {
    await ensurePermission();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return DriverLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: await _addressFor(position),
    );
  }

  Stream<Position> positionStream() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );

  Future<String> _addressFor(Position position) async {
    try {
      final places = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final p = places.first;
        final parts =
            [
                  p.street,
                  p.subLocality,
                  p.locality,
                  p.administrativeArea,
                  p.country,
                ]
                .whereType<String>()
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toSet();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return '${position.latitude}, ${position.longitude}';
  }
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}
