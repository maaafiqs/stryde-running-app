import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/background_service_manager.dart';
import 'core/theme/stryde_theme.dart';
import 'features/home/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF151A23),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize background tracking foreground service
  try {
    await BackgroundServiceManager.initialize();
  } catch (e) {
    debugPrint('Background service init notice: $e');
  }

  runApp(
    const ProviderScope(
      child: StrydeApp(),
    ),
  );
}

class StrydeApp extends StatelessWidget {
  const StrydeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stryde',
      debugShowCheckedModeBanner: false,
      theme: StrydeTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
