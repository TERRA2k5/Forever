import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/chat_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fuctions/sql_functions.dart';
import '../providers/id_provider.dart';
import '../providers/my_location_provider.dart';
import '../providers/partner_location_provider.dart';
import '../providers/pet_name_provider.dart';
import '../services/fcm_handler.dart';
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
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              final partnerId = partnerIdController.text.trim();

              if (partnerId.isNotEmpty) {
                // final prefs = await SharedPreferences.getInstance();
                await prefs.setString('partner_id', partnerId);

                // 3. IMPORTANT: Invalidate the provider to force a refresh
                ref.invalidate(partnerIdProvider);
                ref.invalidate(partnerLocationProvider);
                ref.invalidate(petNameProvider);

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

  Future<void> _updateBackend(String partnerName) async {
    final partnerID = await ref.read(partnerIdProvider.future);
    if (partnerID != null) {
      await updateName(partnerID, partnerName);
    }
  }

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
                await _updateBackend(partnerName);
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

  Future<void> _updateBackend(String name) async {
    final myId = await ref.read(myIdProvider.future);
    if (myId != null) {
      await updateName(myId, name);
    }
  }


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
                await _updateBackend(name);
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

Future<void> showErrorBox(BuildContext context, WidgetRef ref) async {
  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Something went wrong!'),
        content: Text(
          'Check your network connection', style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              SystemNavigator.pop();
            },
          ),

          CustomBtn(
            text: 'Retry',
            onPressed: () async {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              ref.invalidate(partnerLocationProvider);
              ref.invalidate(myLocationProvider);
              ref.invalidate(chatIdProvider);
              ref.invalidate(chatRepositoryProvider);
              ref.invalidate(myIdProvider);
              ref.invalidate(partnerIdProvider);
              ref.invalidate(petNameProvider);
              ref.invalidate(userNameProvider);
              ref.invalidate(messagesStreamProvider);
            },
          ),
        ],
      );
    },
  );
}

// Future<void> showVibrateBox(BuildContext context, WidgetRef ref) async {
//   await showDialog(
//     context: context,
//     builder: (BuildContext dialogContext) {
//       // Initial value for the slider (e.g., 1.0 seconds)
//       double duration = 1.0;
//
//       // StatefulBuilder allows the UI to update when the slider is dragged
//       return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               title: const Text(
//                 'Send a Vibe!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min, // Prevents the column from taking the whole screen
//                 children: [
//                   Text(
//                     'Duration: ${duration.toStringAsFixed(1)} seconds',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   Slider(
//                     value: duration,
//                     min: 0.5,
//                     max: 3.0,
//                     divisions: 5,
//                     label: '${duration.toStringAsFixed(1)}s',
//                     onChanged: (newValue) {
//                       setState(() {
//                         duration = newValue;
//                       });
//                     },
//                   )
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('Cancel'),
//                   onPressed: () {
//                     Navigator.of(dialogContext).pop();
//                   },
//                 ),
//                 CustomBtn(
//                   text: 'Send',
//                   onPressed: () async {
//                     // 1. Close the dialog
//                     if (dialogContext.mounted) {
//                       Navigator.of(dialogContext).pop();
//                     }
//                     FcmHandler().sendVibrationNotification();
//
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Vibe sent successfully!"),
//                           behavior: SnackBarBehavior.floating,
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             );
//           }
//       );
//     },
//   );
// }