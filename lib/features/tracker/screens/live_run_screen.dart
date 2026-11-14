import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import '../../history/screens/activity_detail_screen.dart';
import '../models/tracking_state.dart';
import '../providers/tracker_notifier.dart';
import '../widgets/slide_to_finish_button.dart';

class LiveRunScreen extends ConsumerStatefulWidget {
  const LiveRunScreen({super.key});

  @override
  ConsumerState<LiveRunScreen> createState() => _LiveRunScreenState();
}

class _LiveRunScreenState extends ConsumerState<LiveRunScreen> {
  final MapController _mapController = MapController();
  bool _followRunner = true;

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackerProvider);
    final trackerNotifier = ref.read(trackerProvider.notifier);
    final shoesAsync = ref.watch(shoesStreamProvider);

    // Keep map centered on user when active
    if (_followRunner && trackingState.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(trackingState.currentPosition!, _mapController.camera.zoom);
      });
    }

    return Scaffold(
      backgroundColor: StrydeColors.background,
      body: Stack(
        children: [
          // 1. Dark CartoDB Map
          _buildMap(trackingState),

          // 2. Map Overlay Gradient for readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    StrydeColors.background.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Top Status Bar & Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Stryde Logo Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: StrydeColors.surfaceCard.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: StrydeColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: trackingState.isRunning
                                ? StrydeColors.neonGreen
                                : trackingState.isAutoPaused
                                    ? StrydeColors.pausedAmber
                                    : StrydeColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'STRYDE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: StrydeColors.neonGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Auto-Pause Pill Toggle
                  GestureDetector(
                    onTap: () => trackerNotifier.toggleAutoPause(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: trackingState.autoPauseEnabled
                            ? StrydeColors.neonMint.withValues(alpha: 0.15)
                            : StrydeColors.surfaceCard.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: trackingState.autoPauseEnabled
                              ? StrydeColors.neonMint
                              : StrydeColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.pauseCircle,
                            size: 14,
                            color: trackingState.autoPauseEnabled
                                ? StrydeColors.neonMint
                                : StrydeColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trackingState.autoPauseEnabled ? 'AUTO-PAUSE' : 'MANUAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: trackingState.autoPauseEnabled
                                  ? StrydeColors.neonMint
                                  : StrydeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Recenter Location Button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _followRunner = true;
                      });
                      if (trackingState.currentPosition != null) {
                        _mapController.move(
                          trackingState.currentPosition!,
                          16.5,
                        );
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: StrydeColors.surfaceCard.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: StrydeColors.border),
                      ),
                      child: const Icon(
                        LucideIcons.crosshair,
                        size: 18,
                        color: StrydeColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Auto-Pause Notification Banner
          if (trackingState.isAutoPaused)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: StrydeColors.pausedAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StrydeColors.pausedAmber),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.pause, size: 16, color: StrydeColors.pausedAmber),
                    SizedBox(width: 8),
                    Text(
                      'AUTO-PAUSED • RESUMES UPON RUNNING',
                      style: TextStyle(
                        color: StrydeColors.pausedAmber,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Bottom Heads-Up Display (Metrics + Controls)
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildHudPanel(context, trackingState, trackerNotifier, shoesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(TrackingState trackingState) {
    final center = trackingState.currentPosition ?? const LatLng(-6.2088, 106.8456);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16.0,
        minZoom: 4.0,
        maxZoom: 19.0,
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && _followRunner) {
            setState(() {
              _followRunner = false;
            });
          }
        },
      ),
      children: [
        // Dark Matter Tile Layer (CartoDB)
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.stryde.app',
        ),

        // Route Polyline (Electric Neon Green)
        if (trackingState.coordinates.isNotEmpty)
          PolylineLayer(
            polylines: [
              // Outer glow line
              Polyline(
                points: trackingState.coordinates,
                strokeWidth: 8.0,
                color: StrydeColors.neonGreen.withValues(alpha: 0.35),
              ),
              // Inner solid neon line
              Polyline(
                points: trackingState.coordinates,
                strokeWidth: 4.5,
                color: StrydeColors.neonGreen,
              ),
            ],
          ),

        // Runner Current Position Marker
        if (trackingState.currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: trackingState.currentPosition!,
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StrydeColors.neonGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StrydeColors.neonGreen,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: StrydeColors.neonGreen.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHudPanel(
    BuildContext context,
    TrackingState state,
    TrackerNotifier notifier,
    AsyncValue<List<dynamic>> shoesAsync,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: StrydeColors.background.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(
          top: BorderSide(color: StrydeColors.border, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: StrydeColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Primary Huge Metric (DISTANCE)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.distanceKm.toStringAsFixed(2),
                style: StrydeTypography.metricHuge,
              ),
              const SizedBox(width: 8),
              const Text(
                'KM',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: StrydeColors.neonGreen,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Secondary Metrics Grid (Pace, Duration, Avg Pace, Calories)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: StrydeColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StrydeColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  label: 'CURRENT PACE',
                  value: RunMetricsCalculator.formatPace(state.currentPaceSeconds),
                  unit: '/km',
                ),
                _buildDivider(),
                _buildMetricItem(
                  label: 'TIME',
                  value: RunMetricsCalculator.formatDuration(state.movingTimeSeconds),
                  unit: 'elapsed',
                ),
                _buildDivider(),
                _buildMetricItem(
                  label: 'AVG PACE',
                  value: RunMetricsCalculator.formatPace(state.averagePaceSeconds),
                  unit: '/km',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Elevation and Calories info pill
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mountain, size: 14, color: StrydeColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '+${state.elevationGain.toStringAsFixed(0)} m elevation',
                style: StrydeTypography.caption.copyWith(color: StrydeColors.textSecondary),
              ),
              const SizedBox(width: 16),
              const Icon(LucideIcons.flame, size: 14, color: StrydeColors.neonOrange),
              const SizedBox(width: 6),
              Text(
                '${state.calories.toStringAsFixed(0)} kcal',
                style: StrydeTypography.caption.copyWith(color: StrydeColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tracking Action Controls
          if (state.status == TrackingStatus.idle)
            _buildStartButton(notifier)
          else
            _buildActiveControls(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: StrydeTypography.metricMedium,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: StrydeTypography.metricLabel.copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: StrydeColors.border,
    );
  }

  Widget _buildStartButton(TrackerNotifier notifier) {
    return ElevatedButton(
      onPressed: () async {
        final success = await notifier.startTracking();
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please grant location permissions to start tracking.'),
              backgroundColor: StrydeColors.dangerRed,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: StrydeColors.neonGreen,
        foregroundColor: StrydeColors.textOnNeon,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.play, size: 24, color: StrydeColors.textOnNeon),
          SizedBox(width: 12),
          Text(
            'START STRYDE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: StrydeColors.textOnNeon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveControls(
    BuildContext context,
    TrackingState state,
    TrackerNotifier notifier,
  ) {
    return Column(
      children: [
        Row(
          children: [
            // Pause / Resume Toggle Button
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  if (state.status == TrackingStatus.running) {
                    notifier.pauseTracking();
                  } else {
                    notifier.resumeTracking();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.status == TrackingStatus.running
                      ? StrydeColors.surfaceElevated
                      : StrydeColors.neonGreen,
                  foregroundColor: state.status == TrackingStatus.running
                      ? StrydeColors.textPrimary
                      : StrydeColors.textOnNeon,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: state.status == TrackingStatus.running
                          ? StrydeColors.border
                          : StrydeColors.neonGreen,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.status == TrackingStatus.running
                          ? LucideIcons.pause
                          : LucideIcons.play,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.status == TrackingStatus.running ? 'PAUSE' : 'RESUME',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Slide to Finish Component (prevents accidental stop)
        SlideToFinishButton(
          onConfirmed: () async {
            final int? activityId = await notifier.finishTracking();
            if (activityId != null && context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ActivityDetailScreen(activityId: activityId),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
