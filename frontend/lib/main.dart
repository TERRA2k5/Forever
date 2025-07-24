import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/UI/HomePage.dart';
import 'package:forever/UI/WelcomePage.dart';
import 'package:forever/providers/start_up_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupRoute = ref.watch(startupRouteProvider);

    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/welcome': (context) => WelcomeScreen(),
          '/home': (context) => const MapScreen(),
        },
        home: startupRoute.when(
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
          data: (route) => NavigatorPage(route: route),
        ),
      ),
    );
  }
}

class NavigatorPage extends StatelessWidget {
  final String route;

  const NavigatorPage({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, route);
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
