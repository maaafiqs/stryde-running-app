import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stryde_colors.dart';
import 'stryde_typography.dart';

class StrydeTheme {
  StrydeTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StrydeColors.background,
      colorScheme: const ColorScheme.dark(
        primary: StrydeColors.neonGreen,
        onPrimary: StrydeColors.textOnNeon,
        secondary: StrydeColors.neonMint,
        onSecondary: StrydeColors.textOnNeon,
        surface: StrydeColors.surfaceCard,
        onSurface: StrydeColors.textPrimary,
        error: StrydeColors.dangerRed,
        onError: StrydeColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StrydeColors.background,
        foregroundColor: StrydeColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: StrydeTypography.headline,
      ),
      cardTheme: CardThemeData(
        color: StrydeColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StrydeColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StrydeColors.neonGreen,
          foregroundColor: StrydeColors.textOnNeon,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StrydeColors.textPrimary,
          side: const BorderSide(color: StrydeColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: StrydeColors.textPrimary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: StrydeColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: StrydeColors.surfaceCard,
        selectedItemColor: StrydeColors.neonGreen,
        unselectedItemColor: StrydeColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
