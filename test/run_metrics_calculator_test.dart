import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stryde/core/services/run_metrics_calculator.dart';

void main() {
  group('RunMetricsCalculator Tests', () {
    test('Haversine distance between identical coordinates is 0.0', () {
      const p1 = LatLng(-6.2088, 106.8456);
      final distMeters = RunMetricsCalculator.calculateDistanceBetweenMeters(p1, p1);
      expect(distMeters, closeTo(0.0, 0.001));
    });

    test('Haversine distance calculation is accurate against known distance', () {
      // Monas (-6.175392, 106.827153) to Bundaran HI (-6.195000, 106.823000)
      const monas = LatLng(-6.175392, 106.827153);
      const bundaranHi = LatLng(-6.195000, 106.823000);

      final distanceMeters = RunMetricsCalculator.calculateDistanceBetweenMeters(monas, bundaranHi);
      final distanceKm = RunMetricsCalculator.calculateDistanceBetweenKm(monas, bundaranHi);

      // Distance is ~2230 meters (2.23 km)
      expect(distanceMeters, closeTo(2230.0, 50.0));
      expect(distanceKm, closeTo(2.23, 0.05));
    });

    test('Speed to Pace conversion calculates accurate seconds per km', () {
      // 12 km/h = 3.3333 m/s -> 300 seconds/km (5:00 min/km)
      final paceSeconds12kmh = RunMetricsCalculator.speedToPaceSecondsPerKm(3.333333);
      expect(paceSeconds12kmh, closeTo(300.0, 0.5));

      // 10 km/h = 2.7778 m/s -> 360 seconds/km (6:00 min/km)
      final paceSeconds10kmh = RunMetricsCalculator.speedToPaceSecondsPerKm(2.777778);
      expect(paceSeconds10kmh, closeTo(360.0, 0.5));

      // Stationary speed (< 0.5 m/s) returns 0.0
      expect(RunMetricsCalculator.speedToPaceSecondsPerKm(0.2), equals(0.0));
    });

    test('formatPace formats seconds to MM:SS string correctly', () {
      expect(RunMetricsCalculator.formatPace(300), equals('05:00'));
      expect(RunMetricsCalculator.formatPace(324), equals('05:24'));
      expect(RunMetricsCalculator.formatPace(275), equals('04:35'));
      expect(RunMetricsCalculator.formatPace(0), equals('--:--'));
      expect(RunMetricsCalculator.formatPace(-10), equals('--:--'));
      expect(RunMetricsCalculator.formatPace(2000), equals('--:--')); // > 30 min/km
    });

    test('formatDuration formats seconds to HH:MM:SS or MM:SS', () {
      expect(RunMetricsCalculator.formatDuration(45), equals('00:45'));
      expect(RunMetricsCalculator.formatDuration(315), equals('05:15'));
      expect(RunMetricsCalculator.formatDuration(3665), equals('01:01:05'));
    });

    test('calculateAveragePaceSecondsPerKm handles valid and edge inputs', () {
      // 5 km in 1500 seconds (25 minutes) -> 300 sec/km (5:00 pace)
      final avgPace = RunMetricsCalculator.calculateAveragePaceSecondsPerKm(1500, 5.0);
      expect(avgPace, closeTo(300.0, 0.001));

      // Under 50 meters distance returns 0.0 to prevent division distortion
      expect(RunMetricsCalculator.calculateAveragePaceSecondsPerKm(60, 0.02), equals(0.0));
    });

    test('evaluateSplit detects 1.0 km milestone crossing', () {
      final split1 = RunMetricsCalculator.evaluateSplit(
        currentDistanceKm: 1.02,
        currentSplitCount: 0,
        currentMovingTimeSeconds: 310,
        previousSplitCumulativeTimeSeconds: 0,
        currentAltitude: 25.0,
        previousSplitAltitude: 20.0,
      );

      expect(split1, isNotNull);
      expect(split1!.km, equals(1));
      expect(split1.durationSeconds, equals(310));
      expect(split1.formattedPace, equals('05:10'));
      expect(split1.elevationDelta, equals(5.0));

      // Below next milestone (need 2.0 km) returns null
      final noSplit = RunMetricsCalculator.evaluateSplit(
        currentDistanceKm: 1.85,
        currentSplitCount: 1,
        currentMovingTimeSeconds: 580,
        previousSplitCumulativeTimeSeconds: 310,
        currentAltitude: 28.0,
        previousSplitAltitude: 25.0,
      );
      expect(noSplit, isNull);
    });

    test('calculateCalories computes runner caloric expenditure', () {
      // 5 km run for 68 kg runner = ~352 kcal
      final cal = RunMetricsCalculator.calculateCalories(distanceKm: 5.0, runnerWeightKg: 68.0);
      expect(cal, closeTo(352.24, 0.5));
    });
  });
}

