import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text("Real-Time Chat")),
      body: Column(
        children: [
          Expanded(
            child: messagesAsyncValue.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text("Start the conversation!"));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == myIdAsyncValue.value;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        color: isMe ? Colors.blue[100] : Colors.grey[300],
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(message.text),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Enter a message...",
                      border: InputBorder.none,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),

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
        ],
      ),
    );
  }
}