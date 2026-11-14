import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'run_metrics_calculator.dart';

class GpsDriftFilter {
  final double maxAllowedAccuracyMeters;
  final double minDisplacementMeters;
  final double maxAllowedSpeedMps; // Max reasonable running speed (~12.5 m/s = 45 km/h)

  Position? _lastValidPosition;

  GpsDriftFilter({
    this.maxAllowedAccuracyMeters = 20.0,
    this.minDisplacementMeters = 2.0,
    this.maxAllowedSpeedMps = 12.5,
  });

  void reset() {
    _lastValidPosition = null;
  }

  /// Evaluates whether a new GPS [Position] is valid and should be appended.
  bool isValidPoint(Position current) {
    // 1. Accuracy Check: Ignore points with low accuracy (> 20m)
    if (current.accuracy > maxAllowedAccuracyMeters) {
      return false;
    }

    // First point is always accepted if accuracy is acceptable
    if (_lastValidPosition == null) {
      _lastValidPosition = current;
      return true;
    }

    final Position previous = _lastValidPosition!;

    // 2. Calculate actual displacement using Haversine
    final double displacement = RunMetricsCalculator.calculateDistanceBetweenMeters(
      LatLng(previous.latitude, previous.longitude),
      LatLng(current.latitude, current.longitude),
    );

    // 3. Jitter filter while stationary:
    // If movement is under minimum displacement threshold (2m) and reported speed is low (< 0.8 m/s),
    // it's stationary drift jitter
    final double reportedSpeed = current.speed;
    if (displacement < minDisplacementMeters && reportedSpeed < 0.8) {
      return false;
    }

    // 4. Anomaly jump filter:
    // If time difference is small but displacement requires superhuman speed (> 12.5 m/s)
    final double timeDiffSeconds =
        current.timestamp.difference(previous.timestamp).inMilliseconds / 1000.0;
    if (timeDiffSeconds > 0) {
      final double calculatedSpeedMps = displacement / timeDiffSeconds;
      if (calculatedSpeedMps > maxAllowedSpeedMps && displacement > 15.0) {
        return false;
      }
    }

    _lastValidPosition = current;
    return true;
  }

  Position? get lastValidPosition => _lastValidPosition;
}

