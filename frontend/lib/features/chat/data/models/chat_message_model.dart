import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.messageId,
    required super.sessionId,
    required super.sender,
    required super.message,
    required super.createdAt,
  });

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      messageId: entity.messageId,
      sessionId: entity.sessionId,
      sender: entity.sender,
      message: entity.message,
      createdAt: entity.createdAt,
    );
  }

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return ChatMessageModel(
      messageId: doc.id,
      sessionId: data['sessionId'] as String? ?? '',
      sender: data['sender'] as String? ?? 'user',
      message: data['message'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      messageId: map['messageId'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      sender: map['sender'] as String? ?? 'user',
      message: map['message'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageId': messageId,
      'sessionId': sessionId,
      'sender': sender,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'sender': sender,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
