import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<void> saveLocation(
  String myId,
  double latitude,
  double longitude,
) async {
  final url = Uri.parse('https://forever-c5as.onrender.com/location');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': myId,
      'latitude': latitude,
      'longitude': longitude,
    }),
  );

  if (response.statusCode == 201) {
    final json = jsonDecode(response.body);
    print('Success: $json');
  } else {
    print('Failed with status: ${response.statusCode}');
    print('Body: ${response.body}');
  }
}

Future<Position?> fetchLocation(String id) async {
  try {
    final url = Uri.parse('https://forever-c5as.onrender.com/getLocation');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);

      final lat = json['latitude'];
      final lon = json['longitude'];

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

