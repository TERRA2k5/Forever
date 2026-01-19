import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> checkBatteryOptimization(BuildContext context) async {
  // 1. Check if we already asked (to avoid nagging loop on buggy devices)
  // final prefs = await SharedPreferences.getInstance();
  // final bool hasAsked = prefs.getBool('hasAskedBatteryOptimization') ?? false;

  // if (hasAsked) return;

  // 2. Check status using the helper
  // This helper often handles manufacturer quirks better
  bool Optimizing = await BatteryOptimizationHelper.isBatteryOptimizationEnabled();

  if (Optimizing && context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Enable Reliable Notifications"),
        content: const Text(
            "To receive notifications instantly even when the app is closed, please allow Forever to run in the background.\n Go to Forever -> Unrestricted"
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Save that we asked so we don't annoy them next time
              // prefs.setBool('hasAskedBatteryOptimization', true);
            },
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // prefs.setBool('hasAskedBatteryOptimization', true);

              // 3. This single line handles the complex Intent logic
              // It tries to open the specific optimization menu directly
              await BatteryOptimizationHelper.openBatteryOptimizationSettings();
            },
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  } else {
    print("🔋 Battery optimization is already disabled (Unrestricted).");
  }
}