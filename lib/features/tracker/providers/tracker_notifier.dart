import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
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
  StreamSubscription<Position>? _standbySubscription;
  Timer? _timer;

  int _stillTicksCount = 0;
  int _lastSplitCumulativeTime = 0;
  double _lastSplitAltitude = 0.0;
  bool _pendingResumePoint = false;

  TrackerNotifier(this._db) : super(const TrackingState()) {
    _initDefaultShoe();
  }

  Future<void> _initDefaultShoe() async {
    final defaultShoe = await _db.getDefaultShoe();
    if (defaultShoe != null) {
      state = state.copyWith(activeShoeId: drift.Value(defaultShoe.id));
    }
  }

  void setShoe(int? shoeId) {
    state = state.copyWith(activeShoeId: drift.Value(shoeId));
  }

  void setActivityType(StrydeActivityType type) {
    if (state.isActive) return;
    state = state.copyWith(activityType: type);
  }

  void toggleAutoPause() {
    state = state.copyWith(autoPauseEnabled: !state.autoPauseEnabled);
  }

  Future<LatLng?> refreshCurrentLocation() async {
    final position = await LocationPermissionService.getCurrentPosition();
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      state = state.copyWith(
        currentPosition: drift.Value(latLng),
        currentAltitude: position.altitude,
      );
      return latLng;
    }
    return null;
  }

  void startStandbyLocation() {
    if (state.isActive) return;
    _standbySubscription?.cancel();

    // Fast initial fetch
    refreshCurrentLocation();

    const standbySettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _standbySubscription = Geolocator.getPositionStream(
      locationSettings: standbySettings,
    ).listen(
      (position) {
        if (state.isActive) return;
        state = state.copyWith(
          currentPosition: drift.Value(LatLng(position.latitude, position.longitude)),
          currentAltitude: position.altitude,
        );
      },
      onError: (_) {},
    );
  }

  void stopStandbyLocation() {
    _standbySubscription?.cancel();
    _standbySubscription = null;
  }

  Future<bool> startTracking() async {
    final status = await LocationPermissionService.checkAndRequestPermission();
    if (status != LocationPermissionStatus.granted) {
      return false;
    }

    // Stop standby updates when recording starts
    _standbySubscription?.cancel();
    _standbySubscription = null;

    // Reset internal state
    _driftFilter.reset();
    _stillTicksCount = 0;
    _lastSplitCumulativeTime = 0;
    _lastSplitAltitude = 0.0;
    _pendingResumePoint = false;

    // Start background foreground service & wakelock safely
    try {
      await BackgroundServiceManager.startService();
    } catch (_) {}

    final now = DateTime.now();
    final initialPos = state.currentPosition;
    final initialAlt = state.currentAltitude;
    final initialAcc = state.gpsAccuracy;

    state = TrackingState(
      status: TrackingStatus.running,
      activityType: state.activityType,
      startTime: now,
      autoPauseEnabled: state.autoPauseEnabled,
      activeShoeId: state.activeShoeId,
      currentPosition: initialPos,
      currentAltitude: initialAlt,
      gpsAccuracy: initialAcc,
    );

    // Start second-by-second timer
    _startTimer();

    // Start high-precision location updates adapted for real-time tracking
    late final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0, // 0 meter filter for instantaneous real-time position updates
        intervalDuration: const Duration(seconds: 1), // 1 second updates
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

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
      final activityPrefix = state.isWalking ? 'Walk' : 'Run';
      BackgroundServiceManager.updateNotification(
        distance: '$activityPrefix • ${state.distanceKm.toStringAsFixed(2)} km',
        duration: RunMetricsCalculator.formatDuration(newMovingTime),
        pace: state.isWalking
            ? '${state.currentSpeedKmh.toStringAsFixed(1)} km/h'
            : RunMetricsCalculator.formatPace(state.currentPaceSeconds),
      );
    });
  }

  void _onPositionUpdate(Position position) {
    if (state.status != TrackingStatus.running) return;

    final currentLatLng = LatLng(position.latitude, position.longitude);

    // Reject wild GPS spikes (> 45m accuracy error)
    if (position.accuracy > 45.0) return;

    // Always update current position and accuracy in real-time so marker and camera follow smoothly
    state = state.copyWith(
      currentPosition: drift.Value(currentLatLng),
      currentAltitude: position.altitude,
      gpsAccuracy: position.accuracy,
    );

    // Apply GPS drift filter
    final bool isValid = _driftFilter.isValidPoint(position);
    if (!isValid) return;

    // Calculate displacement from last recorded point in meters
    double displacementMeters = 0.0;
    if (state.coordinates.isNotEmpty) {
      displacementMeters = RunMetricsCalculator.calculateDistanceBetweenMeters(
        state.coordinates.last,
        currentLatLng,
      );
    }

    // Auto-Pause logic:
    // Only engage if autoPauseEnabled is true and session has run for at least 8 seconds
    if (state.autoPauseEnabled && state.durationSeconds > 8) {
      final double pauseThreshold = state.isWalking ? 0.35 : 0.8;
      final double resumeThreshold = state.isWalking ? 0.5 : 1.0;

      // User is moving if displacement is >= 1.5m or reported speed >= resumeThreshold
      final bool isMoving = displacementMeters >= 1.5 || position.speed >= resumeThreshold;
      final bool isStationary = displacementMeters < 0.8 && position.speed < pauseThreshold;

      if (isStationary) {
        _stillTicksCount++;
        if (_stillTicksCount >= 4 && !state.isAutoPaused) {
          state = state.copyWith(isAutoPaused: true);
        }
      } else if (isMoving) {
        _stillTicksCount = 0;
        if (state.isAutoPaused) {
          state = state.copyWith(isAutoPaused: false);
          _pendingResumePoint = true;
        }
      }
    } else if (!state.autoPauseEnabled && state.isAutoPaused) {
      state = state.copyWith(isAutoPaused: false);
    }

    // If auto-paused, only update position marker on map, do not accumulate distance
    if (state.isAutoPaused) {
      state = state.copyWith(
        currentPosition: drift.Value(currentLatLng),
        currentAltitude: position.altitude,
      );
      return;
    }

    // Distance accumulation
    final double addedDistanceKm = displacementMeters / 1000.0;
    final double newTotalDistance = state.distanceKm + addedDistanceKm;

    // Calculate effective speed (m/s):
    // Use position.speed if > 0.2 m/s, otherwise calculate from displacement / time delta
    double effectiveSpeedMps = position.speed;
    if (effectiveSpeedMps <= 0.2 && state.coordinates.isNotEmpty && _driftFilter.lastValidPosition != null) {
      final prevTime = _driftFilter.lastValidPosition!.timestamp;
      final double timeDiffSec =
          position.timestamp.difference(prevTime).inMilliseconds / 1000.0;
      if (timeDiffSec > 0.5 && timeDiffSec < 10.0) {
        effectiveSpeedMps = displacementMeters / timeDiffSec;
      }
    }

    final double currentSpeed = RunMetricsCalculator.speedMpsToKmh(effectiveSpeedMps);
    final double maxSpeed =
        currentSpeed > state.maxSpeedKmh ? currentSpeed : state.maxSpeedKmh;
    final double currentPace =
        RunMetricsCalculator.speedToPaceSecondsPerKm(effectiveSpeedMps);

    // Elevation calculation
    double addedElevation = 0.0;
    if (state.coordinates.isNotEmpty && position.altitude > state.currentAltitude) {
      addedElevation = position.altitude - state.currentAltitude;
    }
    final double newElevation = state.elevationGain + addedElevation;

    // Calories adapted for walk vs run
    final double calories = RunMetricsCalculator.calculateCalories(
      distanceKm: newTotalDistance,
      isWalking: state.isWalking,
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
    try {
      await BackgroundServiceManager.stopService();
    } catch (_) {}

    final endTime = DateTime.now();
    final startTime = state.startTime ?? endTime.subtract(Duration(seconds: state.durationSeconds));

    final String title = _generateRunTitle(startTime);
    final splitsJson = SplitPace.listToJson(state.splits);

    // Save Activity to Drift DB
    final activityCompanion = ActivitiesCompanion.insert(
      title: title,
      activityType: drift.Value(state.isWalking ? 'walk' : 'run'),
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
    _standbySubscription?.cancel();
    final currentShoeId = state.activeShoeId;
    state = TrackingState(activeShoeId: currentShoeId);
    startStandbyLocation();
  }

  String _generateRunTitle(DateTime startTime) {
    final hour = startTime.hour;
    final activityName = state.isWalking ? 'Walk' : 'Stryde';
    if (hour >= 4 && hour < 11) {
      return 'Morning $activityName';
    } else if (hour >= 11 && hour < 15) {
      return 'Midday $activityName';
    } else if (hour >= 15 && hour < 18) {
      return 'Afternoon $activityName';
    } else {
      return 'Night $activityName';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _standbySubscription?.cancel();
    super.dispose();
  }
}

