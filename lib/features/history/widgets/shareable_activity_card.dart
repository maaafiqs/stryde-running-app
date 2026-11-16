import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/stryde_database.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';

enum ShareBackgroundStyle {
  transparent(
    label: 'Transparan (Stiker)',
    description: 'Background transparan tanpa latar untuk ditempel di foto',
  ),
  carbonDark(
    label: 'Dark Carbon',
    description: 'Tampilan athletic hitam pekat elegan',
  ),
  midnightGlow(
    label: 'Midnight Glow',
    description: 'Gradasi malam dengan aksen cyber neon',
  ),
  minimalLight(
    label: 'Clean Light',
    description: 'Minimalis putih terang kontras tinggi',
  );

  final String label;
  final String description;

  const ShareBackgroundStyle({required this.label, required this.description});
}

enum ShareCardFormat {
  card(label: 'Card Standar', width: 340, height: null),
  story(label: 'Story (9:16)', width: 340, height: 604),
  square(label: 'Square (1:1)', width: 340, height: 340);

  final String label;
  final double width;
  final double? height;

  const ShareCardFormat({
    required this.label,
    required this.width,
    required this.height,
  });
}

class ShareableActivityCard extends StatelessWidget {
  final Activity activity;
  final List<TrackPoint> trackPoints;
  final Shoe? shoe;
  final ShareBackgroundStyle backgroundStyle;
  final bool showRoute;
  final ShareCardFormat format;

  const ShareableActivityCard({
    super.key,
    required this.activity,
    required this.trackPoints,
    this.shoe,
    this.backgroundStyle = ShareBackgroundStyle.carbonDark,
    this.showRoute = true,
    this.format = ShareCardFormat.card,
  });

  static Future<String?> captureAndSaveImage({
    required BuildContext context,
    required ScreenshotController screenshotController,
    required String title,
  }) async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 120),
      );

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final sanitizedTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final imagePath =
            '${directory.path}/stryde_${sanitizedTitle}_$timestamp.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);
        return imagePath;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat gambar: $e'),
            backgroundColor: StrydeColors.dangerRed,
          ),
        );
      }
    }
    return null;
  }

  static Future<void> captureAndShare({
    required BuildContext context,
    required ScreenshotController screenshotController,
    required String title,
    String? subtitle,
  }) async {
    final imagePath = await captureAndSaveImage(
      context: context,
      screenshotController: screenshotController,
      title: title,
    );

    if (imagePath != null && context.mounted) {
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'Lihat aktivitas saya di Stryde! 🏃⚡ $title ${subtitle ?? ""}');
    }
  }

  bool get _isTransparent =>
      backgroundStyle == ShareBackgroundStyle.transparent;
  bool get _isLight => backgroundStyle == ShareBackgroundStyle.minimalLight;
  bool get _isWalking => activity.activityType == 'walk';
  Color get _activityColor =>
      _isWalking ? const Color(0xFF00E5FF) : StrydeColors.neonGreen;

  Color get _primaryTextColor {
    if (_isLight) return const Color(0xFF0F172A);
    return Colors.white;
  }

  Color get _secondaryTextColor {
    if (_isLight) return const Color(0xFF64748B);
    return _isTransparent ? Colors.white70 : StrydeColors.textSecondary;
  }

  List<Shadow>? get _textShadows {
    if (_isTransparent) {
      return [
        Shadow(
          color: Colors.black.withValues(alpha: 0.85),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];
    }
    return null;
  }

  BoxDecoration _buildCardDecoration() {
    switch (backgroundStyle) {
      case ShareBackgroundStyle.transparent:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        );
      case ShareBackgroundStyle.minimalLight:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case ShareBackgroundStyle.midnightGlow:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF090D16)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _activityColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _activityColor.withValues(alpha: 0.2),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        );
      case ShareBackgroundStyle.carbonDark:
        return BoxDecoration(
          color: const Color(0xFF0F131C).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _activityColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _activityColor.withValues(alpha: 0.15),
              blurRadius: 26,
              spreadRadius: 1,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy • h:mm a');
    final hasPoints = trackPoints.length >= 2;
    final shouldShowRoute = showRoute && hasPoints;

    return Container(
      width: format.width,
      height: format.height,
      padding: const EdgeInsets.all(22),
      decoration: _buildCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Top Stryde Brand Header & Activity Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _activityColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'STRYDE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: _activityColor,
                      shadows: _textShadows,
                    ),
                  ),
                  const Spacer(),

                  // Activity Badge Pill (Lari / Jalan Santai)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _activityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _activityColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isWalking
                              ? LucideIcons.personStanding
                              : LucideIcons.footprints,
                          size: 11,
                          color: _activityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isWalking ? 'JALAN SANTAI' : 'LARI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _activityColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dateFormat.format(activity.startTime),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _secondaryTextColor,
                  shadows: _textShadows,
                ),
              ),
              if (shoe != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.footprints, size: 10, color: _activityColor),
                    const SizedBox(width: 4),
                    Text(
                      '${shoe!.brand} ${shoe!.model}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _secondaryTextColor,
                        shadows: _textShadows,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // 2. Route Vector Map (Optional: only when showRoute is true)
          if (shouldShowRoute) ...[
            Container(
              height: format == ShareCardFormat.story
                  ? 220
                  : format == ShareCardFormat.square
                  ? 120
                  : 150,
              decoration: BoxDecoration(
                color: _isTransparent
                    ? Colors.transparent
                    : _isLight
                    ? const Color(0xFFF1F5F9)
                    : StrydeColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isTransparent
                      ? Colors.white12
                      : _isLight
                      ? const Color(0xFFE2E8F0)
                      : StrydeColors.border,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(
                  painter: RouteVectorPainter(
                    trackPoints: trackPoints,
                    activityType: activity.activityType,
                  ),
                  size: Size(
                    double.infinity,
                    format == ShareCardFormat.story
                        ? 220
                        : format == ShareCardFormat.square
                        ? 120
                        : 150,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 3. Hero Distance Display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL DISTANCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: _secondaryTextColor,
                  shadows: _textShadows,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    activity.distanceKm.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: format == ShareCardFormat.story ? 54 : 44,
                      fontWeight: FontWeight.w900,
                      color: _primaryTextColor,
                      letterSpacing: -1.0,
                      shadows: _textShadows,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KM',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _activityColor,
                      letterSpacing: 1.0,
                      shadows: _textShadows,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4. Metric Stats Grid (Strava-style Pace, Time, Calories, Steps, Elev)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: _isTransparent
                  ? Colors.black.withValues(alpha: 0.35)
                  : _isLight
                  ? const Color(0xFFF8FAFC)
                  : StrydeColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isTransparent
                    ? Colors.white12
                    : _isLight
                    ? const Color(0xFFE2E8F0)
                    : Colors.white10,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Pace / Speed
                _buildStatItem(
                  label: _isWalking ? 'AVG SPEED' : 'AVG PACE',
                  value: _isWalking
                      ? '${activity.avgSpeedKmh.toStringAsFixed(1)} km/h'
                      : '${RunMetricsCalculator.formatPace(activity.avgPaceSecondsPerKm)} /km',
                  icon: _isWalking ? LucideIcons.gauge : LucideIcons.zap,
                ),

                // Moving Time
                _buildStatItem(
                  label: 'TIME',
                  value: RunMetricsCalculator.formatDuration(
                    activity.movingTimeSeconds,
                  ),
                  icon: LucideIcons.clock,
                ),

                // Calories
                _buildStatItem(
                  label: 'CALORIES',
                  value: '${activity.caloriesBurned.toStringAsFixed(0)} kcal',
                  icon: LucideIcons.flame,
                ),

                // Steps if walk, or Elevation if run
                if (_isWalking)
                  _buildStatItem(
                    label: 'EST. STEPS',
                    value:
                        '${RunMetricsCalculator.estimateSteps(distanceKm: activity.distanceKm, isWalking: true)}',
                    icon: LucideIcons.personStanding,
                  )
                else
                  _buildStatItem(
                    label: 'ELEV GAIN',
                    value:
                        '+${activity.elevationGainMeters.toStringAsFixed(0)}m',
                    icon: LucideIcons.mountain,
                  ),
              ],
            ),
          ),

          // 5. Footer Watermark
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TRACKED WITH STRYDE GPS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: _secondaryTextColor,
                    shadows: _textShadows,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: _activityColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _primaryTextColor,
                shadows: _textShadows,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: _secondaryTextColor,
            shadows: _textShadows,
          ),
        ),
      ],
    );
  }
}

