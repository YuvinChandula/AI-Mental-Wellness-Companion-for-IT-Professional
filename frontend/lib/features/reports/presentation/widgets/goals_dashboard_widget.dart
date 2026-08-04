import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class GoalsDashboardWidget extends StatelessWidget {
  final double goalCompletionRate;
  final double successRate;

  const GoalsDashboardWidget({
    super.key,
    required this.goalCompletionRate,
    required this.successRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock goals status list
    final List<Map<String, dynamic>> dailyGoals = <Map<String, dynamic>>[
      <String, dynamic>{'title': 'Sleep 7+ Hours', 'done': true, 'icon': Icons.nights_stay},
      <String, dynamic>{'title': 'Drink 8 Glasses of Water', 'done': false, 'icon': Icons.local_drink},
      <String, dynamic>{'title': 'Take 3 Walking Breaks', 'done': true, 'icon': Icons.directions_walk},
      <String, dynamic>{'title': 'Complete 1 Stress Relief Pause', 'done': true, 'icon': Icons.spa},
    ];

    // Mock unlocked badges list
    final List<Map<String, dynamic>> badges = <Map<String, dynamic>>[
      <String, dynamic>{'title': 'Hydration Hero', 'icon': Icons.local_drink, 'color': Colors.blue},
      <String, dynamic>{'title': 'Sleep Ninja', 'icon': Icons.nights_stay, 'color': Colors.purple},
      <String, dynamic>{'title': 'Active Coder', 'icon': Icons.directions_run, 'color': Colors.green},
      <String, dynamic>{'title': 'Calm Dev', 'icon': Icons.self_improvement, 'color': Colors.teal},
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Goals Header & Streak Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Daily Goals & Badges',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade500.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '5 Day Streak',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Completion Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Goal Completion Rate',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${goalCompletionRate.toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goalCompletionRate / 100.0,
                minHeight: 8,
                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),

            // Daily Checklist
            Text(
              "Today's Checklist",
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyGoals.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> goal = dailyGoals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        goal['done'] as bool ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: goal['done'] as bool ? Colors.green : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Icon(goal['icon'] as IconData, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            decoration: goal['done'] as bool ? TextDecoration.lineThrough : null,
                            color: goal['done'] as bool ? Colors.grey : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Unlocked Badges Panel
            Text(
              "Unlocked Badges",
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: badges.map((Map<String, dynamic> b) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: (b['color'] as Color).withOpacity(0.12),
                          child: Icon(b['icon'] as IconData, color: b['color'] as Color, size: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b['title'] as String,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
