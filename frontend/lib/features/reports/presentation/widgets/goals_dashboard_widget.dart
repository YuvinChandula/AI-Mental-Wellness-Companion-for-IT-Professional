import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mood/domain/entities/mood_log.dart';
import '../../../mood/presentation/providers/mood_providers.dart';

class GoalsDashboardWidget extends ConsumerWidget {
  final double goalCompletionRate;
  final double successRate;

  const GoalsDashboardWidget({
    super.key,
    required this.goalCompletionRate,
    required this.successRate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final moodState = ref.watch(moodHistoryProvider);

    List<MoodLog> logs = <MoodLog>[];
    moodState.whenData((List<MoodLog> data) => logs = data);

    final DateTime now = DateTime.now();
    MoodLog? latestLog;
    for (final MoodLog l in logs) {
      if (l.createdAt.year == now.year &&
          l.createdAt.month == now.month &&
          l.createdAt.day == now.day) {
        latestLog = l;
        break;
      }
    }
    latestLog ??= logs.isNotEmpty ? logs.first : null;

    final bool hasLogs = latestLog != null;
    final bool sleepDone = hasLogs && (latestLog.sleepHours >= 7.0);
    final bool waterDone = hasLogs && (latestLog.waterIntake >= 2000);
    final bool exerciseDone = hasLogs && (latestLog.exerciseMinutes >= 30);
    final bool stressDone = hasLogs && (latestLog.stressLevel <= 5);
    final bool moodDone = hasLogs && (latestLog.moodScore >= 3);

    final List<Map<String, dynamic>> dailyGoals = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': 'Sleep 7+ Hours (${hasLogs ? latestLog.sleepHours.toStringAsFixed(1) : "0"}h)',
        'done': sleepDone,
        'icon': Icons.nights_stay
      },
      <String, dynamic>{
        'title': 'Drink 8 Glasses of Water (${hasLogs ? latestLog.waterIntake : "0"}ml)',
        'done': waterDone,
        'icon': Icons.local_drink
      },
      <String, dynamic>{
        'title': 'Active Workday Exercise (${hasLogs ? latestLog.exerciseMinutes : "0"}m)',
        'done': exerciseDone,
        'icon': Icons.directions_run
      },
      <String, dynamic>{
        'title': 'Maintain Low Stress (Level ${hasLogs ? latestLog.stressLevel : "0"}/10)',
        'done': stressDone,
        'icon': Icons.spa
      },
      <String, dynamic>{
        'title': 'Log Mood & Resilience Entry',
        'done': moodDone,
        'icon': Icons.emoji_emotions
      },
    ];

    int completedCount = 0;
    for (final Map<String, dynamic> g in dailyGoals) {
      if (g['done'] as bool) completedCount++;
    }

    final double computedRate = hasLogs
        ? (completedCount / dailyGoals.length * 100.0)
        : goalCompletionRate;

    // Calculate Streak (consecutive days logged backwards)
    int streakDays = 0;
    if (logs.isNotEmpty) {
      final Set<DateTime> logDates = logs
          .map((MoodLog l) => DateTime(l.createdAt.year, l.createdAt.month, l.createdAt.day))
          .toSet();
      DateTime checkDate = DateTime(now.year, now.month, now.day);
      while (logDates.contains(checkDate)) {
        streakDays++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    final List<Map<String, dynamic>> badges = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': 'Hydration Hero',
        'icon': Icons.local_drink,
        'color': Colors.blue,
        'unlocked': waterDone,
      },
      <String, dynamic>{
        'title': 'Sleep Ninja',
        'icon': Icons.nights_stay,
        'color': Colors.purple,
        'unlocked': sleepDone,
      },
      <String, dynamic>{
        'title': 'Active Coder',
        'icon': Icons.directions_run,
        'color': Colors.green,
        'unlocked': exerciseDone,
      },
      <String, dynamic>{
        'title': 'Calm Dev',
        'icon': Icons.self_improvement,
        'color': Colors.teal,
        'unlocked': stressDone,
      },
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
                        '$streakDays Day Streak',
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
                  '${computedRate.toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (computedRate / 100.0).clamp(0.0, 1.0),
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
                final bool isDone = goal['done'] as bool;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isDone ? Colors.green : Colors.grey,
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
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? Colors.grey : null,
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
                  final bool unlocked = b['unlocked'] as bool;
                  final Color color = b['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: unlocked ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.12),
                          child: Icon(
                            b['icon'] as IconData,
                            color: unlocked ? color : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b['title'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? null : Colors.grey,
                          ),
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
