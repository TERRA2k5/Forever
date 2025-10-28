import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize the plugin once as a global variable for efficiency.
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // It's crucial to initialize Firebase first in the background isolate.
  await Firebase.initializeApp();
  print("📥 Background message received! Handling with custom notification.");
  print("Action: ${message.data['action']}");

  // Initialize the plugin. This is safe to call multiple times.
  await _flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  ));

  AndroidNotificationDetails androidDetails;

  if (message.data['action'] == 'message') {

    print("Action is 'message'. Configuring notification with sound.");
    androidDetails = const AndroidNotificationDetails(
      'message_channel', // Use a different channel ID for messages
      'Message Channel',
      channelDescription: 'Used for incoming chat messages',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // <-- PLAY SOUND IS ENABLED
    );
  } else {
    // For any other action (like 'vibrate'), use your custom pattern.
    print("Action is not 'message'. Configuring notification with custom vibration.");
    androidDetails = AndroidNotificationDetails(
      'vibrate_channel',
      'Vibrate Channel',
      channelDescription: 'Used for special partner vibration alerts',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: false, // <-- PLAY SOUND IS DISABLED
    );
  }

  // Build the final notification details for the local notification.
  NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  // Get title and body from the reliable `notification` payload.
  final String title = message.notification?.title ?? 'New Notification';
  final String body = message.notification?.body ?? 'You have a new message.';

  // Show the local notification with the correct, conditional details.
  await _flutterLocalNotificationsPlugin.show(
    // ⭐ BEST PRACTICE: Use a unique ID for each notification.
    // This ensures new messages don't just replace the old ones.
    DateTime.now().millisecondsSinceEpoch.toSigned(31),
    title,
    body,
    notificationDetails,
  );
}