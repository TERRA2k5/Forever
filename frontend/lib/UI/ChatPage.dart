import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/pet_name_provider.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../providers/id_provider.dart';

class ChatScreen extends ConsumerWidget {
  final TextEditingController _messageController = TextEditingController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsyncValue = ref.watch(messagesStreamProvider);
    final myIdAsyncValue = ref.watch(myIdProvider);
    final chatIdAsyncValue = ref.watch(chatIdProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final partnerNameAsync = ref.watch(petNameProvider);

    return Scaffold(
      appBar: AppBar(
        title:partnerNameAsync.when(
          data: (partnerName) => Text(partnerName ?? 'Chat'),
          error: (err, stack) => Text('Chat Error $err'),
          loading: () => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary)),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsyncValue.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Say something sweet!", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == myIdAsyncValue.value;
                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Couldn't load messages. Please check your connection or try again later.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // --- Redesigned Message Input Area ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.05),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.send_rounded),
                    onPressed: myIdAsyncValue.hasValue && chatIdAsyncValue.hasValue
                        ? () {
                      final text = _messageController.text;
                      if (text.trim().isNotEmpty) {
                        ref.read(chatRepositoryProvider).sendMessage(
                          text,
                          chatIdAsyncValue.value!,
                          myIdAsyncValue.value!,
                        );
                        _messageController.clear();
                      }
                    }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  final Message message;
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
        child: Text(
          message.text,
          style: textTheme.bodyLarge?.copyWith(
            color: isMe ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}