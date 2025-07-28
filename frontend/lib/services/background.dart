import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📥 Background message received: ${message.data}");

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'vibrate_channel',
    'Vibrate Channel',
    channelDescription: 'Used for partner vibration alerts',
    importance: Importance.max,
    priority: Priority.high,
    vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    playSound: false,
  );

  NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  ));

  await plugin.show(
    0,
    message.data['title'] ?? '💖 Miss You',
    message.data['body'] ?? 'Your partner is thinking of you!',
    notificationDetails,
  );
}
