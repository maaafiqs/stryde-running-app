import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../gear/screens/gear_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultShoeAsync = ref.watch(defaultShoeProvider);

    final cardBg = isDark ? StrydeColors.surfaceCard : Colors.white;
    final borderColor = isDark ? StrydeColors.border : const Color(0xFFE2E8F0);
    final textColor = isDark ? StrydeColors.textPrimary : const Color(0xFF0F172A);
    final textMutedColor = isDark ? StrydeColors.textSecondary : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? StrydeColors.background : const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('PENGATURAN'),
        backgroundColor: isDark ? StrydeColors.background : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Developer Branding Card (developed by Maaafiqs Dev)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF131A26), const Color(0xFF0B1017)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFF1F5F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? StrydeColors.neonGreen.withValues(alpha: 0.3)
                      : const Color(0xFF00C853).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? StrydeColors.neonGreen : const Color(0xFF00C853))
                        .withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: StrydeColors.neonGreenGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: StrydeColors.neonGreen.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.zap,
                          size: 28,
                          color: StrydeColors.textOnNeon,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STRYDE APP',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isDark ? StrydeColors.neonGreen : const Color(0xFF00C853))
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? StrydeColors.neonGreen : const Color(0xFF00C853),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'developed by Maaafiqs Dev',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? StrydeColors.neonGreen : const Color(0xFF00C853),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Versi Aplikasi',
                        style: TextStyle(fontSize: 12, color: textMutedColor, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'v1.0.0+1 (Build 2026)',
                        style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Engine Pelacakan',
                        style: TextStyle(fontSize: 12, color: textMutedColor, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'GPS Real-Time Fused Telemetry',
                        style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Tema Aplikasi (Light Mode vs Dark Mode)
            Text(
              'TEMA & TAMPILAN',
              style: StrydeTypography.metricLabel.copyWith(color: textMutedColor),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildThemeOptionTile(
                    icon: LucideIcons.moon,
                    title: 'Mode Gelap (Dark Mode)',
                    subtitle: 'Tampilan atletis kontras tinggi hemat baterai OLED',
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                    textColor: textColor,
                    textMutedColor: textMutedColor,
                    isDark: isDark,
                  ),
                  Divider(height: 1, color: borderColor),
                  _buildThemeOptionTile(
                    icon: LucideIcons.sunMedium,
                    title: 'Mode Terang (Light Mode)',
                    subtitle: 'Tampilan bersih terang nyaman di bawah sinar matahari',
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                    textColor: textColor,
                    textMutedColor: textMutedColor,
                    isDark: isDark,
                  ),
                  Divider(height: 1, color: borderColor),
                  _buildThemeOptionTile(
                    icon: LucideIcons.smartphone,
                    title: 'Ikuti Sistem HP (Otomatis)',
                    subtitle: 'Menyesuaikan otomatis dengan tema sistem Android',
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                    textColor: textColor,
                    textMutedColor: textMutedColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Gear & Sepatu Lari Aktif
            Text(
              'SEPATU & PENGUKURAN JARAK',
              style: StrydeTypography.metricLabel.copyWith(color: textMutedColor),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultShoeAsync.when(
                    data: (shoe) {
                      if (shoe == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.footprints, size: 20, color: StrydeColors.neonOrange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Belum ada sepatu aktif',
                                    style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tambahkan sepatu lari Anda agar jarak setiap sesi otomatis terakumulasi.',
                              style: TextStyle(fontSize: 12, color: textMutedColor),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isDark ? StrydeColors.neonGreen : const Color(0xFF00C853))
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.footprints,
                              size: 20,
                              color: isDark ? StrydeColors.neonGreen : const Color(0xFF00C853),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sepatu Utama Aktif',
                                  style: TextStyle(fontSize: 11, color: textMutedColor, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${shoe.brand} ${shoe.model}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${shoe.totalDistanceKm.toStringAsFixed(1)} KM',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? StrydeColors.neonGreen : const Color(0xFF00C853),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const SizedBox(),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const GearScreen()),
                      );
                    },
                    icon: const Icon(LucideIcons.externalLink, size: 16),
                    label: const Text('Buka Menu Gear & Sepatu'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. GPS & Pelacakan Real-Time
            Text(
              'PELACAKAN REAL-TIME OTOMATIS',
              style: StrydeTypography.metricLabel.copyWith(color: textMutedColor),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.locateFixed, size: 18, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Presisi GPS Real-Time',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pembaruan posisi instan setiap 1 detik dengan Google Fused Location',
                              style: TextStyle(fontSize: 11, color: textMutedColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.shieldCheck, size: 18, color: Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privasi 100% Offline-First',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Data rute dan statistik tersimpan aman di database lokal HP Anda',
                              style: TextStyle(fontSize: 11, color: textMutedColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textColor,
    required Color textMutedColor,
    required bool isDark,
  }) {
    final activeColor = isDark ? StrydeColors.neonGreen : const Color(0xFF00C853);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? activeColor : textColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? activeColor : textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: textMutedColor),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : textMutedColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
