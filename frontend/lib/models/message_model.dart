import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final String senderId;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Message(
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: data['timestamp'] == null
          ? DateTime.now()
          : (data['timestamp'] as Timestamp).toDate(),
    );
  }
}