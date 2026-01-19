import 'package:flutter/material.dart';
import 'package:forever/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Align text and icon to end
          children: [
            Text(
              message.text,
              style: textTheme.bodyLarge?.copyWith(
                color: isMe ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
            if (isMe) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.done_all,
                size: 16,
                // If seen, show blue (or a distinct color), otherwise translucent white/grey
                color: message.isRead
                    ? Colors.lightBlueAccent
                    : colorScheme.onPrimary.withOpacity(0.6),
              ),
            ]
          ],
        ),
      ),
    );
  }
}