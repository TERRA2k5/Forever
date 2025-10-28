import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// Remove local notifications import, it's not needed here anymore
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart'; // Import the vibration package

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase (required in background isolate)
  await Firebase.initializeApp();
  print("📥 Background message received! Action: ${message.data['action']}");

  // --- ✅ THE FIX: Only trigger vibration, DO NOT show a local notification ---
  // The OS will already show the notification based on the FCM payload's
  // 'notification' block. This handler's job is just to add the custom
  // vibration if it's the 'vibrate' action.

  if (message.data['action'] == 'vibrate') {
    print('Action is "vibrate". Triggering custom vibration pattern.');
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Directly trigger the custom vibration pattern.
      // The OS handles showing the notification itself.
      Vibration.vibrate(pattern: [0, 1000, 500, 1000], amplitude: 128);
    }
  } else {
    // If it's a 'message' or any other action, DO NOTHING in this handler.
    // The OS will display the notification based on the FCM payload's
    // 'notification' block and the 'message_channel' settings (sound+vibration).
    print("Action is not 'vibrate'. Letting OS handle the standard notification display.");
  }
}