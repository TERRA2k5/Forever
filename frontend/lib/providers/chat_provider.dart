import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import 'id_provider.dart';


final chatIdProvider = FutureProvider.autoDispose<String>((ref) async {
  final myId = await ref.watch(myIdProvider.future);
  final partnerId = await ref.watch(partnerIdProvider.future);

  if (myId!.compareTo(partnerId!) > 0) {
    return '$myId-$partnerId';
  } else {
    return '$partnerId-$myId';
  }
});


final chatRepositoryProvider = Provider.autoDispose<ChatRepository>((ref) {
  return ChatRepository(firestore: FirebaseFirestore.instance);
});

final messagesStreamProvider = StreamProvider.autoDispose<List<Message>>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final asyncChatId = ref.watch(chatIdProvider);


  final chatId = asyncChatId.value;
  if (chatId == null) {
    print("Chat ID is null, returning empty stream");
    return Stream.value([]);
  }

  return chatRepository.getMessagesStream(chatId);
});


class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(String text, String chatId, String senderId) async {
    if (text.trim().isEmpty) return;

    final messageData = {
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }
}