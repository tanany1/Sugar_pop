// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     tz.initializeTimeZones();
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );
//
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // Handle notification tap
//       },
//     );
//
//     // Request permissions
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestPermission();
//   }
//
//   static Future<void> scheduleNotification({
//     required String id,
//     required String medicineName,
//     required TimeOfDay time,
//   }) async {
//     final now = DateTime.now();
//     DateTime scheduleDate = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         time.hour,
//         time.minute
//     );
//
//     // If the time is in the past, schedule for tomorrow
//     if (scheduleDate.isBefore(now)) {
//       scheduleDate = scheduleDate.add(const Duration(days: 1));
//     }
//
//     await _notificationsPlugin.zonedSchedule(
//       id.hashCode, // Use hashCode as a unique integer ID
//       'Medication Reminder',
//       'Remember to take your $medicineName',
//       tz.TZDateTime.from(scheduleDate, tz.local),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'medicines_channel',
//           'Medicines',
//           channelDescription: 'Medication reminders',
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/ic_launcher',
//         ),
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//       payload: id,
//     );
//   }
//
//   static Future<void> cancelNotification(String id) async {
//     await _notificationsPlugin.cancel(id.hashCode);
//   }
//
//   static Future<void> cancelAllNotifications() async {
//     await _notificationsPlugin.cancelAll();
//   }
// }