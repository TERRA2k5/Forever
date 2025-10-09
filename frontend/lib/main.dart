import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/MainContainer.dart';
import 'package:forever/UI/SignUp.dart';
import 'package:forever/UI/WelcomePage.dart';
import 'package:forever/providers/start_up_provider.dart';
import 'package:forever/services/background.dart';
import 'package:forever/services/fcm_handler.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FcmHandler().initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupRoute = ref.watch(startupRouteProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const Maincontainer(),
        '/signup': (context) => const SignUpScreen(),
      },
      home: startupRoute.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
        data: (route) {
          if (route == '/home') {
            return const Maincontainer();
          }
          return const WelcomeScreen();
        },
      ),
    );
  }
}

// The NavigatorPage class is no longer needed and has been removed.
