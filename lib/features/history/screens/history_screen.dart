import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import 'activity_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: StrydeColors.background,
      appBar: AppBar(
        title: const Text('RUN HISTORY'),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: activities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityCard(context, db, activity);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: StrydeColors.neonGreen),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading history: $err', style: const TextStyle(color: StrydeColors.dangerRed)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: StrydeColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: StrydeColors.border),
              ),
              child: const Icon(
                LucideIcons.activity,
                size: 48,
                color: StrydeColors.neonGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NO ACTIVITIES YET',
              style: StrydeTypography.title,
            ),
            const SizedBox(height: 8),
            const Text(
              'Lace up your shoes and record your first run to start building your Stryde journey!',
              textAlign: TextAlign.center,
              style: StrydeTypography.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, StrydeDatabase db, Activity activity) {
    final dateFormat = DateFormat('EEE, MMM d • h:mm a');

    return Dismissible(
      key: ValueKey(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: StrydeColors.dangerRed.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: StrydeColors.surfaceCard,
            title: const Text('Delete Activity?'),
            content: const Text('This will permanently delete this run session and its GPS points.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('CANCEL', style: TextStyle(color: StrydeColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('DELETE', style: TextStyle(color: StrydeColors.dangerRed)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        db.deleteActivity(activity.id);
      },
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(activityId: activity.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StrydeColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StrydeColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    activity.title,
                    style: StrydeTypography.metricSmall.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(activity.startTime),
                    style: StrydeTypography.caption,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    activity.distanceKm.toStringAsFixed(2),
                    style: StrydeTypography.metricLarge,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'KM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: StrydeColors.neonGreen,
                    ),
                  ),
                  const Spacer(),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        RunMetricsCalculator.formatPace(activity.avgPaceSecondsPerKm),
                        style: StrydeTypography.metricMedium.copyWith(fontSize: 20),
                      ),
                      const Text(
                        'AVG PACE /KM',
                        style: StrydeTypography.metricLabel,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        RunMetricsCalculator.formatDuration(activity.movingTimeSeconds),
                        style: StrydeTypography.metricMedium.copyWith(fontSize: 20),
                      ),
                      const Text(
                        'TIME',
                        style: StrydeTypography.metricLabel,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(LucideIcons.flame, size: 14, color: StrydeColors.neonOrange),
                  const SizedBox(width: 4),
                  Text(
                    '${activity.caloriesBurned.toStringAsFixed(0)} kcal',
                    style: StrydeTypography.caption,
                  ),
                  const SizedBox(width: 14),
                  const Icon(LucideIcons.mountain, size: 14, color: StrydeColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '+${activity.elevationGainMeters.toStringAsFixed(0)} m',
                    style: StrydeTypography.caption,
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.chevronRight, size: 18, color: StrydeColors.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
