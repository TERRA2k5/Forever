import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:forever/services/callKit_service.dart';
import 'package:uuid/uuid.dart';
// Remove local notifications import, it's not needed here anymore
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart'; // Import the vibration package

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase (required in background isolate)
  await Firebase.initializeApp();
  print("📥 Background message received! Action: ${message.data['action']}");

  if (message.data['action'] == 'vibrate') {
    print('Action is "vibrate". Triggering custom vibration pattern.');
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Directly trigger the custom vibration pattern.
      // The OS handles showing the notification itself.
      Vibration.vibrate(pattern: [0, 1000, 500, 1000], amplitude: 128);
    }
  }
  if (message.data['action'] == 'incoming_call') {
    final callerName = message.data['caller_name'] ?? 'Unknown';
    final channelName = message.data['channel_name'];
    final isVideo = message.data['is_video'] == 'true';
    Vibration.vibrate(pattern: [0, 500, 1000, 500], amplitude: 255);
    CallKitService().showIncoming(callerName, channelName, isVideo);
  }
}