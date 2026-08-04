import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/mood_log.dart';
import '../providers/mood_providers.dart';
import 'mood_selector_grid.dart'; // To fetch mood color mappings

class MoodLogListItem extends ConsumerWidget {
  final MoodLog log;

  const MoodLogListItem({
    super.key,
    required this.log,
  });

  Color _getMoodColor(String moodName) {
    final match = supportedMoods.firstWhere(
      (MoodItem m) => m.label.toLowerCase() == moodName.toLowerCase(),
      orElse: () => const MoodItem(emoji: '😐', label: 'Neutral', score: 3, color: Colors.blue),
    );
    return match.color;
  }

  String _getMoodEmoji(String moodName) {
    final match = supportedMoods.firstWhere(
      (MoodItem m) => m.label.toLowerCase() == moodName.toLowerCase(),
      orElse: () => const MoodItem(emoji: '😐', label: 'Neutral', score: 3, color: Colors.blue),
    );
    return match.emoji;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodColor = _getMoodColor(log.mood);
    final moodEmoji = _getMoodEmoji(log.mood);
    final formattedDate = DateFormat('EEEE, MMM d, y • h:mm a').format(log.createdAt);

    return Semantics(
      label: 'Mood log entry. Registered on $formattedDate. Mood: ${log.mood}. Notes: ${log.notes}',
      child: Card(
        child: InkWell(
          onTap: () => _showEntryDetails(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header (Emoji, Mood Label, Date, Edit/Delete Shortcuts)
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: moodColor.withOpacity(0.12),
                      child: Text(
                        moodEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            log.mood,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: moodColor,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: context.textTheme.labelSmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Quick Action Icons
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => context.push(AppRouter.logMood, extra: log),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stress & Energy Indicators
                Row(
                  children: <Widget>[
                    _buildMetricBadge(context, 'Stress: ${log.stressLevel}/10', Colors.orange),
                    const SizedBox(width: 8),
                    _buildMetricBadge(context, 'Energy: ${log.energyLevel}/10', Colors.blue),
                  ],
                ),
                // Daily Notes preview
                if (log.notes.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    log.notes,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Physical Activity Summary Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildActivityTrackerItem(context, Icons.nights_stay, '${log.sleepHours}h', Colors.indigo),
                    _buildActivityTrackerItem(context, Icons.local_drink, '${log.waterIntake}ml', Colors.blue),
                    _buildActivityTrackerItem(context, Icons.directions_run, '${log.exerciseMinutes}m', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActivityTrackerItem(BuildContext context, IconData icon, String text, Color color) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: color.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showEntryDetails(BuildContext context, WidgetRef ref) {
    final moodColor = _getMoodColor(log.mood);
    final moodEmoji = _getMoodEmoji(log.mood);
    final formattedDate = DateFormat('EEEE, MMMM d, y • h:mm a').format(log.createdAt);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: moodColor.withOpacity(0.1),
                child: Text(moodEmoji),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(log.mood, style: TextStyle(color: moodColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(formattedDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Wellness Trackers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildModalDetailRow(Icons.spa, 'Stress Level', '${log.stressLevel}/10'),
                _buildModalDetailRow(Icons.bolt, 'Energy Level', '${log.energyLevel}/10'),
                _buildModalDetailRow(Icons.nights_stay, 'Sleep Hours', '${log.sleepHours} hrs'),
                _buildModalDetailRow(Icons.local_drink, 'Water Hydration', '${log.waterIntake} ml'),
                _buildModalDetailRow(Icons.directions_run, 'Exercise Activity', '${log.exerciseMinutes} min'),
                if (log.notes.isNotEmpty) ...<Widget>[
                  const Divider(height: 24),
                  const Text('Personal Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(log.notes, style: const TextStyle(fontSize: 13, height: 1.4)),
                ]
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRouter.logMood, extra: log);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: Colors.blue.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Journal Entry?'),
          content: const Text(
            'Are you sure you want to delete this mood log? This will permanently erase it from this device and Cloud servers immediately.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                ref.read(moodHistoryProvider.notifier).deleteLog(log.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry permanently deleted.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
