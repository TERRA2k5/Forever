import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/services/fcm_handler.dart';
import 'package:forever/services/firebase_access_token.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLocation(
  String myId,
  double latitude,
  double longitude,
) async {

  SharedPreferences pref = await SharedPreferences.getInstance();
  final email = pref.getString('userEmail');

  final url = Uri.parse('https://forever-c5as.onrender.com/location');
  String token = await FcmHandler().getToken();
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': myId,
      'latitude': latitude,
      'longitude': longitude,
      'fcm': token,
      'email': email
    }),
  );
  print('Saving in progress for $myId: ($latitude, $longitude) with token $token');

  if (response.statusCode == 201 || response.statusCode == 200) {
    final json = jsonDecode(response.body);
    print('Success: $json');
  } else {
    print('Failed with status: ${response.statusCode}');
    print('Body: ${response.body}');
  }
}


Future<void> updateName(
    String Id,
    String name
    ) async {


  final url = Uri.parse('https://forever-c5as.onrender.com/updateName');
  String token = await FcmHandler().getToken();
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': Id,
      'fcm': token,
      'name': name,
    }),
  );
  print('Updating name in progress for $Id: ($name) with token $token');

  if (response.statusCode == 201 || response.statusCode == 200) {
    final json = jsonDecode(response.body);
    print('Success: $json');
  } else {
    print('Failed with status: ${response.statusCode}');
    print('Body: ${response.body}');
  }
}

// Future<String?> fetchFCM(String id) async {
//   print('Fetching FCM token for $id');
//   try {
//     final url = Uri.parse('https://forever-c5as.onrender.com/userPositions');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'id': id}),
//     );
//
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       final fcm = json['data']['fcm'];
//
//       if (fcm == null || fcm.isEmpty) {
//         print('No FCM token found for partner $id');
//         return null;
//       } else {
//         print('FCM token for partner ID $id: $fcm');
//
//         return fcm;
//       }
//     } else {
//       print('Failed with status: ${response.statusCode}');
//       return null;
//     }
//   } catch (e) {
//     print('Error fetching partner FCM: $e');
//     return null;
//   }
// }

Future<Position?> fetchLocation(String id) async {
  print('Fetching location for $id');
  try {
    final url = Uri.parse('https://forever-c5as.onrender.com/userPositions');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final lat = json['data']['latitude'];
      final lon = json['data']['longitude'];
      final fcm = json['data']['fcm'];
      final name = json['data']['name'];
      final email = json['data']['email'];

      final pref = await SharedPreferences.getInstance();

      await pref.setString("userName", name);
      await pref.setString("userEmail", email);

      if(fcm == null || fcm.isEmpty) {
        print('No FCM token found for partner $id');
      }
      else {
        print('FCM token for partner ID $id: $fcm');
        pref.setString('partnerToken', fcm);
      }

      print('Fetched location for ID ${response.body}');

      if (lat == null || lon == null) {
        return null;
      }
      return Position(
        latitude: lat.toDouble(),
        longitude: lon.toDouble(),
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        speed: 0,
        speedAccuracy: 0,
        heading: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } else {
      print('Failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching partner location: $e');
    return null;
  }
}

Future<String?> fetchName(String id) async {
  print('Fetching location for $id');
  try {
    final url = Uri.parse('https://forever-c5as.onrender.com/userPositions');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);


      final name = json['data']['name'];

      final pref = await SharedPreferences.getInstance();
      await pref.setString("userName", name);


      print('Fetched name for ID ${response.body}');

      return name;
    } else {
      print('Failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching partner name: $e');
    return null;
  }
}
