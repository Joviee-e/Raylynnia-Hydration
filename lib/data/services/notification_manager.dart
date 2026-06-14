import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../core/constants/notification_constants.dart';
import '../../domain/entities/reminder_schedule.dart';

class NotificationManager {
  NotificationManager(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const MethodChannel _exactAlarmChannel =
      MethodChannel('com.example.raylynnia_hydration/exact_alarm');

  static const List<String> _bodies = [
    'A small sip now keeps you energized.',
    'Your body will thank you for a glass of water.',
    'Stay refreshed and on track today.',
    'Water is flow. Take a mindful sip.',
    'Keep your inner sanctuary refreshed.',
    'Sip gently and continue your day with clarity.',
  ];

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationConstants.hydrationChannelId,
        NotificationConstants.hydrationChannelName,
        description: NotificationConstants.hydrationChannelDescription,
        importance: Importance.max,
      ),
    );

    // Initialize timezones and set device's local timezone
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback if local timezone detection fails
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
  }

  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (Platform.isAndroid) {
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }

    return await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
  }

  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    try {
      final bool? canSchedule = await _exactAlarmChannel.invokeMethod<bool>('canScheduleExactAlarms');
      return canSchedule ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {}
  }

  Future<void> cancelAll() {
    return _plugin.cancelAll();
  }

  Future<void> scheduleAll(ReminderSchedule schedule) async {
    final List<DateTime> times = schedule.times;
    final int limit = Platform.isIOS
        ? NotificationConstants.iosMaxPendingNotifications
        : times.length;

    final List<DateTime> boundedTimes = times.take(limit).toList(growable: false);
    final Random random = Random();

    // Check exact alarm permissions
    final bool hasExact = await hasExactAlarmPermission();
    final AndroidScheduleMode scheduleMode = hasExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (int i = 0; i < boundedTimes.length; i++) {
      final DateTime scheduledAt = boundedTimes[i];
      // Only schedule future reminder times
      if (scheduledAt.isBefore(DateTime.now())) {
        continue;
      }

      final int id = _notificationIdFor(scheduledAt, i);
      final String payload = jsonEncode(<String, String>{
        'type': NotificationConstants.hydrationPayloadType,
        'scheduledAt': scheduledAt.toIso8601String(),
      });

      final String body = _bodies[random.nextInt(_bodies.length)];

      try {
        await _plugin.zonedSchedule(
          id,
          'Time to Hydrate 💧',
          body,
          tz.TZDateTime.from(scheduledAt, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.hydrationChannelId,
              NotificationConstants.hydrationChannelName,
              channelDescription: NotificationConstants.hydrationChannelDescription,
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (e) {
        // Safe fallback: try scheduling with inexact mode if exact fails
        try {
          await _plugin.zonedSchedule(
            id,
            'Time to Hydrate 💧',
            body,
            tz.TZDateTime.from(scheduledAt, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                NotificationConstants.hydrationChannelId,
                NotificationConstants.hydrationChannelName,
                channelDescription: NotificationConstants.hydrationChannelDescription,
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload,
          );
        } catch (_) {
          // Fail silently to prevent crashing or preventing saves
        }
      }
    }
  }

  int _notificationIdFor(DateTime dateTime, int slotIndex) {
    return Object.hash(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
            dateTime.minute, slotIndex) &
        0x7fffffff;
  }
}
