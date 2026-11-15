import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('updateMetrics').listen((event) {
    if (service is AndroidServiceInstance && event != null) {
      try {
        final String distance = event['distance'] as String? ?? '0.00 km';
        final String duration = event['duration'] as String? ?? '00:00';
        final String pace = event['pace'] as String? ?? '--:--';

        service.setForegroundNotificationInfo(
          title: 'Stryde • $distance',
          content: 'Time: $duration  |  Pace: $pace /km',
        );
      } catch (e) {
        debugPrint('Error updating notification: $e');
      }
    }
  });
}

@pragma('vm:entry-point')
class BackgroundServiceManager {
  BackgroundServiceManager._();

  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<void> initialize() async {
    try {
      await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: false,
          isForegroundMode: true,
          notificationChannelId: 'stryde_tracking_channel',
          initialNotificationTitle: 'Stryde Run Tracker',
          initialNotificationContent: 'Recording run session...',
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
      );
    } catch (e) {
      debugPrint('Background service configure warning: $e');
    }
  }

  static Future<void> startService() async {
    try {
      final isRunning = await _service.isRunning();
      if (!isRunning) {
        await _service.startService();
      }
    } catch (e) {
      debugPrint('BackgroundService start error: $e');
    }

    try {
      await WakelockPlus.enable();
    } catch (e) {
      debugPrint('Wakelock enable notice: $e');
    }
  }

  static Future<void> stopService() async {
    try {
      final isRunning = await _service.isRunning();
      if (isRunning) {
        _service.invoke('stopService');
      }
    } catch (e) {
      debugPrint('BackgroundService stop error: $e');
    }

    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('Wakelock disable notice: $e');
    }
  }

  static void updateNotification({
    required String distance,
    required String duration,
    required String pace,
  }) {
    try {
      _service.invoke('updateMetrics', {
        'distance': distance,
        'duration': duration,
        'pace': pace,
      });
    } catch (e) {
      debugPrint('Update notification error: $e');
    }
  }
}
