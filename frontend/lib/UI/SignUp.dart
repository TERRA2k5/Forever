import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/services/firebaseAuth_service.dart'; // Make sure this path is correct

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // Controllers are managed in the state to preserve text on rebuilds
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _isVisible = true;
  bool _isVisibleConf = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                // --- App Title (Same as WelcomeScreen) ---
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: textTheme.displaySmall?.copyWith(height: 1.2),
                    children: [
                      const TextSpan(
                        text: 'Create Your\n',
                        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                      ),
                      TextSpan(
                        text: 'Account ♡',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),

                // --- Input Fields ---
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name / Pet name",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email ID",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _isVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                        icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isVisibleConf,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        _isVisibleConf = !_isVisibleConf;
                      });
                    },
                        icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility)),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Sign Up Button ---
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: textTheme.titleMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    AuthService().createUser(
                      context,
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                      _confirmPasswordController.text.trim(),
                      _nameController.text.trim(),
                      ref
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text("Sign Up"),
                ),
                const SizedBox(height: 20),

                // --- Navigation back to Login ---
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                    // Navigator.pop(context);
                  },
                  child: Text(
                    "Already have an account? Log In",
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}