import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/services/firebaseAuth_service.dart'; // Make sure path is correct
import 'package:forever/utils/CostomButton.dart';
import 'package:forever/utils/IdCard.dart';
import 'package:forever/utils/alertboxes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fuctions/sql_functions.dart';
import '../providers/id_provider.dart';
import '../providers/my_location_provider.dart';
import '../providers/pet_name_provider.dart';

// Assuming userNameProvider is defined in id_provider.dart or imported

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all necessary providers at the top
    final myIdAsync = ref.watch(myIdProvider);
    final partnerIdAsync = ref.watch(partnerIdProvider);
    final userNameAsync = ref.watch(userNameProvider); // Use the new provider
    final petNameAsync = ref.watch(petNameProvider);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Combine loading states for a cleaner UI
    if (myIdAsync.isLoading || partnerIdAsync.isLoading || userNameAsync.isLoading || petNameAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Combine error states
    if (myIdAsync.hasError || partnerIdAsync.hasError || userNameAsync.hasError || petNameAsync.hasError) {
      // You can provide more specific error messages if needed
      return Scaffold(body: Center(child: Text('Error loading profile data: ${myIdAsync.error ?? partnerIdAsync.error ?? userNameAsync.error ?? petNameAsync.error}')));
    }

    // If we reach here, all data is loaded successfully
    final myId = myIdAsync.value;
    final partnerId = partnerIdAsync.value;
    final username = userNameAsync.value;
    final petName = petNameAsync.value;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Apply padding once here
        child: Column(
          children: [
            const SizedBox(height: 80),
            // --- App Title ---
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: textTheme.displaySmall?.copyWith(height: 1.2),
                children: [
                  const TextSpan(
                    text: 'Together\n',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                  ),
                  TextSpan(
                    text: 'Profile ♡',
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // --- Your Name Section ---
            _buildEditableField(
              context: context,
              ref: ref,
              title: 'Your Name',
              value: username ?? 'Set Your Name',
              onTap: () {
                showUserNameBox(context, ref);
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 30),

            // --- ID Cards ---
            // Pass necessary data, but avoid passing ref if possible
            IdCard(myid: myId, isPartner: false, ref: ref),
            const SizedBox(height: 30),
            IdCard(myid: partnerId, isPartner: true, ref: ref),
            const SizedBox(height: 30),

            // --- Pet Name Section ---
            _buildEditableField(
              context: context,
              ref: ref,
              title: 'Partner\'s Pet Name',
              value: petName ?? 'Set Pet Name',
              onTap: () => showPetNameBox(context, ref),
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 30),

            // --- Logout Button ---
            CustomBtn(
              onPressed: () async {
                // Call the clean logout function (assuming it's in AuthService)
                // This function should NOT need context or ref anymore
                await AuthService().logout(ref, context);
              },
              text: 'Logout',
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Helper widget to reduce repetition for editable fields
  Widget _buildEditableField({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String value,
    required VoidCallback onTap,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Added Expanded to prevent text overflow
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary),
                    overflow: TextOverflow.ellipsis, // Handle long names gracefully
                  ),
                ),
                Icon(Icons.edit, color: colorScheme.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}