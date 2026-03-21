import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:forever/UI/CallPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'callKit_service.dart';
import 'firebase_access_token.dart';

// Foreground handler remains the same
Future<void> _handleForegroundVibration(RemoteMessage message) async {
  print("Foreground message received! Action: ${message.data['action']}");
  if (message.data['action'] == 'vibrate') {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [0, 1000, 500, 1000], amplitude: 128);
    }
  }
  if (message.data['action'] == 'incoming_call') {
    final callerName = message.data['caller_name'] ?? 'Unknown';
    final channelName = message.data['channel_name'];
    final isVideo = message.data['is_video'] == 'true';

    CallKitService().showIncoming(callerName, channelName, isVideo);
  }
}

Future<void> setupInteractedMessage(
  GlobalKey<NavigatorState> navigatorKey,
) async {
  // SCENARIO 1: App is completely dead / terminated
  // Get any messages which caused the application to open from a terminated state.
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessageTap(initialMessage, navigatorKey);
  }

  // SCENARIO 2: App is minimized in the background
  // Also handle any interaction when the app is in the background via a Stream listener
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleMessageTap(message, navigatorKey);
  });
}

void _handleMessageTap(
  RemoteMessage message,
  GlobalKey<NavigatorState> navigatorKey,
) {
  print("User tapped a notification! Action: ${message.data['action']}");

  if (message.data['action'] == 'message') {
    navigatorKey.currentState?.pushNamed('/chat');
  }

  // if (message.data['action'] == 'incoming_call') {
  //   // Extract the call data
  //   final channelName = message.data['channel_name'];
  //   final isVideo = message.data['is_video'] == 'true';
  //
  //   navigatorKey.currentState?.push(
  //     MaterialPageRoute(
  //       builder: (context) => CallScreen(
  //         channelName: channelName,
  //         isVideoCall: isVideo,
  //       ),
  //     ),
  //   );
  // }
}

class FcmHandler {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState>? navigatorKey;

  FcmHandler({this.navigatorKey});

  Future<void> initialize() async {
    await _messaging.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleForegroundVibration);
    if (navigatorKey != null) {
      await setupInteractedMessage(navigatorKey!);
    }
  }

  // --- SEND "VIBRATE" NOTIFICATION ---
  Future<void> sendVibrationNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('partnerToken');
    final partnerName = prefs.getString('partner_name') ?? 'You';
    final String? name = prefs.getString('userName') ?? 'Your Partner';
    if (token == null) return;

    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        // Standard notification block (used by iOS and as base for Android)
        "notification": {
          "title": "Miss you, $partnerName!💖",
          "body": '$name sent you a vibe!',
        },
        // Data payload remains the same
        "data": {"action": "vibrate", "screen_to_open": "/home"},
        // --- ✅ CORRECTED Android Specific Configuration ---
        "android": {
          "priority": "HIGH",
          "notification": {
            // Channel ID goes HERE
            "channelId": "vibrate_channel",
            // Custom sound also goes here
            "sound": "vibe_alert",
          },
        },
        "apns": {
          // iOS custom sound remains the same
          "headers": {"apns-priority": "10"},
          "payload": {
            "aps": {"sound": "vibe_alert.wav"},
          },
        },
      },
    };
    await _sendFcmMessage(message);
  }

  // --- SEND "MESSAGE" NOTIFICATION ---
  Future<void> sendNotification(String body) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('partnerToken');
    final String? name = prefs.getString('userName') ?? 'Your Partner';
    if (token == null) return;

    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        // Standard notification block
        "notification": {"title": "Message from $name", "body": body},
        // Data payload remains the same
        "data": {"action": "message", "screen_to_open": "/chat"},
        // --- ✅ CORRECTED Android Specific Configuration ---
        "android": {
          "notification": {
            // Channel ID goes HERE
            "channelId": "message_channel",
            // You could specify a sound here too if needed
            // "sound": "default" // or a custom sound file name
          },
        },
        // No custom sound needed for iOS messages in this example
      },
    };
    await _sendFcmMessage(message);
  }

  // --- SEND "INCOMING CALL" NOTIFICATION ---
  Future<void> sendCallNotification({
    required String channelName,
    required bool isVideo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('partnerToken');
    final String? name = prefs.getString('userName') ?? 'Your Partner';

    if (token == null) {
      print("No partner token found, cannot ring phone.");
      return;
    }

    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        // Notice: NO "notification" block! This is a silent data payload.
        "data": {
          "action": "incoming_call",
          "channel_name": channelName,
          "caller_name": name,
          "is_video": isVideo.toString(),
        },
        // Force high priority so it delivers instantly even in doze mode
        "android": {"priority": "HIGH"},
        "apns": {
          "headers": {"apns-priority": "10"},
        },
      },
    };

    await _sendFcmMessage(message);
  }

  // Helper function remains the same
  Future<void> _sendFcmMessage(Map<String, dynamic> message) async {
    try {
      String accessToken = await FirebaseAccessToken().getAccessToken();
      final Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/forever-8938b/messages:send',
      );
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      // Log the payload just before sending
      print("Sending FCM Payload: ${jsonEncode(message)}");
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(message),
      );
      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print(
          "Failed to send notification: Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print('Sending notification failed: $e');
    }
  }

  Future<String> getToken() async {
    String? token = await _messaging.getToken();
    print("FCM Token: ${token.toString()}"); // Added log for clarity
    return token!;
  }
}
