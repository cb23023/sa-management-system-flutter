import 'package:flutter/foundation.dart';

import '../../models/attendance/attendance_session_model.dart';
import '../../services/attendance/location_service.dart';

class LocationController extends ChangeNotifier {
  LocationController({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  final LocationService _locationService;

  bool gpsVerified = false;
  bool identityVerified = false;
  String locationMessage = 'Location not checked yet.';

  double? _currentLatitude;
  double? _currentLongitude;

  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;

  Future<String?> fillCurrentLocation() async {
    final error = await _locationService.getPermissionError();
    if (error != null) return error;

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) return 'Unable to get current location.';
      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;
      notifyListeners();
      return null;
    } catch (_) {
      return 'Unable to get current location.';
    }
  }

  Future<void> checkGeolocation(ScannedSessionData? session) async {
    final error = await _locationService.getPermissionError();
    if (error != null) {
      gpsVerified = false;
      locationMessage = error;
      notifyListeners();
      return;
    }

    if (session == null) {
      gpsVerified = false;
      locationMessage = 'Find the attendance session first.';
      notifyListeners();
      return;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        gpsVerified = false;
        locationMessage = 'Unable to retrieve current location.';
        notifyListeners();
        return;
      }

      final distance = _locationService.distanceBetween(
        position.latitude,
        position.longitude,
        session.latitude,
        session.longitude,
      );
      final withinRange = distance <= session.allowedRadiusMeters;

      gpsVerified = withinRange;
      identityVerified = withinRange;
      locationMessage = withinRange
          ? 'Location valid. ${distance.toStringAsFixed(1)}m from lecturer point.'
          : 'Out of range. ${distance.toStringAsFixed(1)}m away. '
              'Need within ${session.allowedRadiusMeters.toStringAsFixed(0)}m.';
      notifyListeners();
    } catch (_) {
      gpsVerified = false;
      locationMessage = 'Unable to retrieve current location.';
      notifyListeners();
    }
  }

  void reset() {
    gpsVerified = false;
    identityVerified = false;
    locationMessage = 'Location not checked yet.';
    notifyListeners();
  }
}
