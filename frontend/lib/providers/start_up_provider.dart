import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startupRouteProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return '/home';
    } else {
      return '/welcome';
    }
  });
});