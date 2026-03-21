import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/UI/CallPage.dart';
import 'package:forever/models/message_model.dart';
import 'package:forever/providers/pet_name_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_state_provider.dart';
import '../providers/id_provider.dart';
import '../utils/message_bubble.dart';

// 1. Convert to ConsumerStatefulWidget to access lifecycle methods
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('chat state open is true');
      ref.read(isChatScreenOpenProvider.notifier).state = true;
      // ref.invalidate(isChatScreenOpenProvider);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isChatScreenOpenProvider);
    // The rest of your build logic remains exactly the same!
    final messagesAsync = ref.watch(messagesStreamProvider);
    final myIdAsync = ref.watch(myIdProvider);
    final chatIdAsync = ref.watch(chatIdProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final partnerNameAsync = ref.watch(petNameProvider);

    ref.listen<AsyncValue<List<MessageModel>>>(messagesStreamProvider, (previous, next) {
      next.whenData((messages) {
        print('Listening for new messages in chat screen');
        if (messages.isNotEmpty) {
          print('New messages received');

          final unseenIds = messages
              .where((msg) => msg.senderId != myIdAsync.value && !msg.isRead)
              .map((msg) => msg.id)
              .toList();

          if (unseenIds.isNotEmpty) {
            print('Marking messages as seen: $unseenIds');
            ref.read(chatRepositoryProvider).markMessagesAsSeen(chatIdAsync.value!, unseenIds);
          }
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: partnerNameAsync.when(
          data: (partnerName) => Align(
            alignment: Alignment.centerLeft,
            child: Text(partnerName ?? 'Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          ),
          error: (err, stack) => Text('Chat Error $err'),
          loading: () => CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CallScreen(channelName: chatIdAsync.value!, isVideoCall: false, isCaller: true,),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CallScreen(channelName: chatIdAsync.value!, isVideoCall: true, isCaller: true,),
              ));
            },
          )
        ],
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("Say something sweet!",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  // _saveLastActiveTimestamp(messages);
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final bool isMe =
                          message.senderId == myIdAsync.value;
                      return MessageBubble(message: message, isMe: isMe);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) {
                  print('Error loading messages: $err');
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Couldn't load messages. Please check your connection or try again later.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
          ),
          // --- Message Input Area ---
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                    onPressed: myIdAsync.hasValue &&
                        chatIdAsync.hasValue
                        ? () {
                      final text = _messageController.text;
                      if (text.trim().isNotEmpty) {
                        ref.read(chatRepositoryProvider).sendMessage(
                          text,
                          chatIdAsync.value!,
                          myIdAsync.value!,
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