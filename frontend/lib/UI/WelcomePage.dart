import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/id_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  WelcomeScreen({super.key});

  final partnerIdControllerProvider = Provider<TextEditingController>((ref) {
    return TextEditingController();
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myIdAsync = ref.watch(myIdProvider);
    final partnerController = ref.watch(partnerIdControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(
        "Forever",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 25,
        ),
      ),),
      body: myIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (myId) => Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100,),
                Text("Your ID:", style: Theme.of(context).textTheme.titleLarge),
                SelectableText(myId, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 40),
                TextField(
                  controller: partnerController,
                  decoration: const InputDecoration(
                    labelText: "Enter Partner's ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('partner_id', partnerController.text.trim());
                    await prefs.setBool('connected', true);
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Text("Connect"),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
