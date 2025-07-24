import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fuctions/sql_functions.dart';

final partnerLocationProvider = FutureProvider<Position?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final partnerId = prefs.getString('partner_id');
  if (partnerId == null) return null;

  return await fetchLocation(partnerId);
});
