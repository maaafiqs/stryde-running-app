import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/stryde_colors.dart';
import '../analytics/screens/analytics_screen.dart';
import '../gear/screens/gear_screen.dart';
import '../history/screens/history_screen.dart';
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StrydeColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: StrydeColors.surfaceCard,
          border: Border(
            top: BorderSide(color: StrydeColors.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: StrydeColors.surfaceCard,
          selectedItemColor: StrydeColors.neonGreen,
          unselectedItemColor: StrydeColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.playCircle),
              activeIcon: Icon(LucideIcons.playCircle, color: StrydeColors.neonGreen),
              label: 'TRACK',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.history),
              activeIcon: Icon(LucideIcons.history, color: StrydeColors.neonGreen),
              label: 'HISTORY',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.barChart2),
              activeIcon: Icon(LucideIcons.barChart2, color: StrydeColors.neonGreen),
              label: 'ANALYTICS',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.archive),
              activeIcon: Icon(LucideIcons.archive, color: StrydeColors.neonGreen),
              label: 'GEAR',
            ),
          ],
        ),
      ),
    );
  }
}
