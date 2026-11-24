import 'dart:convert';

class SplitPace {
  final int km;
  final int durationSeconds;
  final double paceSeconds; // seconds per km
  final double elevationDelta; // meters gained/lost in this km
  final double distanceKm; // e.g. 1.0 or partial e.g. 0.45
  final bool isPartial;

  const SplitPace({
    required this.km,
    required this.durationSeconds,
    required this.paceSeconds,
    this.elevationDelta = 0.0,
    this.distanceKm = 1.0,
    this.isPartial = false,
  });

  /// Formatted pace string like "05:12"
  String get formattedPace {
    if (paceSeconds <= 0 || paceSeconds.isInfinite || paceSeconds.isNaN) {
      return "--:--";
    }
    final int minutes = (paceSeconds / 60).floor();
    final int seconds = (paceSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Speed in km/h derived from pace
  double get speedKmh => paceSeconds > 0 ? (3600 / paceSeconds) : 0.0;

  /// Formatted speed string like "5.4 km/h"
  String get formattedSpeed => '${speedKmh.toStringAsFixed(1)} km/h';

  /// Label for split table, e.g. "1" or "4*" or "< 1 KM"
  String get displayLabel {
    if (isPartial) {
      if (km <= 1 && distanceKm < 1.0) {
        return '< 1 KM';
      }
      return '$km*';
    }
    return '$km';
  }

  Map<String, dynamic> toMap() {
    return {
      'km': km,
      'durationSeconds': durationSeconds,
      'paceSeconds': paceSeconds,
      'elevationDelta': elevationDelta,
      'distanceKm': distanceKm,
      'isPartial': isPartial,
    };
  }

  factory SplitPace.fromMap(Map<String, dynamic> map) {
    return SplitPace(
      km: map['km'] as int,
      durationSeconds: map['durationSeconds'] as int,
      paceSeconds: (map['paceSeconds'] as num).toDouble(),
      elevationDelta: (map['elevationDelta'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 1.0,
      isPartial: map['isPartial'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  static List<SplitPace> listFromJson(String jsonStr) {
    if (jsonStr.isEmpty || jsonStr == '[]') return [];
    try {
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((e) => SplitPace.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<SplitPace> splits) {
    return json.encode(splits.map((s) => s.toMap()).toList());
  }

  /// Builds a complete list of splits, accounting for full kilometers,
  /// any final partial kilometer, or sessions under 1 km.
  static List<SplitPace> completeSplits({
    required List<SplitPace> existingSplits,
    required double totalDistanceKm,
    required int totalMovingTimeSeconds,
    required double totalElevationGain,
  }) {
    if (totalDistanceKm <= 0) return existingSplits;

    // Case 1: Total distance is under 1.0 km (e.g. 0.05 km test walk or 600m walk)
    if (existingSplits.isEmpty && totalDistanceKm < 1.0) {
      final double pace = totalDistanceKm > 0
          ? (totalMovingTimeSeconds / totalDistanceKm)
          : 0.0;
      return [
        SplitPace(
          km: 1,
          durationSeconds: totalMovingTimeSeconds,
          paceSeconds: pace,
          elevationDelta: totalElevationGain,
          distanceKm: totalDistanceKm,
          isPartial: true,
        ),
      ];
    }

    final result = List<SplitPace>.from(existingSplits);

    // Case 2: There are completed splits, but remaining distance exists
    // (e.g. totalDistance is 2.45 km, but existingSplits has 2 splits)
    final int completedKm = existingSplits.length;
    final double remainingDistanceKm = totalDistanceKm - completedKm;

    if (remainingDistanceKm >= 0.05) {
      int sumCompletedSeconds = 0;
      for (final s in existingSplits) {
        sumCompletedSeconds += s.durationSeconds;
      }
      final int remainingSeconds = (totalMovingTimeSeconds - sumCompletedSeconds).clamp(0, 999999);
      final double partialPace = remainingDistanceKm > 0 ? (remainingSeconds / remainingDistanceKm) : 0.0;

      result.add(
        SplitPace(
          km: completedKm + 1,
          durationSeconds: remainingSeconds,
          paceSeconds: partialPace,
          elevationDelta: 0.0,
          distanceKm: remainingDistanceKm,
          isPartial: true,
        ),
      );
    }

    return result;
  }
}
