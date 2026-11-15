import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/split_pace.dart';

class RunMetricsCalculator {
  RunMetricsCalculator._();

  static const double earthRadiusMeters = 6371000.0;
  static const Distance _distance = Distance();

  /// Calculates the Haversine distance between two [LatLng] points in meters.
  static double calculateDistanceBetweenMeters(LatLng point1, LatLng point2) {
    return _distance.as(LengthUnit.Meter, point1, point2);
  }

  /// Calculates the Haversine distance between two [LatLng] points in kilometers.
  static double calculateDistanceBetweenKm(LatLng point1, LatLng point2) {
    return calculateDistanceBetweenMeters(point1, point2) / 1000.0;
  }

  /// Pure mathematical Haversine implementation for verification and unit testing.
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double phi1 = lat1 * math.pi / 180.0;
    final double phi2 = lat2 * math.pi / 180.0;
    final double deltaPhi = (lat2 - lat1) * math.pi / 180.0;
    final double deltaLambda = (lon2 - lon1) * math.pi / 180.0;

    final double a = math.sin(deltaPhi / 2.0) * math.sin(deltaPhi / 2.0) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2.0) *
            math.sin(deltaLambda / 2.0);

    final double c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return earthRadiusMeters * c;
  }

  /// Converts speed (meters per second) to Pace in seconds per kilometer.
  /// Returns 0 if speed is below human walking threshold (< 0.5 m/s).
  static double speedToPaceSecondsPerKm(double speedMps) {
    if (speedMps < 0.5) {
      return 0.0;
    }
    return 1000.0 / speedMps;
  }

  /// Formats pace in seconds per kilometer into "MM:SS" (e.g. 324 seconds -> "05:24").
  static String formatPace(double paceSecondsPerKm) {
    if (paceSecondsPerKm <= 0 ||
        paceSecondsPerKm.isInfinite ||
        paceSecondsPerKm.isNaN ||
        paceSecondsPerKm > 1800) {
      // Pace slower than 30:00 min/km is rendered as --:--
      return '--:--';
    }
    final int minutes = (paceSecondsPerKm / 60).floor();
    final int seconds = (paceSecondsPerKm % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calculates average pace given moving time (seconds) and distance (km).
  static double calculateAveragePaceSecondsPerKm(int movingTimeSeconds, double distanceKm) {
    if (distanceKm < 0.05 || movingTimeSeconds <= 0) {
      return 0.0;
    }
    return movingTimeSeconds / distanceKm;
  }

  /// Converts speed in m/s to km/h.
  static double speedMpsToKmh(double speedMps) {
    return speedMps * 3.6;
  }

  /// Estimates calories burned (assuming standard weight of 68kg, MET ~ 1.036 for run, ~0.72 for walk).
  static double calculateCalories({
    required double distanceKm,
    double runnerWeightKg = 68.0,
    bool isWalking = false,
  }) {
    if (distanceKm <= 0) return 0.0;
    final double factor = isWalking ? 0.72 : 1.036;
    return distanceKm * runnerWeightKg * factor;
  }

  /// Estimates steps based on distance and activity type.
  /// Walking: ~1,350 steps/km (average stride length ~0.74m)
  /// Running: ~1,050 steps/km (average stride length ~0.95m)
  static int estimateSteps({required double distanceKm, required bool isWalking}) {
    if (distanceKm <= 0) return 0;
    final double stepsPerKm = isWalking ? 1350.0 : 1050.0;
    return (distanceKm * stepsPerKm).round();
  }

  /// Checks if a new split kilometer milestone has been reached.
  /// If reached, returns the newly completed [SplitPace].
  static SplitPace? evaluateSplit({
    required double currentDistanceKm,
    required int currentSplitCount,
    required int currentMovingTimeSeconds,
    required int previousSplitCumulativeTimeSeconds,
    required double currentAltitude,
    required double previousSplitAltitude,
  }) {
    final int nextTargetKm = currentSplitCount + 1;
    if (currentDistanceKm >= nextTargetKm) {
      final int splitDurationSeconds =
          currentMovingTimeSeconds - previousSplitCumulativeTimeSeconds;
      final double paceSeconds = splitDurationSeconds.toDouble();
      final double elevationDelta = currentAltitude - previousSplitAltitude;

      return SplitPace(
        km: nextTargetKm,
        durationSeconds: splitDurationSeconds,
        paceSeconds: paceSeconds,
        elevationDelta: elevationDelta,
      );
    }
    return null;
  }

  /// Formats seconds to "HH:MM:SS" or "MM:SS".
  static String formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
