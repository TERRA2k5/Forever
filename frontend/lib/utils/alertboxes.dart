import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/id_provider.dart';
import '../providers/partner_location_provider.dart';
import '../providers/pet_name_provider.dart';
import 'CostomButton.dart';

Future<void> showPartnerIDbox(BuildContext context, WidgetRef ref) async {
  final partnerIdController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Connect with Partner'),
        content: TextField(
          controller: partnerIdController,
          autofocus: true, // Automatically focuses the text field
          decoration: const InputDecoration(
            labelText: "Partner's ID",
            hintText: "Enter the ID you received",
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),

          CustomBtn(
            text: 'Save ♡ Connect',
            onPressed: () async {
              final partnerId = partnerIdController.text.trim();

              if (partnerId.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('partner_id', partnerId);

                // 3. IMPORTANT: Invalidate the provider to force a refresh
                ref.invalidate(partnerIdProvider);
                ref.invalidate(partnerLocationProvider);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                // Show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Partner ID saved successfully!"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}


Future<void> showPetNameBox(BuildContext context, WidgetRef ref) async {
  final nameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Name Your Partner'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Name your partner",
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),

          CustomBtn(
            text: 'Save ♡',
            onPressed: () async {
              final partnerName = nameController.text.trim();

              if (partnerName.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('partner_name', partnerName);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Partner name updated successfully!"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
                ref.invalidate(petNameProvider);
              }
            },
          ),
        ],
      );
    },
  );
}


Future<void> showUserNameBox(BuildContext context, WidgetRef ref) async {
  final nameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Your Name'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter your name/petname",
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),

          CustomBtn(
            text: 'Save ♡',
            onPressed: () async {
              final name = nameController.text.trim();

              if (name.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('userName', name);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Name updated successfully!"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
                ref.invalidate(userNameProvider);
              }
            },
          ),
        ],
      );
    },
  );
}


