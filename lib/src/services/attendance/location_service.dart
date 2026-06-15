import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 15),
  );

  Future<Position?> getCurrentPosition() async {
    final error = await getPermissionError();
    if (error != null) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
    } on TimeoutException {
      return Geolocator.getLastKnownPosition();
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

  Future<String?> getPermissionError() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are turned off. Enable GPS on this device/emulator.';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return 'Location permission was not granted.';
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permission is permanently denied. Enable it from app settings.';
      }

      return null;
    } catch (_) {
      return 'Location permission failed. Rebuild/reinstall the Android app, then enable location permission.';
    }
  }

  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  bool isWithinRadius(
    Position position,
    double targetLatitude,
    double targetLongitude,
    double radiusMeters,
  ) {
    final distance = distanceBetween(
      position.latitude,
      position.longitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= radiusMeters;
  }
}
