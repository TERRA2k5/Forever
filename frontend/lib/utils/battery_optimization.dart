import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkBatteryOptimization(BuildContext context) async {
  // Check if the app currently has battery restrictions.
  // .isDenied means the app IS restricted (Optimized).
  // .isGranted means the app is Unrestricted (what we want).
  var status = await Permission.ignoreBatteryOptimizations.status;

  if (status.isDenied && context.mounted) {
    // Show a dialog explaining why we need this permission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Enable Reliable Notifications"),
        content: const Text(
            "To receive notifications instantly even when the app is closed, please allow 'Forever' to run in the background."
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              openAppSettings();
              Navigator.pop(context);
              await Permission.ignoreBatteryOptimizations.request();
            },
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
}