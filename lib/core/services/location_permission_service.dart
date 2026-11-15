import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationPermissionService {
  LocationPermissionService._();

  static Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  static Future<LocationPermissionStatus> checkPermissionOnly() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }
      return LocationPermissionStatus.granted;
    } catch (_) {
      return LocationPermissionStatus.denied;
    }
  }

  static Future<LocationPermissionStatus> checkAndRequestPermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionStatus.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }

      return LocationPermissionStatus.granted;
    } catch (_) {
      return LocationPermissionStatus.denied;
    }
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final status = await checkAndRequestPermission();
      if (status != LocationPermissionStatus.granted) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      try {
        // Fallback to last known position if timeout
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

