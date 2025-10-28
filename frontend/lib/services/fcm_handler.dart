import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:forever/fuctions/sql_functions.dart';
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
      print('foreground notification is handled');
      Vibration.vibrate(pattern: [0, 1000, 500, 1000]);
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

  Future<void> sendMissNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('partnerToken');
    final String? name = prefs.getString('userName') ?? ' ';
    final String? partner = prefs.getString('partner_name') ?? 'Your Partner';

    print("sending to FCM Token: $token");
    if (token == null) {
      print("No token found, cannot send notification.");
      return;
    }

    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        // This `notification` block is what the OS will display
        // when your app is terminated. It ensures delivery.
        "notification": {
          "title": "Misses You $partner!",
          "body": '$name is thinking of you!',
        },

        "data": {
          "action": "vibrate",
          "senderName": name,
          "screen_to_open": "/home",
        }
      }
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

  Future<void> sendNotification(String body) async {
    print('Preparing to send notification...');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('partnerToken');
    final String? name = prefs.getString('userName') ?? 'Your Partner';

    if (token == null) {
      print("No partner token found, cannot send notification.");
      return;
    }

    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {
          "title": "Message from $name",
          "body": body,
        },
        "data": {
          "action": "message",
          "senderName": name,
          "screen_to_open": "/chat",
        }
      }
    };

    try {
      String accessToken = await FirebaseAccessToken().getAccessToken();

      final Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/forever-8938b/messages:send',
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully via FCM!");
      } else {
        print("Failed to send notification. Status: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print('An error occurred while sending the notification: $e');
    }
  }

  Future<String> getToken() async {
    String? token = await _messaging.getToken();
    print(token.toString());
    return token!;
  }
}
