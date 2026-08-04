import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/chat_session.dart';
import '../providers/chat_providers.dart';

class ConversationDrawer extends ConsumerWidget {
  const ConversationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(chatSessionsProvider);
    final activeSessionId = ref.watch(activeSessionIdProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Sidebar Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Conversations',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_comment_outlined),
                    tooltip: 'New Chat',
                    onPressed: () {
                      ref.read(activeSessionIdProvider.notifier).state = null;
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Sessions List
            Expanded(
              child: sessionsState.when(
                data: (List<ChatSession> sessions) {
                  if (sessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.chat_bubble_outline, size: 40, color: context.colorScheme.onSurface.withOpacity(0.15)),
                          const SizedBox(height: 8),
                          const Text('No previous chats found.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    itemCount: sessions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final session = sessions[index];
                      final isSelected = activeSessionId == session.sessionId;

                      return Semantics(
                        button: true,
                        selected: isSelected,
                        label: 'Conversation session titled: ${session.title}',
                        child: Card(
                          elevation: 0,
                          color: isSelected
                              ? context.colorScheme.primary.withOpacity(0.08)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? context.colorScheme.primary : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: isSelected ? context.colorScheme.primary : null,
                            ),
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('MMM d, h:mm a').format(session.createdAt),
                              style: const TextStyle(fontSize: 10),
                            ),
                            onTap: () {
                              ref.read(activeSessionIdProvider.notifier).state = session.sessionId;
                              Navigator.pop(context); // Close drawer
                            },
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 16),
                              onSelected: (String val) {
                                if (val == 'rename') {
                                  _showRenameDialog(context, ref, session);
                                } else if (val == 'delete') {
                                  _confirmDelete(context, ref, session);
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'rename',
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.edit_outlined, size: 16),
                                      SizedBox(width: 8),
                                      Text('Rename'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.delete_outline, color: Colors.red, size: 16),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error loading chats: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, ChatSession session) {
    final controller = TextEditingController(text: session.title);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Conversation'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Conversation Title',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  ref.read(chatSessionsProvider.notifier).renameSession(session.sessionId, newTitle);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ChatSession session) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Conversation?'),
          content: const Text(
            'Are you sure you want to delete this conversation session and all its messages permanently?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                ref.read(chatSessionsProvider.notifier).deleteSession(session.sessionId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
