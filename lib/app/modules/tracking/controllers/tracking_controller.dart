import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../config/app_config.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/location_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../dashboard/models/dispatch_assignment.dart';

class TrackingController extends GetxController {
  TrackingController(this._locationService, this._api);
  final LocationService _locationService;
  final ApiProvider _api;

  final assignment = Rxn<DispatchAssignment>();
  final driverPosition = Rxn<LatLng>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final routePoints = <LatLng>[].obs;
  StreamSubscription<Position>? _subscription;

  Set<Marker> get markers {
    final current = assignment.value;
    final driver = driverPosition.value;
    return {
      if (driver != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: driver,
          infoWindow: const InfoWindow(title: 'Current location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      if (current?.pickupLatitude != null && current?.pickupLongitude != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(current!.pickupLatitude!, current.pickupLongitude!),
          infoWindow: InfoWindow(title: 'Pickup', snippet: current.pickup),
        ),
      if (current?.destinationLatitude != null &&
          current?.destinationLongitude != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            current!.destinationLatitude!,
            current.destinationLongitude!,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: current.hospital,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
    };
  }

  Set<Polyline> get polylines {
    final directPoints = <LatLng>[
      if (driverPosition.value != null) driverPosition.value!,
      if (assignment.value?.pickupLatitude != null &&
          assignment.value?.pickupLongitude != null)
        LatLng(
          assignment.value!.pickupLatitude!,
          assignment.value!.pickupLongitude!,
        ),
      if (assignment.value?.destinationLatitude != null &&
          assignment.value?.destinationLongitude != null)
        LatLng(
          assignment.value!.destinationLatitude!,
          assignment.value!.destinationLongitude!,
        ),
    ];
    final points = routePoints.isNotEmpty ? routePoints : directPoints;
    return points.length < 2
        ? {}
        : {
            Polyline(
              polylineId: const PolylineId('dispatch_route'),
              points: points,
              color: Colors.red,
              width: 5,
            ),
          };
  }

  @override
  void onInit() {
    super.onInit();
    assignment.value = Get.arguments is DispatchAssignment
        ? Get.arguments as DispatchAssignment
        : null;
    if (assignment.value == null && Get.isRegistered<DashboardController>()) {
      assignment.value = Get.find<DashboardController>().activeAssignment.value;
    }
    startTracking();
  }

  Future<void> startTracking() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final location = await _locationService.getCurrentLocation();
      driverPosition.value = LatLng(location.latitude, location.longitude);
      await _loadRoadRoute();
      await _subscription?.cancel();
      _subscription = _locationService.positionStream().listen(
        (position) => driverPosition.value = LatLng(
          position.latitude,
          position.longitude,
        ),
        onError: (Object error) => errorMessage.value = error.toString(),
      );
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRoadRoute() async {
    final origin = driverPosition.value;
    final current = assignment.value;
    if (origin == null || current == null || AppConfig.mapsApiKey.isEmpty) {
      return;
    }
    final pickup =
        current.pickupLatitude != null && current.pickupLongitude != null
        ? LatLng(current.pickupLatitude!, current.pickupLongitude!)
        : null;
    final destination =
        current.destinationLatitude != null &&
            current.destinationLongitude != null
        ? LatLng(current.destinationLatitude!, current.destinationLongitude!)
        : pickup;
    if (destination == null) return;
    try {
      final response = await _api.client.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': AppConfig.mapsApiKey,
          if (pickup != null && destination != pickup)
            'waypoints': '${pickup.latitude},${pickup.longitude}',
        },
      );
      final data = response.data;
      final routes = data is Map ? data['routes'] : null;
      final route = routes is List && routes.isNotEmpty ? routes.first : null;
      final overview = route is Map ? route['overview_polyline'] : null;
      final encoded = overview is Map ? overview['points'] : null;
      if (encoded is String && encoded.isNotEmpty) {
        routePoints.assignAll(_decodePolyline(encoded));
      }
    } catch (_) {
      // The direct pickup/destination line remains visible when Directions fails.
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;
    while (index < encoded.length) {
      final lat = _decodeValue(encoded, index);
      index = lat.nextIndex;
      latitude += lat.value;
      final lng = _decodeValue(encoded, index);
      index = lng.nextIndex;
      longitude += lng.value;
      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }
    return points;
  }

  ({int value, int nextIndex}) _decodeValue(String encoded, int start) {
    var index = start;
    var result = 0;
    var shift = 0;
    var byte = 0;
    do {
      if (index >= encoded.length) {
        throw const FormatException('Invalid route polyline.');
      }
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    return (
      value: (result & 1) != 0 ? ~(result >> 1) : result >> 1,
      nextIndex: index,
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
