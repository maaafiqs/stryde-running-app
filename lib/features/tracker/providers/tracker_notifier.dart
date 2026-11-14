import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/models/split_pace.dart';
import '../../../core/services/background_service_manager.dart';
import '../../../core/services/gps_drift_filter.dart';
import '../../../core/services/location_permission_service.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../models/tracking_state.dart';

final trackerProvider = StateNotifierProvider<TrackerNotifier, TrackingState>((ref) {
  final db = ref.watch(databaseProvider);
  return TrackerNotifier(db);
});

class TrackerNotifier extends StateNotifier<TrackingState> {
  final StrydeDatabase _db;
  final GpsDriftFilter _driftFilter = GpsDriftFilter();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;

  int _stillTicksCount = 0;
  int _lastSplitCumulativeTime = 0;
  double _lastSplitAltitude = 0.0;
  bool _pendingResumePoint = false;

  TrackerNotifier(this._db) : super(const TrackingState());

  void setShoe(int? shoeId) {
    state = state.copyWith(activeShoeId: drift.Value(shoeId));
  }

  void toggleAutoPause() {
    state = state.copyWith(autoPauseEnabled: !state.autoPauseEnabled);
  }

  Future<bool> startTracking() async {
    final status = await LocationPermissionService.checkAndRequestPermission();
    if (status != LocationPermissionStatus.granted) {
      return false;
    }

    // Reset internal state
    _driftFilter.reset();
    _stillTicksCount = 0;
    _lastSplitCumulativeTime = 0;
    _lastSplitAltitude = 0.0;
    _pendingResumePoint = false;

    // Start background foreground service & wakelock
    await BackgroundServiceManager.startService();

    final now = DateTime.now();
    state = TrackingState(
      status: TrackingStatus.running,
      startTime: now,
      autoPauseEnabled: state.autoPauseEnabled,
      activeShoeId: state.activeShoeId,
    );

    // Start second-by-second timer
    _startTimer();

    // Start high-precision location updates
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onPositionUpdate);

