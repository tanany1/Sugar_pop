import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static StreamController<NotificationResponse> streamController =
  StreamController();

  static onTap(NotificationResponse notificationResponse) {
    streamController.add(notificationResponse);
  }

  static Future init() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
      await Permission.ignoreBatteryOptimizations.request();
    }

    if (await Permission.notification.isPermanentlyDenied) {
      openAppSettings();
    }

    InitializationSettings settings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_reminders',
      'Medication Reminders',
      importance: Importance.max,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Schedule a notification for medication at a specific time each day
  static Future<void> scheduleMedicationReminder(
      String medicationId, String medicationName, TimeOfDay time) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    NotificationDetails details = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert medicationId string to an integer for notification ID
    final int notificationId = medicationId.hashCode;

    // Calculate the next occurrence of the specified time
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past for today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // First, cancel any existing notifications for this medication
    await cancelMedicationReminder(medicationId);

    // Convert to timezone-aware DateTime
    final tz.TZDateTime scheduledTzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    // Schedule the notification using zonedSchedule for exact timing
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Medication Reminder',
      'Time to take $medicationName',
      scheduledTzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily at the same time
    );

    // For debugging purposes
    print('Scheduled notification for $medicationName at ${scheduledTzDateTime.toString()}');
  }

  // Cancel a specific medication reminder
  static Future<void> cancelMedicationReminder(String medicationId) async {
    await flutterLocalNotificationsPlugin.cancel(medicationId.hashCode);
    await flutterLocalNotificationsPlugin.cancel(medicationId.hashCode + 1000);
  }

  // Check if it's the exact medication time (for UI highlighting only)
  static bool isMedicationTime(TimeOfDay medicationTime) {
    final now = TimeOfDay.now();

    // Only return true if the hour and minute match exactly
    return now.hour == medicationTime.hour && now.minute == medicationTime.minute;
  }
}