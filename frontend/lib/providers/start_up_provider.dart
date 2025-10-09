import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startupRouteProvider = FutureProvider<String>((ref) async {

  var connected = false;
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
    if (user == null) {
      connected = false;
      print('User is currently signed out!');
    } else {
      connected = true;
      print('User is signed in!');
    }
  });
  return connected ? '/home' : '/welcome';
});
