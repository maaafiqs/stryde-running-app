import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/models/split_pace.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import '../widgets/activity_route_map.dart';
import '../widgets/elevation_speed_chart.dart';
import '../widgets/share_activity_modal.dart';
import '../widgets/split_pace_table.dart';

class _ActivityDetailData {
  final Activity activity;
  final List<TrackPoint> trackPoints;
  final Shoe? shoe;

  const _ActivityDetailData({
    required this.activity,
    required this.trackPoints,
    this.shoe,
  });
}

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final int activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {

  Future<_ActivityDetailData?> _loadActivityData(StrydeDatabase db) async {
    final activity = await db.getActivityById(widget.activityId);
    if (activity == null) return null;
    final trackPoints = await db.getTrackPointsForActivity(widget.activityId);
    Shoe? shoe;
    if (activity.shoeId != null) {
      shoe = await db.getShoeById(activity.shoeId!);
    }
    return _ActivityDetailData(activity: activity, trackPoints: trackPoints, shoe: shoe);
  }

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
      body: FutureBuilder<_ActivityDetailData?>(
        future: _loadActivityData(db),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: StrydeColors.neonGreen),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data aktivitas...',
                    style: TextStyle(color: StrydeColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: Text('Activity not found.', style: TextStyle(color: StrydeColors.textSecondary)),
            );
          }

          final activity = data.activity;
          final trackPoints = data.trackPoints;
          final rawSplits = SplitPace.listFromJson(activity.splitPacesJson);
          final splits = SplitPace.completeSplits(
            existingSplits: rawSplits,
            totalDistanceKm: activity.distanceKm,
            totalMovingTimeSeconds: activity.movingTimeSeconds,
            totalElevationGain: activity.elevationGainMeters,
          );

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
                const SizedBox(height: 12),

                // Shoe info card (if a shoe was selected for this session)
                if (data.shoe != null) ...[
                  _buildShoeCard(activity, data.shoe!),
                  const SizedBox(height: 12),
                ],

                // Interactive Map showing user footprint trail & last location
                ActivityRouteMap(
                  activity: activity,
                  trackPoints: trackPoints,
                ),
                const SizedBox(height: 16),

                // Action button (Share Card)
                _buildActionButtons(activity, trackPoints, data.shoe),
                const SizedBox(height: 20),

                // Primary Stats HUD
                _buildStatsGrid(activity),
                const SizedBox(height: 20),

                // Elevation & Speed Chart
                ElevationSpeedChart(trackPoints: trackPoints),
                const SizedBox(height: 20),

                // 1km Split Pace Table
                SplitPaceTable(
                  splits: splits,
                  activityType: activity.activityType,
                  avgPaceSecondsPerKm: activity.avgPaceSecondsPerKm,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShoeCard(Activity activity, Shoe shoe) {
    final bool isWalking = activity.activityType == 'walk';
    final Color accentColor = isWalking ? const Color(0xFF00E5FF) : StrydeColors.neonGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StrydeColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.footprints,
              size: 16,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SEPATU DIGUNAKAN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: StrydeColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shoe.brand} ${shoe.model}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: StrydeColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${shoe.totalDistanceKm.toStringAsFixed(1)} KM',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                'Total Jarak',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: StrydeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Activity activity, List<TrackPoint> trackPoints, Shoe? shoe) {
    final bool isWalking = activity.activityType == 'walk';
    final Color buttonColor = isWalking ? const Color(0xFF00E5FF) : StrydeColors.neonGreen;

    return ElevatedButton.icon(
      onPressed: () => _openShareCardDialog(activity, trackPoints, shoe),
      icon: const Icon(LucideIcons.share2, size: 18),
      label: const Text(
        'BAGIKAN HASIL (SHARE CARD)',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: StrydeColors.textOnNeon,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
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

  void _openShareCardDialog(Activity activity, List<TrackPoint> trackPoints, Shoe? shoe) {
    ShareActivityModal.show(
      context: context,
      activity: activity,
      trackPoints: trackPoints,
      shoe: shoe,
    );
  }
}
