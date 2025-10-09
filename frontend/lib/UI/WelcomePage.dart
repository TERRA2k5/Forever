import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/services/firebaseAuth_service.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  late final TextEditingController _emailIdController;
  late final TextEditingController _passwordIdController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _emailIdController = TextEditingController();
    _passwordIdController = TextEditingController();
  }

  @override
  void dispose() {
    _emailIdController.dispose();
    _passwordIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 120),
            // --- App Title ---
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: textTheme.displaySmall?.copyWith(height: 1.2),
                children: [
                  const TextSpan(
                    text: 'Together\n',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextSpan(
                    text: 'Forever ♡',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),

            // // --- Your ID Card ---
            //
            // const SizedBox(height: 32),

            // --- Input Fields ---
            TextField(
              controller: _emailIdController,
              decoration: const InputDecoration(
                labelText: "Email ID",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _passwordIdController,
              obscureText: _isVisible,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  icon: Icon(
                    _isVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // Navigate to Forgot Password Screen
                FirebaseAuth.instance.sendPasswordResetEmail(
                  email: _emailIdController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Password reset email sent to entered emailID!",
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Forgot Password ?',
                textAlign: TextAlign.right,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 64),

            // --- Connect Button ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: textTheme.titleMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                String email = _emailIdController.text.trim();
                String password = _passwordIdController.text.trim();
                AuthService().loginUser(context, email, password, ref);
              },
              icon: const Icon(Icons.link),
              label: const Text("Connect"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signup',
                  (route) => false,
                );
                // Navigator.pop(context);
              },
              child: Text(
                "Don't have an account? Sign Up",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
