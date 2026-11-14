import 'package:flutter/material.dart';
import 'stryde_colors.dart';

class StrydeTypography {
  StrydeTypography._();

  /// Primary tabular figures feature list for real-time metric counters
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  // Huge display metrics (e.g. 12.45 km, 05:23 Pace)
  static const TextStyle metricHuge = TextStyle(
    fontSize: 54,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    height: 1.0,
    color: StrydeColors.textPrimary,
    fontFeatures: tabularFigures,
  );

  static const TextStyle metricLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.1,
    color: StrydeColors.textPrimary,
    fontFeatures: tabularFigures,
  );

  static const TextStyle metricMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
    color: StrydeColors.textPrimary,
    fontFeatures: tabularFigures,
  );

  static const TextStyle metricSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: StrydeColors.textPrimary,
    fontFeatures: tabularFigures,
  );

  // Labels & Subtitles
  static const TextStyle metricLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: StrydeColors.textSecondary,
  );

  static const TextStyle labelNeon = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: StrydeColors.neonGreen,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: StrydeColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: StrydeColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: StrydeColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: StrydeColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: StrydeColors.textMuted,
  );
}

