import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String messageId;
  final String sessionId;
  final String sender; // 'user' or 'model'
  final String message;
  final DateTime createdAt;

  const ChatMessage({
    required this.messageId,
    required this.sessionId,
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => <Object?>[
        messageId,
        sessionId,
        sender,
        message,
        createdAt,
      ];
}
