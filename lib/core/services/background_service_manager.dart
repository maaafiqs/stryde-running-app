import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BackgroundServiceManager {
  BackgroundServiceManager._();

  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<void> initialize() async {
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
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    service.on('updateMetrics').listen((event) {
      if (service is AndroidServiceInstance && event != null) {
        final String distance = event['distance'] as String? ?? '0.00 km';
        final String duration = event['duration'] as String? ?? '00:00';
        final String pace = event['pace'] as String? ?? '--:--';

        service.setForegroundNotificationInfo(
          title: 'Stryde • $distance',
          content: 'Time: $duration  |  Pace: $pace /km',
        );
      }
    });
  }

  static Future<void> startService() async {
    final isRunning = await _service.isRunning();
    if (!isRunning) {
      await _service.startService();
    }
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  static Future<void> stopService() async {
    final isRunning = await _service.isRunning();
    if (isRunning) {
      _service.invoke('stopService');
    }
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  static void updateNotification({
    required String distance,
    required String duration,
    required String pace,
  }) {
    _service.invoke('updateMetrics', {
      'distance': distance,
      'duration': duration,
      'pace': pace,
    });
  }
}
