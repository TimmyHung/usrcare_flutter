import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:usrcare/main.dart';
import 'package:usrcare/views/home/AlarmPage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Taipei'));

    // if (await Permission.notification.isDenied) {
    //   await Permission.notification.request();
    // }

    const androidChannel = AndroidNotificationChannel(
      'alarm_channel',
      '提醒通知',
      description: '定時提醒通知',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings = AndroidInitializationSettings('notification_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  Future<void> scheduleAlarm(AlarmItem alarm) async {
    if (await Permission.notification.isDenied) return;

    final Map<String, String> notificationTitles = {
      '用藥提醒': '💊 用藥提醒',
      '活動提醒': '🏃‍♂️ 活動提醒',
      '喝水提醒': '💧 喝水提醒',
      '休息提醒': '💤 休息提醒',
    };

    for (int i = 0; i < alarm.weekdays.length; i++) {
      if (alarm.weekdays[i]) {
        final scheduledDate = _nextInstanceOfDay(
          i + 1,
          alarm.time.hour,
          alarm.time.minute,
        );

        final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

        try {
          final id = alarm.hashCode + i;
          await _notifications.zonedSchedule(
            id,
            notificationTitles[alarm.type] ?? alarm.type,
            alarm.name,
            scheduledTZ,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'alarm_channel',
                '提醒通知',
                channelDescription: '定時提醒通知',
                importance: Importance.max,
                priority: Priority.max,
                enableVibration: true,
                playSound: true,
                fullScreenIntent: true,
                category: AndroidNotificationCategory.alarm,
                visibility: NotificationVisibility.public,
                additionalFlags: Int32List.fromList(<int>[4, 32]),
                ticker: 'ticker',
                icon: 'notification_icon',
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                interruptionLevel: InterruptionLevel.timeSensitive,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: alarm.type,
          );
        } catch (e) {}
      }
    }
  }

  Future<void> cancelAlarm(AlarmItem alarm) async {
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel(alarm.hashCode + i);
    }
  }

  DateTime _nextInstanceOfDay(int day, int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now) || scheduledDate.weekday != day) {
      while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    final context = navigatorKey.currentContext;
    if (context != null) {
      bool isInHomePage = false;
      Navigator.popUntil(context, (route) {
        isInHomePage = route.settings.name == '/home';
        return isInHomePage || route.isFirst;
      });

      if (!isInHomePage) {
        Navigator.pushReplacementNamed(context, '/home');
      }

      Navigator.pushNamed(context, '/alarm', arguments: payload);
    }
  }
}
