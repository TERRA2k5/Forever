import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final myIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('my_id');

  if (id == null) {
    id = const Uuid().v4().substring(0,6);
    await prefs.setString('my_id', id);
  }

  return id;
});

final partnerIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('partner_id');

  return id!;
});