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
import '../../gear/screens/gear_screen.dart';
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
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
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
    return _ActivityDetailData(
      activity: activity,
      trackPoints: trackPoints,
      shoe: shoe,
    );
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
                    style: TextStyle(
                      color: StrydeColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: Text(
                'Activity not found.',
                style: TextStyle(color: StrydeColors.textSecondary),
              ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                            activity.activityType == 'walk'
                                ? 'JALAN SANTAI'
                                : 'LARI',
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
                  DateFormat(
                    'EEEE, MMM d, yyyy • h:mm a',
                  ).format(activity.startTime),
                  style: StrydeTypography.bodySecondary,
                ),
                const SizedBox(height: 12),

                // Shoe info & mileage card
                _buildShoeCard(activity, data.shoe),
                const SizedBox(height: 12),

                // Interactive Map showing user footprint trail & last location
                ActivityRouteMap(activity: activity, trackPoints: trackPoints),
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

  Widget _buildShoeCard(Activity activity, Shoe? shoe) {
    final bool isWalking = activity.activityType == 'walk';
    final Color accentColor = isWalking
        ? const Color(0xFF00E5FF)
        : StrydeColors.neonGreen;

    if (shoe == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StrydeColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: StrydeColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: StrydeColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.footprints,
                size: 20,
                color: StrydeColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEPATU DIGUNAKAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: StrydeColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Belum terhubung ke sepatu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: StrydeColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openShoePickerModal(activity, null),
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('PILIH'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: isWalking ? Colors.black : StrydeColors.textOnNeon,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    final double mileagePercent = (shoe.totalDistanceKm / shoe.maxDistanceKm).clamp(0.0, 1.0);
    final double remainingKm = (shoe.maxDistanceKm - shoe.totalDistanceKm).clamp(0.0, double.infinity);

    return InkWell(
      onTap: () => _openShoePickerModal(activity, shoe),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StrydeColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Badge + Shoe Name + Ganti Button
            Row(
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
                const SizedBox(width: 10),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: StrydeColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: StrydeColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: StrydeColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ganti',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(LucideIcons.chevronRight, size: 12, color: accentColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar of Shoe Life
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: mileagePercent,
                minHeight: 6,
                backgroundColor: StrydeColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(
                  mileagePercent > 0.9 ? StrydeColors.dangerRed : accentColor,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3-Metric Detailed Grid: Sesi ini, Total Dipakai, Batas Pakai
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: StrydeColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShoeMetric(
                    label: 'SESI INI',
                    value: '+${activity.distanceKm.toStringAsFixed(2)}',
                    unit: 'km',
                    valueColor: accentColor,
                  ),
                  Container(width: 1, height: 24, color: StrydeColors.border),
                  _buildShoeMetric(
                    label: 'TOTAL DIPAKAI',
                    value: shoe.totalDistanceKm.toStringAsFixed(1),
                    unit: 'km',
                    valueColor: StrydeColors.textPrimary,
                  ),
                  Container(width: 1, height: 24, color: StrydeColors.border),
                  _buildShoeMetric(
                    label: 'BATAS PAKAI',
                    value: shoe.maxDistanceKm.toStringAsFixed(0),
                    unit: 'km (sisa ${remainingKm.toStringAsFixed(0)})',
                    valueColor: StrydeColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoeMetric({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: StrydeColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: StrydeColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openShoePickerModal(Activity activity, Shoe? currentShoe) async {
    final db = ref.read(databaseProvider);
    final shoes = await db.getAllShoes();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: StrydeColors.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: StrydeColors.border, width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: StrydeColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PILIH SEPATU AKTIVITAS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GearScreen()),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    icon: const Icon(LucideIcons.plus, size: 14, color: StrydeColors.neonGreen),
                    label: const Text(
                      'Kelola Gear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: StrydeColors.neonGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (shoes.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.footprints, size: 40, color: StrydeColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada sepatu di database.',
                        style: TextStyle(color: StrydeColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GearScreen()),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StrydeColors.neonGreen,
                          foregroundColor: StrydeColors.textOnNeon,
                        ),
                        child: const Text('TAMBAH SEPATU BARU'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: shoes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, idx) {
                      final s = shoes[idx];
                      final isSelected = currentShoe?.id == s.id;

                      return InkWell(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await db.assignShoeToActivity(activity.id, s.id);
                          if (!mounted) return;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✓ Sepatu dihubungkan ke ${s.brand} ${s.model}'),
                              backgroundColor: StrydeColors.surfaceElevated,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? StrydeColors.neonGreen.withValues(alpha: 0.12)
                                : StrydeColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? StrydeColors.neonGreen : StrydeColors.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.footprints,
                                size: 20,
                                color: isSelected ? StrydeColors.neonGreen : StrydeColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${s.brand} ${s.model}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? StrydeColors.neonGreen : StrydeColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Total Dipakai: ${s.totalDistanceKm.toStringAsFixed(1)} / ${s.maxDistanceKm.toStringAsFixed(0)} km • ${(s.nickname != null && s.nickname!.isNotEmpty) ? s.nickname! : "Utama"}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: StrydeColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  LucideIcons.checkCircle2,
                                  size: 18,
                                  color: StrydeColors.neonGreen,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    Activity activity,
    List<TrackPoint> trackPoints,
    Shoe? shoe,
  ) {
    final bool isWalking = activity.activityType == 'walk';
    final Color buttonColor = isWalking
        ? const Color(0xFF00E5FF)
        : StrydeColors.neonGreen;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                _buildStatCell(
                  'AVG PACE',
                  '${RunMetricsCalculator.formatPace(activity.avgPaceSecondsPerKm)} /km',
                ),
              _buildStatCell(
                'MOVING TIME',
                RunMetricsCalculator.formatDuration(activity.movingTimeSeconds),
              ),
              _buildStatCell(
                'CALORIES',
                '${activity.caloriesBurned.toStringAsFixed(0)} kcal',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCell(
                'ELEV GAIN',
                '+${activity.elevationGainMeters.toStringAsFixed(0)} m',
              ),
              _buildStatCell(
                'AVG SPEED',
                '${activity.avgSpeedKmh.toStringAsFixed(1)} km/h',
              ),
              _buildStatCell(
                'MAX SPEED',
                '${activity.maxSpeedKmh.toStringAsFixed(1)} km/h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String label, String value) {
    return Column(
      children: [
        Text(value, style: StrydeTypography.metricSmall),
        const SizedBox(height: 2),
        Text(label, style: StrydeTypography.metricLabel.copyWith(fontSize: 10)),
      ],
    );
  }

  void _openShareCardDialog(
    Activity activity,
    List<TrackPoint> trackPoints,
    Shoe? shoe,
  ) {
    ShareActivityModal.show(
      context: context,
      activity: activity,
      trackPoints: trackPoints,
      shoe: shoe,
    );
  }
}
