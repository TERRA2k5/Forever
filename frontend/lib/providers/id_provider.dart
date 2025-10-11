import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/start_up_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


final myIdProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ref.invalidate(startupRouteProvider);
    throw Exception('No user is currently signed in.');
  }
  else{
    final id = FirebaseAuth.instance.currentUser?.uid;
    return id!.substring(0,6);
  }
});

final partnerIdProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('partner_id');
  return id;
});