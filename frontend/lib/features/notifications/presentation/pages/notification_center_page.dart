import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_providers.dart';

class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Icons.local_drink;
      case 'sleep':
        return Icons.nights_stay;
      case 'exercise':
        return Icons.directions_run;
      case 'break':
        return Icons.spa;
      case 'burnout':
        return Icons.warning_amber;
      case 'goal':
        return Icons.emoji_events;
      case 'streak':
        return Icons.local_fire_department;
      case 'mood':
        return Icons.mood;
      case 'quote':
        return Icons.format_quote;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForPriority(String priority, ThemeData theme) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return theme.colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  void _showNotificationDetails(BuildContext context, WidgetRef ref, AppNotification notif) {
    ref.read(notificationsListProvider.notifier).markRead(notif.notificationId);
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Category Icon
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: _getColorForPriority(notif.priority, theme).withOpacity(0.12),
                    child: Icon(_getIconForType(notif.type), color: _getColorForPriority(notif.priority, theme)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        notif.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getColorForPriority(notif.priority, theme),
                        ),
                      ),
                      Text(
                        notif.priority.toUpperCase() + ' PRIORITY',
                        style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                notif.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                notif.message,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Received: ${DateFormat('yyyy-MM-dd HH:mm').format(notif.createdAt)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              // Action triggers
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // If burnout alert or recommendation alert, redirect to AI Coach Chat!
                  if (notif.type.toLowerCase() == 'burnout' || notif.type.toLowerCase() == 'recommendation' || notif.type.toLowerCase() == 'break')
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.go(AppRouter.aiChat); // Route shortcut to AI chat page
                        },
                        icon: const Icon(Icons.chat_bubble),
                        label: const Text('Open AI Coach'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AppNotification>> state = ref.watch(notificationsListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        centerTitle: true,
        actions: <Widget>[
          state.maybeWhen(
            data: (List<AppNotification> list) {
              if (list.any((AppNotification n) => !n.isRead)) {
                return TextButton(
                  onPressed: () => ref.read(notificationsListProvider.notifier).markAllAsRead(),
                  child: const Text('Mark all read', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/notifications-settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsListProvider.notifier).loadNotifications(forceRefresh: true),
        child: state.when(
          data: (List<AppNotification> list) {
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.notifications_none, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                final AppNotification notif = list[index];

                return Dismissible(
                  key: Key(notif.notificationId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (DismissDirection direction) {
                    ref.read(notificationsListProvider.notifier).deleteNotif(notif.notificationId);
                  },
                  child: Semantics(
                    button: true,
                    label: 'Notification: ${notif.title}. ${notif.message}',
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: notif.isRead 
                              ? theme.colorScheme.onSurface.withOpacity(0.04)
                              : theme.colorScheme.primary.withOpacity(0.15),
                        ),
                      ),
                      color: notif.isRead ? null : theme.colorScheme.primary.withOpacity(0.02),
                      elevation: 0,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForPriority(notif.priority, theme).withOpacity(0.08),
                          child: Icon(
                            _getIconForType(notif.type),
                            color: _getColorForPriority(notif.priority, theme),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: <Widget>[
                            if (!notif.isRead) ...<Widget>[
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            notif.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              DateFormat('HH:mm').format(notif.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => ref.read(notificationsListProvider.notifier).deleteNotif(notif.notificationId),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        onTap: () => _showNotificationDetails(context, ref, notif),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Failed to load alerts: $err')),
        ),
      ),
    );
  }
}
