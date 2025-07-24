import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final startupRouteProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final connected = prefs.getBool('connected') ?? false;
  return connected ? '/home' : '/welcome';
});