    return true;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status != TrackingStatus.running) return;

      final int newDuration = state.durationSeconds + 1;
      final int newMovingTime =
          state.isAutoPaused ? state.movingTimeSeconds : state.movingTimeSeconds + 1;

      final double avgPace = RunMetricsCalculator.calculateAveragePaceSecondsPerKm(
        newMovingTime,
        state.distanceKm,
      );

      state = state.copyWith(
        durationSeconds: newDuration,
        movingTimeSeconds: newMovingTime,
        averagePaceSeconds: avgPace,
      );

      // Update background notification
      BackgroundServiceManager.updateNotification(
        distance: '${state.distanceKm.toStringAsFixed(2)} km',
        duration: RunMetricsCalculator.formatDuration(newMovingTime),
        pace: RunMetricsCalculator.formatPace(state.currentPaceSeconds),
      );
    });
  }

  void _onPositionUpdate(Position position) {
    if (state.status != TrackingStatus.running) return;

    final currentLatLng = LatLng(position.latitude, position.longitude);

    // Apply GPS drift filter
    final bool isValid = _driftFilter.isValidPoint(position);
    if (!isValid) return;

    // Check Auto-Pause logic
    if (state.autoPauseEnabled) {
      if (position.speed < 0.8) {
        _stillTicksCount++;
        if (_stillTicksCount >= 4 && !state.isAutoPaused) {
          state = state.copyWith(isAutoPaused: true);
        }
      } else if (position.speed >= 1.2) {
        _stillTicksCount = 0;
        if (state.isAutoPaused) {
          state = state.copyWith(isAutoPaused: false);
          _pendingResumePoint = true;
        }
      }
    }

    if (state.isAutoPaused) {
      state = state.copyWith(
        currentPosition: drift.Value(currentLatLng),
        currentAltitude: position.altitude,
      );
      return;
    }

    double addedDistance = 0.0;
    if (state.coordinates.isNotEmpty) {
      final lastPoint = state.coordinates.last;
      addedDistance = RunMetricsCalculator.calculateDistanceBetweenKm(
        lastPoint,
        currentLatLng,
      );
    }

    final double newTotalDistance = state.distanceKm + addedDistance;
    final double currentSpeed = RunMetricsCalculator.speedMpsToKmh(position.speed);
    final double maxSpeed =
        currentSpeed > state.maxSpeedKmh ? currentSpeed : state.maxSpeedKmh;
    final double currentPace =
        RunMetricsCalculator.speedToPaceSecondsPerKm(position.speed);

    // Elevation calculation
    double addedElevation = 0.0;
    if (state.coordinates.isNotEmpty && position.altitude > state.currentAltitude) {
      addedElevation = position.altitude - state.currentAltitude;
    }
    final double newElevation = state.elevationGain + addedElevation;

    // Calories
    final double calories = RunMetricsCalculator.calculateCalories(
      distanceKm: newTotalDistance,
    );

    // Evaluate 1.0 km Split
    final List<SplitPace> updatedSplits = List<SplitPace>.from(state.splits);
    final newSplit = RunMetricsCalculator.evaluateSplit(
      currentDistanceKm: newTotalDistance,
      currentSplitCount: updatedSplits.length,
      currentMovingTimeSeconds: state.movingTimeSeconds,
      previousSplitCumulativeTimeSeconds: _lastSplitCumulativeTime,
      currentAltitude: position.altitude,
      previousSplitAltitude: _lastSplitAltitude,
    );

    if (newSplit != null) {
      updatedSplits.add(newSplit);
      _lastSplitCumulativeTime = state.movingTimeSeconds;
      _lastSplitAltitude = position.altitude;
    }

    // Build TrackPoint for DB
    final trackPointCompanion = TrackPointsCompanion.insert(
      activityId: 0, // Will be updated on save
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: drift.Value(position.altitude),
      speed: drift.Value(position.speed),
      accuracy: drift.Value(position.accuracy),
      timestamp: position.timestamp,
      isPausedPoint: drift.Value(_pendingResumePoint),
    );
    _pendingResumePoint = false;

    state = state.copyWith(
      distanceKm: newTotalDistance,
      currentPaceSeconds: currentPace,
      currentSpeedKmh: currentSpeed,
      maxSpeedKmh: maxSpeed,
      elevationGain: newElevation,
      calories: calories,
      splits: updatedSplits,
      coordinates: [...state.coordinates, currentLatLng],
      trackPoints: [...state.trackPoints, trackPointCompanion],
      currentPosition: drift.Value(currentLatLng),
      currentAltitude: position.altitude,
    );
  }

  void pauseTracking() {
    if (state.status != TrackingStatus.running) return;
    _pendingResumePoint = true;
    state = state.copyWith(
      status: TrackingStatus.paused,
      isAutoPaused: false,
    );
  }

  void resumeTracking() {
    if (state.status != TrackingStatus.paused) return;
    state = state.copyWith(
      status: TrackingStatus.running,
      isAutoPaused: false,
    );
  }

  Future<int?> finishTracking() async {
    if (!state.isActive && state.distanceKm <= 0.0) return null;

    _timer?.cancel();
    await _positionSubscription?.cancel();
    await BackgroundServiceManager.stopService();

    final endTime = DateTime.now();
    final startTime = state.startTime ?? endTime.subtract(Duration(seconds: state.durationSeconds));

    final String title = _generateRunTitle(startTime);
    final splitsJson = SplitPace.listToJson(state.splits);

    // Save Activity to Drift DB
    final activityCompanion = ActivitiesCompanion.insert(
      title: title,
      startTime: startTime,
      endTime: endTime,
      distanceKm: state.distanceKm,
      durationSeconds: state.durationSeconds,
      movingTimeSeconds: state.movingTimeSeconds,
      avgPaceSecondsPerKm: state.averagePaceSeconds,
      maxPaceSecondsPerKm: drift.Value(state.maxSpeedKmh > 0 ? (3600 / state.maxSpeedKmh) : 0.0),
      avgSpeedKmh: drift.Value(
        state.movingTimeSeconds > 0
            ? (state.distanceKm / (state.movingTimeSeconds / 3600))
            : 0.0,
      ),
      maxSpeedKmh: drift.Value(state.maxSpeedKmh),
      elevationGainMeters: drift.Value(state.elevationGain),
      caloriesBurned: drift.Value(state.calories),
      shoeId: drift.Value(state.activeShoeId),
      splitPacesJson: drift.Value(splitsJson),
    );

    final activityId = await _db.insertActivity(activityCompanion);

    // Save track points with activityId
    if (state.trackPoints.isNotEmpty) {
      final pointsWithId = state.trackPoints.map((pt) {
        return pt.copyWith(activityId: drift.Value(activityId));
      }).toList();
      await _db.insertTrackPointsBatch(pointsWithId);
    }

    // Update shoe mileage if shoe selected
    if (state.activeShoeId != null) {
      await _db.addMileageToShoe(state.activeShoeId!, state.distanceKm);
    }

    state = state.copyWith(status: TrackingStatus.finished);
    return activityId;
  }

  void reset() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    state = const TrackingState();
  }

  String _generateRunTitle(DateTime startTime) {
    final hour = startTime.hour;
    if (hour >= 4 && hour < 11) {
      return 'Morning Stryde';
    } else if (hour >= 11 && hour < 15) {
      return 'Midday Stryde';
    } else if (hour >= 15 && hour < 18) {
      return 'Afternoon Stryde';
    } else {
      return 'Night Stryde';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}

