import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class RecentMoodEntries extends StatelessWidget {
  final List<Map<String, dynamic>> recentMoods;

  const RecentMoodEntries({
    super.key,
    required this.recentMoods,
  });

  @override
  Widget build(BuildContext context) {
    if (recentMoods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Recent Mood Entries',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentMoods.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, indent: 64),
            itemBuilder: (BuildContext context, int index) {
              final mood = recentMoods[index];
              final String emoji = mood['emoji'] as String? ?? '😐';
              final String label = mood['label'] as String? ?? 'Neutral';
              final String time = mood['time'] as String? ?? 'Just now';

              return Semantics(
                label: 'Mood log: $label, entry registered at $time.',
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.colorScheme.primary.withOpacity(0.08),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    time,
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.check_circle_outline,
                    color: context.colorScheme.primary.withOpacity(0.4),
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
