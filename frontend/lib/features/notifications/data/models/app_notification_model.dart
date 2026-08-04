import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.notificationId,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    required super.priority,
    required super.scheduledTime,
    required super.sentTime,
    required super.status,
    required super.isRead,
    required super.source,
    required super.createdAt,
  });

  factory AppNotificationModel.fromEntity(AppNotification entity) {
    return AppNotificationModel(
      notificationId: entity.notificationId,
      userId: entity.userId,
      title: entity.title,
      message: entity.message,
      type: entity.type,
      priority: entity.priority,
      scheduledTime: entity.scheduledTime,
      sentTime: entity.sentTime,
      status: entity.status,
      isRead: entity.isRead,
      source: entity.source,
      createdAt: entity.createdAt,
    );
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) {
    return AppNotificationModel(
      notificationId: map['notificationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      priority: map['priority'] as String? ?? 'low',
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.parse(map['scheduledTime'] as String)
          : DateTime.now(),
      sentTime: map['sentTime'] != null
          ? DateTime.parse(map['sentTime'] as String)
          : DateTime.now(),
      status: map['status'] as String? ?? 'sent',
      isRead: map['isRead'] as bool? ?? false,
      source: map['source'] as String? ?? 'backend_engine',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory AppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return AppNotificationModel(
      notificationId: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      priority: data['priority'] as String? ?? 'low',
      scheduledTime: (data['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sentTime: (data['sentTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'sent',
      isRead: data['isRead'] as bool? ?? false,
      source: data['source'] as String? ?? 'backend_engine',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'scheduledTime': scheduledTime.toIso8601String(),
      'sentTime': sentTime.toIso8601String(),
      'status': status,
      'isRead': isRead,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'sentTime': Timestamp.fromDate(sentTime),
      'status': status,
      'isRead': isRead,
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