class RouteVectorPainter extends CustomPainter {
  final List<TrackPoint> trackPoints;
  final String activityType;

  RouteVectorPainter({required this.trackPoints, this.activityType = 'run'});

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
      final double x =
          padding + ((p.longitude - minLon) / lonRange) * drawWidth;
      // Invert Y because latitude goes north while canvas Y goes down
      final double y =
          padding + (1.0 - ((p.latitude - minLat) / latRange)) * drawHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Color routeColor = activityType == 'walk'
        ? const Color(0xFF00E5FF)
        : StrydeColors.neonGreen;

    // Outer glow paint
    final glowPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.35)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Solid line paint
    final solidPaint = Paint()
      ..color = routeColor
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, solidPaint);

    // Draw Start point (Green)
    final firstPoint = trackPoints.first;
    final double startX =
        padding + ((firstPoint.longitude - minLon) / lonRange) * drawWidth;
    final double startY =
        padding +
        (1.0 - ((firstPoint.latitude - minLat) / latRange)) * drawHeight;
    canvas.drawCircle(
      Offset(startX, startY),
      4.5,
      Paint()..color = StrydeColors.neonGreen,
    );
    canvas.drawCircle(
      Offset(startX, startY),
      2.0,
      Paint()..color = Colors.white,
    );

    // Draw Finish point (Red)
    final lastPoint = trackPoints.last;
    final double endX =
        padding + ((lastPoint.longitude - minLon) / lonRange) * drawWidth;
    final double endY =
        padding +
        (1.0 - ((lastPoint.latitude - minLat) / latRange)) * drawHeight;
    canvas.drawCircle(
      Offset(endX, endY),
      5.0,
      Paint()..color = StrydeColors.neonRed,
    );
    canvas.drawCircle(Offset(endX, endY), 2.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant RouteVectorPainter oldDelegate) {
    return oldDelegate.trackPoints != trackPoints ||
        oldDelegate.activityType != activityType;
  }
}
