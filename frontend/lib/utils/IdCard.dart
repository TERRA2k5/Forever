import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/partner_location_provider.dart';
import 'package:forever/utils/CostomButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/id_provider.dart';

class IdCard extends StatelessWidget {
  final String? myid;
  final bool isPartner;
  final WidgetRef? ref;

  const IdCard({
    super.key,
    required this.myid,
    required this.isPartner,
    this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          isPartner ? _partnerClick(context, ref!) : _selfClick(context, myid);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPartner ? 'Partner ID' : "Your ID",
                      style: textTheme.titleMedium,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: SelectableText(
                        myid ?? 'Not Available',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              !isPartner ? Icon(Icons.copy, color: colorScheme.primary.withOpacity(0.7)) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _partnerClick(BuildContext context, WidgetRef ref) async {
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

void _selfClick(BuildContext context, String? myid) {
  {
    Clipboard.setData(ClipboardData(text: myid ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Your ID has been copied to the clipboard!"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
