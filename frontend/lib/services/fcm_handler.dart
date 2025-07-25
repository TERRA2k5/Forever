import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

import 'firebase_access_token.dart';

Future<void> _handleVibration(Map<String, dynamic> data) async {
  if (data['action'] == 'vibrate') {
    // if (kDebugMode) {
    print("Vibration action received!");
    // }

    bool? hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator == true) {
      Vibration.vibrate(duration: 1000, amplitude: 128);
    }
  }
}

class FcmHandler {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission();

    String accessToken = await FirebaseAccessToken().getAccessToken();

    print("--- FCM TOKEN ---");
    print(accessToken);
    print("-----------------");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleVibration(message.data);
    });
  }

  Future<void> sendNotification() async {
    final pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('partnerToken');
    if (token == null) {
      print("No token found, cannot send notification.");

      return;
    }

    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        "data": {"action": "vibrate"},
      },
    };

    String accessToken = await FirebaseAccessToken().getAccessToken();

    final Uri url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/forever-8938b/messages:send',
    );

    final Map<String, String> headers = {
      'Content-Type': 'application/json',

      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print('Sending notification failed: $e');
    }
  }
}
