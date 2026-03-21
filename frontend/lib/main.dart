import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/MainContainer.dart';
import 'package:forever/UI/CallPage.dart';
import 'package:forever/UI/SignUp.dart';
import 'package:forever/UI/WelcomePage.dart';
import 'package:forever/UI/ChatPage.dart';
import 'package:forever/providers/start_up_provider.dart';
import 'package:forever/services/background.dart';
import 'package:forever/services/callKit_service.dart';
import 'package:forever/services/fcm_handler.dart';
import 'firebase_options.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FcmHandler(navigatorKey: navigatorKey).initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MyApp()));
}
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  @override
  void initState() {
    super.initState();
    // ✅ 4. Start listening for the CallKit Accept/Decline buttons!
    CallKitService().handleIncoming();
  }

  @override
  Widget build(BuildContext context) {
    final startupRoute = ref.watch(startupRouteProvider);

    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ 5. Attach the key to the app!
      debugShowCheckedModeBanner: false,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const Maincontainer(),
        '/signup': (context) => const SignUpScreen(),
        '/chat': (context) => ChatScreen(),
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