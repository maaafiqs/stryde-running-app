import 'package:flutter/material.dart';

class StrydeColors {
  StrydeColors._();

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0B0E14);
  static const Color surfaceCard = Color(0xFF151A23);
  static const Color surfaceElevated = Color(0xFF1E2532);
  static const Color surfaceSubtle = Color(0xFF10141D);
  static const Color border = Color(0xFF232B3A);

  // Accents
  static const Color neonGreen = Color(0xFFC6FF00); // Electric Lime
  static const Color neonMint = Color(0xFF00E676);
  static const Color neonOrange = Color(0xFFFF9100);
  static const Color neonRed = Color(0xFFFF5252);
  static const Color neonCyan = Color(0xFF00E5FF);

  // Content / Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textOnNeon = Color(0xFF0B0E14);

  // Status Indicators
  static const Color activeGreen = Color(0xFF00E676);
  static const Color pausedAmber = Color(0xFFFFD600);
  static const Color dangerRed = Color(0xFFFF1744);

  // Gradient
  static const LinearGradient neonGreenGradient = LinearGradient(
    colors: [Color(0xFFC6FF00), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF181E29), Color(0xFF12161F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

