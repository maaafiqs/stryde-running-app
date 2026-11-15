import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/stryde_database.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';

class ShareableActivityCard extends StatelessWidget {
  final Activity activity;
  final List<TrackPoint> trackPoints;

  const ShareableActivityCard({
    super.key,
    required this.activity,
    required this.trackPoints,
  });

  static Future<void> captureAndShare({
    required BuildContext context,
    required ScreenshotController screenshotController,
    required String title,
  }) async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/stryde_share_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Check out my run on Stryde! 🏃⚡',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share card: $e'),
            backgroundColor: StrydeColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy • h:mm a');

    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F131C).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: StrydeColors.neonGreen.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: StrydeColors.neonGreen.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stryde Brand Header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: StrydeColors.neonGreen,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'STRYDE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: StrydeColors.neonGreen,
                ),
              ),
              const Spacer(),
              Text(
                'PERFORMANCE',
                style: StrydeTypography.caption.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                  color: StrydeColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Vector Route Map Preview
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: StrydeColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StrydeColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: RouteVectorPainter(trackPoints: trackPoints),
                size: const Size(double.infinity, 170),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Big Distance
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                activity.distanceKm.toStringAsFixed(2),
                style: StrydeTypography.metricHuge.copyWith(fontSize: 48),
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
          const SizedBox(height: 12),

          // Metric Stats Grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: StrydeColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (activity.activityType == 'walk')
                  _buildStat(
                    'EST. STEPS',
                    '${RunMetricsCalculator.estimateSteps(distanceKm: activity.distanceKm, isWalking: true)}',
                  )
                else
                  _buildStat('AVG PACE', '${RunMetricsCalculator.formatPace(activity.avgPaceSecondsPerKm)} /km'),
                _buildStat('TIME', RunMetricsCalculator.formatDuration(activity.movingTimeSeconds)),
                _buildStat('CALORIES', '${activity.caloriesBurned.toStringAsFixed(0)} kcal'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Date & Time Footer
          Text(
            dateFormat.format(activity.startTime),
            style: StrydeTypography.caption.copyWith(color: StrydeColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: StrydeTypography.metricSmall.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: StrydeTypography.metricLabel.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}

class RouteVectorPainter extends CustomPainter {
  final List<TrackPoint> trackPoints;

  RouteVectorPainter({required this.trackPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (trackPoints.length < 2) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLon = double.infinity;
    double maxLon = -double.infinity;

    for (final p in trackPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }

    final double latRange = (maxLat - minLat).abs();
    final double lonRange = (maxLon - minLon).abs();

    if (latRange == 0 || lonRange == 0) return;

    const double padding = 20.0;
    final double drawWidth = size.width - (padding * 2);
    final double drawHeight = size.height - (padding * 2);

    final path = Path();
    for (int i = 0; i < trackPoints.length; i++) {
      final p = trackPoints[i];
      final double x = padding + ((p.longitude - minLon) / lonRange) * drawWidth;
      // Invert Y because latitude goes up north while canvas Y goes down
      final double y = padding + (1.0 - ((p.latitude - minLat) / latRange)) * drawHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Outer glow paint
    final glowPaint = Paint()
      ..color = StrydeColors.neonGreen.withValues(alpha: 0.3)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Solid line paint
    final solidPaint = Paint()
      ..color = StrydeColors.neonGreen
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, solidPaint);

    // Draw Start point (Green)
    final firstPoint = trackPoints.first;
    final double startX = padding + ((firstPoint.longitude - minLon) / lonRange) * drawWidth;
    final double startY = padding + (1.0 - ((firstPoint.latitude - minLat) / latRange)) * drawHeight;
    canvas.drawCircle(Offset(startX, startY), 4, Paint()..color = StrydeColors.neonGreen);

    // Draw Finish point (Red)
    final lastPoint = trackPoints.last;
    final double endX = padding + ((lastPoint.longitude - minLon) / lonRange) * drawWidth;
    final double endY = padding + (1.0 - ((lastPoint.latitude - minLat) / latRange)) * drawHeight;
    canvas.drawCircle(Offset(endX, endY), 4, Paint()..color = StrydeColors.neonRed);
  }

  @override
  bool shouldRepaint(covariant RouteVectorPainter oldDelegate) {
    return oldDelegate.trackPoints != trackPoints;
  }
}
