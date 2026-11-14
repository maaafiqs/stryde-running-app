import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stryde/core/services/gps_drift_filter.dart';

void main() {
  group('GpsDriftFilter Tests', () {
    late GpsDriftFilter filter;

    setUp(() {
      filter = GpsDriftFilter(
        maxAllowedAccuracyMeters: 20.0,
        minDisplacementMeters: 2.0,
      );
    });

    Position createPos({
      required double lat,
      required double lon,
      double accuracy = 5.0,
      double speed = 3.0,
      DateTime? timestamp,
    }) {
      return Position(
        latitude: lat,
        longitude: lon,
        timestamp: timestamp ?? DateTime.now(),
        accuracy: accuracy,
        altitude: 10.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: speed,
        speedAccuracy: 0.5,
      );
    }

    test('Rejects GPS point with poor accuracy (> 20 meters)', () {
      final badAccuracyPoint = createPos(
        lat: -6.2088,
        lon: 106.8456,
        accuracy: 25.0, // Exceeds 20m threshold
      );

      final accepted = filter.isValidPoint(badAccuracyPoint);
      expect(accepted, isFalse);
    });

    test('Accepts initial point with good accuracy', () {
      final initialPoint = createPos(
        lat: -6.2088,
        lon: 106.8456,
        accuracy: 8.0,
      );

      final accepted = filter.isValidPoint(initialPoint);
      expect(accepted, isTrue);
      expect(filter.lastValidPosition, equals(initialPoint));
    });

    test('Filters out stationary jitter when displacement is under 2m and speed < 0.8 m/s', () {
      final p1 = createPos(
        lat: -6.208800,
        lon: 106.845600,
        accuracy: 5.0,
        speed: 2.5,
      );
      expect(filter.isValidPoint(p1), isTrue);

      // Micro movement of ~0.5m with low speed (stationary drift)
      final jitter = createPos(
        lat: -6.208803,
        lon: 106.845602,
        accuracy: 5.0,
        speed: 0.2, // Below 0.8 m/s resting speed threshold
      );

      expect(filter.isValidPoint(jitter), isFalse);
    });

    test('Accepts valid running progress points', () {
      final p1 = createPos(
        lat: -6.208800,
        lon: 106.845600,
        accuracy: 5.0,
        speed: 3.0,
        timestamp: DateTime(2026, 1, 1, 8, 0, 0),
      );
      expect(filter.isValidPoint(p1), isTrue);

      // Progressive point ~25 meters away after 5 seconds (~5 m/s)
      final p2 = createPos(
        lat: -6.209000,
        lon: 106.845600,
        accuracy: 5.0,
        speed: 3.2,
        timestamp: DateTime(2026, 1, 1, 8, 0, 5),
      );

      expect(filter.isValidPoint(p2), isTrue);
    });
  });
}

