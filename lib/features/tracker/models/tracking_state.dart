import 'package:drift/drift.dart' as drift;
import 'package:latlong2/latlong.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/models/split_pace.dart';
import '../../../core/services/run_metrics_calculator.dart';

enum TrackingStatus {
  idle,
  running,
  paused,
  finished,
}

enum StrydeActivityType {
  run,
  walk,
}

class TrackingState {
  final TrackingStatus status;
  final StrydeActivityType activityType;
  final double distanceKm;
  final int durationSeconds;
  final int movingTimeSeconds;
  final double currentPaceSeconds;
  final double averagePaceSeconds;
  final double currentSpeedKmh;
  final double maxSpeedKmh;
  final double elevationGain;
  final double calories;
  final List<SplitPace> splits;
  final List<LatLng> coordinates;
  final List<TrackPointsCompanion> trackPoints;
  final LatLng? currentPosition;
  final double currentAltitude;
  final bool autoPauseEnabled;
  final bool isAutoPaused;
  final int? activeShoeId;
  final DateTime? startTime;
  final double gpsAccuracy;

  const TrackingState({
    this.status = TrackingStatus.idle,
    this.activityType = StrydeActivityType.run,
    this.distanceKm = 0.0,
    this.durationSeconds = 0,
    this.movingTimeSeconds = 0,
    this.currentPaceSeconds = 0.0,
    this.averagePaceSeconds = 0.0,
    this.currentSpeedKmh = 0.0,
    this.maxSpeedKmh = 0.0,
    this.elevationGain = 0.0,
    this.calories = 0.0,
    this.splits = const [],
    this.coordinates = const [],
    this.trackPoints = const [],
    this.currentPosition,
    this.currentAltitude = 0.0,
    this.autoPauseEnabled = false,
    this.isAutoPaused = false,
    this.activeShoeId,
    this.startTime,
    this.gpsAccuracy = 0.0,
  });

  bool get isActive => status == TrackingStatus.running || status == TrackingStatus.paused;
  bool get isRunning => status == TrackingStatus.running && !isAutoPaused;
  bool get isWalking => activityType == StrydeActivityType.walk;
  int get estimatedSteps =>
      RunMetricsCalculator.estimateSteps(distanceKm: distanceKm, isWalking: isWalking);

  TrackingState copyWith({
    TrackingStatus? status,
    StrydeActivityType? activityType,
    double? distanceKm,
    int? durationSeconds,
    int? movingTimeSeconds,
    double? currentPaceSeconds,
    double? averagePaceSeconds,
    double? currentSpeedKmh,
    double? maxSpeedKmh,
    double? elevationGain,
    double? calories,
    List<SplitPace>? splits,
    List<LatLng>? coordinates,
    List<TrackPointsCompanion>? trackPoints,
    drift.Value<LatLng?>? currentPosition,
    double? currentAltitude,
    bool? autoPauseEnabled,
    bool? isAutoPaused,
    drift.Value<int?>? activeShoeId,
    DateTime? startTime,
    double? gpsAccuracy,
  }) {
    return TrackingState(
      status: status ?? this.status,
      activityType: activityType ?? this.activityType,
      distanceKm: distanceKm ?? this.distanceKm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
      currentPaceSeconds: currentPaceSeconds ?? this.currentPaceSeconds,
      averagePaceSeconds: averagePaceSeconds ?? this.averagePaceSeconds,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      elevationGain: elevationGain ?? this.elevationGain,
      calories: calories ?? this.calories,
      splits: splits ?? this.splits,
      coordinates: coordinates ?? this.coordinates,
      trackPoints: trackPoints ?? this.trackPoints,
      currentPosition:
          currentPosition != null ? currentPosition.value : this.currentPosition,
      currentAltitude: currentAltitude ?? this.currentAltitude,
      autoPauseEnabled: autoPauseEnabled ?? this.autoPauseEnabled,
      isAutoPaused: isAutoPaused ?? this.isAutoPaused,
      activeShoeId: activeShoeId != null ? activeShoeId.value : this.activeShoeId,
      startTime: startTime ?? this.startTime,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
    );
  }
}

