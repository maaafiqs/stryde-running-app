import 'dart:convert';

class SplitPace {
  final int km;
  final int durationSeconds;
  final double paceSeconds; // seconds per km
  final double elevationDelta; // meters gained/lost in this km

  const SplitPace({
    required this.km,
    required this.durationSeconds,
    required this.paceSeconds,
    this.elevationDelta = 0.0,
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

  Map<String, dynamic> toMap() {
    return {
      'km': km,
      'durationSeconds': durationSeconds,
      'paceSeconds': paceSeconds,
      'elevationDelta': elevationDelta,
    };
  }

  factory SplitPace.fromMap(Map<String, dynamic> map) {
    return SplitPace(
      km: map['km'] as int,
      durationSeconds: map['durationSeconds'] as int,
      paceSeconds: (map['paceSeconds'] as num).toDouble(),
      elevationDelta: (map['elevationDelta'] as num?)?.toDouble() ?? 0.0,
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
}

