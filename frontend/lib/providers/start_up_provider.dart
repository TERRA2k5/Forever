import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startupRouteProvider = StreamProvider<String>((ref) {
  // You give the StreamProvider the radio station to listen to.
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    // It automatically listens and runs this logic EVERY TIME a new event is broadcast.
    if (user != null) {
      return '/home'; // User just logged in!
    } else {
      return '/welcome'; // User just logged out!
    }
  });
});