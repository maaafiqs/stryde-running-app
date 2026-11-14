import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';

enum ChartMode {
  elevation,
  speed,
}

class ElevationSpeedChart extends StatefulWidget {
  final List<TrackPoint> trackPoints;

  const ElevationSpeedChart({super.key, required this.trackPoints});

  @override
  State<ElevationSpeedChart> createState() => _ElevationSpeedChartState();
}

class _ElevationSpeedChartState extends State<ElevationSpeedChart> {
  ChartMode _mode = ChartMode.elevation;

  @override
  Widget build(BuildContext context) {
    if (widget.trackPoints.length < 2) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: StrydeColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: StrydeColors.border),
        ),
        child: const Center(
          child: Text(
            'Not enough telemetry data for chart.',
            style: TextStyle(color: StrydeColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final spots = _generateSpots();

    return Container(
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StrydeColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _mode == ChartMode.elevation ? 'ELEVATION PROFILE' : 'SPEED PROFILE',
                style: StrydeTypography.metricLabel,
              ),
              const Spacer(),
              _buildToggleChip(ChartMode.elevation, 'ELEVATION'),
              const SizedBox(width: 8),
              _buildToggleChip(ChartMode.speed, 'SPEED'),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _mode == ChartMode.elevation ? 10 : 3,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: StrydeColors.border.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _mode == ChartMode.elevation
                              ? '${value.toInt()}m'
                              : '${value.toInt()}k',
                          style: StrydeTypography.caption.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            '${value.toStringAsFixed(1)}km',
                            style: StrydeTypography.caption.copyWith(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: _mode == ChartMode.elevation
                        ? StrydeColors.neonCyan
                        : StrydeColors.neonGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: _mode == ChartMode.elevation
                            ? [
                                StrydeColors.neonCyan.withValues(alpha: 0.3),
                                StrydeColors.neonCyan.withValues(alpha: 0.0),
                              ]
                            : [
                                StrydeColors.neonGreen.withValues(alpha: 0.3),
                                StrydeColors.neonGreen.withValues(alpha: 0.0),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(ChartMode mode, String label) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? StrydeColors.neonGreen : StrydeColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? StrydeColors.textOnNeon : StrydeColors.textSecondary,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final List<FlSpot> spots = [];
    double cumulativeDistanceKm = 0.0;

    for (int i = 0; i < widget.trackPoints.length; i++) {
      final current = widget.trackPoints[i];
      if (i > 0) {
        final prev = widget.trackPoints[i - 1];
        final dist = RunMetricsCalculator.haversineMeters(
              prev.latitude,
              prev.longitude,
              current.latitude,
              current.longitude,
            ) /
            1000.0;
        cumulativeDistanceKm += dist;
      }

      final double yValue = _mode == ChartMode.elevation
          ? current.altitude
          : RunMetricsCalculator.speedMpsToKmh(current.speed);

      spots.add(FlSpot(cumulativeDistanceKm, yValue));
    }
    return spots;
  }
}
