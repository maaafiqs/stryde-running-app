import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      backgroundColor: StrydeColors.background,
      appBar: AppBar(
        title: const Text('ANALYTICS & PROGRESS'),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. High-Level Lifetime Stats
                _buildLifetimeCards(activities),
                const SizedBox(height: 20),

                // 2. Weekly Bar Chart (Mon - Sun volume)
                _buildWeeklyVolumeChart(activities),
                const SizedBox(height: 20),

                // 3. Activity Consistency Heatmap
                _buildConsistencyHeatmap(activities),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: StrydeColors.neonGreen),
        ),
        error: (err, _) => Center(
          child: Text('Error loading analytics: $err', style: const TextStyle(color: StrydeColors.dangerRed)),
        ),
      ),
    );
  }

  Widget _buildLifetimeCards(List<Activity> activities) {
    double totalKm = 0.0;
    int totalMovingSeconds = 0;
    double totalCalories = 0.0;
    double totalPaceSum = 0.0;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double weekKm = 0.0;
    double monthKm = 0.0;

    for (final a in activities) {
      totalKm += a.distanceKm;
      totalMovingSeconds += a.movingTimeSeconds;
      totalCalories += a.caloriesBurned;
      totalPaceSum += a.avgPaceSecondsPerKm;

      if (a.startTime.isAfter(startOfWeek)) {
        weekKm += a.distanceKm;
      }
      if (a.startTime.isAfter(startOfMonth)) {
        monthKm += a.distanceKm;
      }
    }

    final double avgPace = activities.isNotEmpty ? (totalPaceSum / activities.length) : 0.0;

    return Column(
      children: [
        // Total Distance Big Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: StrydeColors.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: StrydeColors.border),
          ),
          child: Column(
            children: [
              const Text('TOTAL DISTANCE COVERED', style: StrydeTypography.metricLabel),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalKm.toStringAsFixed(1),
                    style: StrydeTypography.metricHuge.copyWith(fontSize: 50),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'KM',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: StrydeColors.neonGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSubStat('RUNS', activities.length.toString()),
                  _buildSubStat('AVG PACE', '${RunMetricsCalculator.formatPace(avgPace)}/km'),
                  _buildSubStat('TOTAL TIME', RunMetricsCalculator.formatDuration(totalMovingSeconds)),
                  _buildSubStat('CALORIES', totalCalories.toStringAsFixed(0)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Week and Month Quick Glance
        Row(
          children: [
            Expanded(
              child: _buildMetricPill(
                title: 'THIS WEEK',
                value: '${weekKm.toStringAsFixed(1)} KM',
                icon: LucideIcons.calendar,
                accentColor: StrydeColors.neonGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricPill(
                title: 'THIS MONTH',
                value: '${monthKm.toStringAsFixed(1)} KM',
                icon: LucideIcons.calendarDays,
                accentColor: StrydeColors.neonMint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: StrydeTypography.metricSmall.copyWith(fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: StrydeTypography.metricLabel.copyWith(fontSize: 9)),
      ],
    );
  }

  Widget _buildMetricPill({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StrydeColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: StrydeTypography.metricLabel.copyWith(fontSize: 10)),
              Text(value, style: StrydeTypography.metricSmall.copyWith(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyVolumeChart(List<Activity> activities) {
    // Days of current week (Mon=1 .. Sun=7)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final List<double> dayVolumes = List.filled(7, 0.0);

    for (final a in activities) {
      final diff = a.startTime.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        dayVolumes[diff] += a.distanceKm;
      }
    }

    final barGroups = List.generate(7, (index) {
      final km = dayVolumes[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: km > 0 ? km : 0.3,
            color: km > 0 ? StrydeColors.neonGreen : StrydeColors.surfaceElevated,
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StrydeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WEEKLY VOLUME (KM)', style: StrydeTypography.metricLabel),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < 7) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[idx],
                              style: StrydeTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: dayVolumes[idx] > 0
                                    ? StrydeColors.neonGreen
                                    : StrydeColors.textMuted,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyHeatmap(List<Activity> activities) {
    // Generate 60-day calendar heatmap
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const int totalDays = 60;

    final Map<String, double> dayKmMap = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final a in activities) {
      final key = dateFormat.format(a.startTime);
      dayKmMap[key] = (dayKmMap[key] ?? 0.0) + a.distanceKm;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StrydeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('CONSISTENCY HEATMAP', style: StrydeTypography.metricLabel),
              const Spacer(),
              Text('LAST 60 DAYS', style: StrydeTypography.caption.copyWith(color: StrydeColors.neonGreen)),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(totalDays, (index) {
              final day = today.subtract(Duration(days: totalDays - 1 - index));
              final key = dateFormat.format(day);
              final km = dayKmMap[key] ?? 0.0;

              Color cellColor = StrydeColors.surfaceElevated;
              if (km >= 10.0) {
                cellColor = StrydeColors.neonGreen;
              } else if (km >= 5.0) {
                cellColor = StrydeColors.neonMint;
              } else if (km > 0.0) {
                cellColor = StrydeColors.neonMint.withValues(alpha: 0.4);
              }

              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: StrydeTypography.caption.copyWith(fontSize: 10)),
              const SizedBox(width: 4),
              _buildLegendBox(StrydeColors.surfaceElevated),
              _buildLegendBox(StrydeColors.neonMint.withValues(alpha: 0.4)),
              _buildLegendBox(StrydeColors.neonMint),
              _buildLegendBox(StrydeColors.neonGreen),
              const SizedBox(width: 4),
              Text('More', style: StrydeTypography.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
