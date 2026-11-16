import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/stryde_colors.dart';
import '../analytics/screens/analytics_screen.dart';
import '../gear/screens/gear_screen.dart';
import '../history/screens/history_screen.dart';
import '../settings/screens/settings_screen.dart';
import '../tracker/screens/live_run_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LiveRunScreen(),
    HistoryScreen(),
    AnalyticsScreen(),
    GearScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? StrydeColors.surfaceCard : Colors.white;
    final navBorder = isDark ? StrydeColors.border : const Color(0xFFE2E8F0);
    final activeColor = isDark ? StrydeColors.neonGreen : const Color(0xFF00C853);
    final inactiveColor = isDark ? StrydeColors.textSecondary : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? StrydeColors.background : const Color(0xFFF6F8FA),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: navBorder, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: navBg,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.playCircle),
              activeIcon: Icon(LucideIcons.playCircle, color: activeColor),
              label: 'TRACK',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.history),
              activeIcon: Icon(LucideIcons.history, color: activeColor),
              label: 'HISTORY',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.barChart2),
              activeIcon: Icon(LucideIcons.barChart2, color: activeColor),
              label: 'ANALYTICS',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.footprints),
              activeIcon: Icon(LucideIcons.footprints, color: activeColor),
              label: 'GEAR',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.settings),
              activeIcon: Icon(LucideIcons.settings, color: activeColor),
              label: 'SETTING',
            ),
          ],
        ),
      ),
    );
  }
}
