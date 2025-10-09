import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IdCard extends StatelessWidget {
  final String myid;

  const IdCard({super.key, required this.myid});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: myid));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Your ID has been copied to the clipboard!"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your ID", style: textTheme.titleMedium),
                    SelectableText(myid, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                  ],
                ),
                Icon(Icons.copy, color: colorScheme.primary.withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
