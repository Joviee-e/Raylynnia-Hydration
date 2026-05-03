import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/constants/notification_constants.dart';
import '../../domain/entities/reminder_schedule.dart';

class NotificationManager {
  NotificationManager(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

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
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final DarwinFlutterLocalNotificationsPlugin? darwinPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            DarwinFlutterLocalNotificationsPlugin>();

    if (Platform.isAndroid) {
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }

    return await darwinPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
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

    for (int i = 0; i < boundedTimes.length; i++) {
      final DateTime scheduledAt = boundedTimes[i];
      final int id = _notificationIdFor(scheduledAt, i);
      final String payload = jsonEncode(<String, String>{
        'type': NotificationConstants.hydrationPayloadType,
        'scheduledAt': scheduledAt.toIso8601String(),
      });

      await (_plugin as dynamic).schedule(
        id,
        'Hydration Reminder',
        'Time to drink some water.',
        scheduledAt,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationConstants.hydrationChannelId,
            NotificationConstants.hydrationChannelName,
            channelDescription: NotificationConstants.hydrationChannelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  int _notificationIdFor(DateTime dateTime, int slotIndex) {
    return Object.hash(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
            dateTime.minute, slotIndex) &
        0x7fffffff;
  }
}
