import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
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
  // Optional: Handle 'message' action vibration in foreground
}

// Function to handle notification taps remains the same
Future<void> setupInteractedMessage(GlobalKey<NavigatorState> navigatorKey) async {
  // ... (implementation remains the same) ...
}

void _handleMessageTap(RemoteMessage message, GlobalKey<NavigatorState> navigatorKey) {
  // ... (implementation remains the same) ...
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
        "data": {
          "action": "vibrate",
          "screen_to_open": "/home",
        },
        // --- ✅ CORRECTED Android Specific Configuration ---
        "android": {
          "notification": {
            // Channel ID goes HERE
            "channel_id": "vibrate_channel",
            // Custom sound also goes here
            "sound": "vibe_alert",
          }
        },
        "apns": { // iOS custom sound remains the same
          "payload": { "aps": { "sound": "vibe_alert.wav" } }
        }
      }
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
        "notification": {
          "title": "Message from $name",
          "body": body,
        },
        // Data payload remains the same
        "data": {
          "action": "message",
          "screen_to_open": "/chat",
        },
        // --- ✅ CORRECTED Android Specific Configuration ---
        "android": {
          "notification": {
            // Channel ID goes HERE
            "channel_id": "message_channel"
            // You could specify a sound here too if needed
            // "sound": "default" // or a custom sound file name
          }
        }
        // No custom sound needed for iOS messages in this example
      }
    };
    await _sendFcmMessage(message);
  }

  // Helper function remains the same
  Future<void> _sendFcmMessage(Map<String, dynamic> message) async {
    try {
      String accessToken = await FirebaseAccessToken().getAccessToken();
      final Uri url = Uri.parse('https://fcm.googleapis.com/v1/projects/forever-8938b/messages:send');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      // Log the payload just before sending
      print("Sending FCM Payload: ${jsonEncode(message)}");
      final response = await http.post(url, headers: headers, body: jsonEncode(message));
      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification: Status: ${response.statusCode}, Body: ${response.body}");
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

