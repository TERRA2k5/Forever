import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<void> saveLocation(String myId, double latitude, double longitude) async {
  final url = Uri.parse('http://localhost:3000/location');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'id': myId,
      'latitude': latitude,
      'longitude': longitude,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    print('Success: $json');
  } else {
    print('Failed with status: ${response.statusCode}');
    print('Body: ${response.body}');
  }
}

Future<Position?> fetchLocation(String Id) async {
  final url = Uri.parse('http://localhost:3000/getLocation');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'id': Id,
    }),
  );
  Position? position = null;

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    print('Success: $json');
    position = Position(
      longitude: json['longitude'],
      latitude: json['latitude'],
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      speed: 0,
      speedAccuracy: 0,
      heading: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0
    );
  } else {
    print('Failed with status: ${response.statusCode}');
    print('Body: ${response.body}');
  }
  return position;
}
