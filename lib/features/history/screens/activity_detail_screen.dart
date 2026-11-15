import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/models/split_pace.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import '../../../core/utils/gpx_exporter.dart';
import '../widgets/elevation_speed_chart.dart';
import '../widgets/shareable_activity_card.dart';
import '../widgets/split_pace_table.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final int activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: StrydeColors.background,
      appBar: AppBar(
        title: const Text('ACTIVITY DETAILS'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Activity?>(
        future: db.getActivityById(widget.activityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: StrydeColors.neonGreen),
            );
          }

          final activity = snapshot.data;
          if (activity == null) {
            return const Center(
              child: Text('Activity not found.', style: TextStyle(color: StrydeColors.textSecondary)),
            );
          }

          return FutureBuilder<List<TrackPoint>>(
            future: db.getTrackPointsForActivity(widget.activityId),
            builder: (context, pointsSnapshot) {
              final trackPoints = pointsSnapshot.data ?? [];
              final splits = SplitPace.listFromJson(activity.splitPacesJson);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title, Badge and Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: activity.activityType == 'walk'
                                ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                                : StrydeColors.neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: activity.activityType == 'walk'
                                  ? const Color(0xFF00E5FF)
                                  : StrydeColors.neonGreen,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                activity.activityType == 'walk'
                                    ? LucideIcons.personStanding
                                    : LucideIcons.footprints,
                                size: 13,
                                color: activity.activityType == 'walk'
                                    ? const Color(0xFF00E5FF)
                                    : StrydeColors.neonGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.activityType == 'walk' ? 'JALAN SANTAI' : 'LARI',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: activity.activityType == 'walk'
                                      ? const Color(0xFF00E5FF)
                                      : StrydeColors.neonGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            activity.title,
                            style: StrydeTypography.headline,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy • h:mm a').format(activity.startTime),
                      style: StrydeTypography.bodySecondary,
                    ),
                    const SizedBox(height: 16),

                    // Interactive Map
                    _buildRouteMap(trackPoints),
                    const SizedBox(height: 16),

                    // Action buttons (GPX Export, Share Card)
                    _buildActionButtons(activity, trackPoints),
                    const SizedBox(height: 20),

                    // Primary Stats HUD
                    _buildStatsGrid(activity),
                    const SizedBox(height: 20),

                    // Elevation & Speed Chart
                    ElevationSpeedChart(trackPoints: trackPoints),
                    const SizedBox(height: 20),

                    // 1km Split Pace Table
                    SplitPaceTable(splits: splits),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRouteMap(List<TrackPoint> trackPoints) {
    final List<LatLng> latLngList = trackPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final LatLng center = latLngList.isNotEmpty ? latLngList.first : const LatLng(-6.2088, 106.8456);

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StrydeColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15.0,
            onMapReady: () {
              if (latLngList.length >= 2) {
                final bounds = LatLngBounds.fromPoints(latLngList);
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(32),
                  ),
                );
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.stryde.stryde',
            ),
            if (latLngList.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: latLngList,
                    strokeWidth: 4.5,
                    color: StrydeColors.neonGreen,
                  ),
                ],
              ),
            if (latLngList.isNotEmpty)
              MarkerLayer(
                markers: [
                  // Start point marker (Green)
                  Marker(
                    point: latLngList.first,
                    width: 16,
                    height: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: StrydeColors.neonGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  // Finish point marker (Red)
                  Marker(
                    point: latLngList.last,
                    width: 16,
                    height: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: StrydeColors.neonRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Activity activity, List<TrackPoint> trackPoints) {
    return Row(
      children: [
        // Share Activity Card Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openShareCardDialog(activity, trackPoints),
            icon: const Icon(LucideIcons.share2, size: 18),
            label: const Text('SHARE CARD'),
            style: ElevatedButton.styleFrom(
              backgroundColor: StrydeColors.neonGreen,
              foregroundColor: StrydeColors.textOnNeon,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Export GPX Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _exportGpxFile(activity, trackPoints),
            icon: const Icon(LucideIcons.fileText, size: 18),
            label: const Text('EXPORT GPX'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Activity activity) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StrydeColors.border),
      ),
      child: Column(
        children: [
          // Distance
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                activity.distanceKm.toStringAsFixed(2),
                style: StrydeTypography.metricHuge,
              ),
              const SizedBox(width: 6),
              const Text(
                'KM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: StrydeColors.neonGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (activity.activityType == 'walk')
                _buildStatCell(
                  'EST. STEPS',
                  '${RunMetricsCalculator.estimateSteps(distanceKm: activity.distanceKm, isWalking: true)}',
                )
              else
                _buildStatCell('AVG PACE', '${RunMetricsCalculator.formatPace(activity.avgPaceSecondsPerKm)} /km'),
              _buildStatCell('MOVING TIME', RunMetricsCalculator.formatDuration(activity.movingTimeSeconds)),
              _buildStatCell('CALORIES', '${activity.caloriesBurned.toStringAsFixed(0)} kcal'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCell('ELEV GAIN', '+${activity.elevationGainMeters.toStringAsFixed(0)} m'),
              _buildStatCell('AVG SPEED', '${activity.avgSpeedKmh.toStringAsFixed(1)} km/h'),
              _buildStatCell('MAX SPEED', '${activity.maxSpeedKmh.toStringAsFixed(1)} km/h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: StrydeTypography.metricSmall,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: StrydeTypography.metricLabel.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Future<void> _exportGpxFile(Activity activity, List<TrackPoint> trackPoints) async {
    try {
      final gpxFile = await GpxExporter.exportToGpx(
        activity: activity,
        trackPoints: trackPoints,
      );

      await Share.shareXFiles(
        [XFile(gpxFile.path)],
        text: '${activity.title} GPX Track',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export GPX: $e'),
            backgroundColor: StrydeColors.dangerRed,
          ),
        );
      }
    }
  }

  void _openShareCardDialog(Activity activity, List<TrackPoint> trackPoints) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: StrydeColors.surfaceSubtle,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StrydeColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SHAREABLE STRYDE CARD',
                style: StrydeTypography.title,
              ),
              const SizedBox(height: 20),

              Screenshot(
                controller: _screenshotController,
                child: ShareableActivityCard(
                  activity: activity,
                  trackPoints: trackPoints,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ShareableActivityCard.captureAndShare(
                    context: this.context,
                    screenshotController: _screenshotController,
                    title: activity.title,
                  );
                },
                icon: const Icon(LucideIcons.share2),
                label: const Text('SHARE CARD AS IMAGE'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
