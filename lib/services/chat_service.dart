import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String userId;
  final String displayName;
  final String text;
  final DateTime sentAt;

  ChatMessage({
    required this.userId,
    required this.displayName,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        userId: map['userId'] ?? '',
        displayName: map['displayName'] ?? 'Ẩn danh',
        text: map['text'] ?? '',
        sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'displayName': displayName,
        'text': text,
        'sentAt': FieldValue.serverTimestamp(),
      };
}

class ChatService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference _messages(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('messages');

  /// Stream tin nhắn realtime, giới hạn 50 tin gần nhất
  static Stream<List<ChatMessage>> messagesStream(String roomId) {
    return _messages(roomId)
        .orderBy('sentAt', descending: false)
        .limitToLast(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessage.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Gửi tin nhắn
  static Future<void> sendMessage({
    required String roomId,
    required String userId,
    required String displayName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    await _messages(roomId).add(ChatMessage(
      userId: userId,
      displayName: displayName,
      text: text.trim(),
      sentAt: DateTime.now(),
    ).toMap());
  }
}