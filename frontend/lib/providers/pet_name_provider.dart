import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/fuctions/sql_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

final petNameProvider = FutureProvider.autoDispose<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final partnerId = prefs.getString('partner_id');
  if (partnerId == null) return null;
  // print("Partner called with ID: $partnerId");
  String? name = await fetchName(partnerId);
  final pref = await SharedPreferences.getInstance();
  await pref.setString("partner_name", name ?? "Partner Name");
  return await name;
});

final userNameProvider = FutureProvider.autoDispose<String?>((ref) async {
  final Id = FirebaseAuth.instance.currentUser?.uid.substring(0,6);
  if (Id == null) return null;

  String? name = await fetchName(Id);
  final pref = await SharedPreferences.getInstance();
  await pref.setString("userName", name ?? "Enter Your Name");
  return await name;
});