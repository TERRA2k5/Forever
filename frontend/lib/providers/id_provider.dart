import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/start_up_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


final myIdProvider = FutureProvider.autoDispose<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid.substring(0,6);
});

final partnerIdProvider = FutureProvider.autoDispose<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('partner_id');
  return id;
});