import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String priority;
  final DateTime scheduledTime;
  final DateTime sentTime;
  final String status;
  final bool isRead;
  final String source;
  final DateTime createdAt;

  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.scheduledTime,
    required this.sentTime,
    required this.status,
    required this.isRead,
    required this.source,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? priority,
    DateTime? scheduledTime,
    DateTime? sentTime,
    String? status,
    bool? isRead,
    String? source,
    DateTime? createdAt,
  }) {
    return AppNotification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      sentTime: sentTime ?? this.sentTime,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        notificationId,
        userId,
        title,
        message,
        type,
        priority,
        scheduledTime,
        sentTime,
        status,
        isRead,
        source,
        createdAt,
      ];
}
