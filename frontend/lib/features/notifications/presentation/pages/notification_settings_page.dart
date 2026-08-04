import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_preference.dart';
import '../providers/notification_providers.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  Future<void> _selectTime(BuildContext context, WidgetRef ref, NotificationPreference prefs, bool isWakeUp) async {
    final String initialTime = isWakeUp ? prefs.wakeUpTime : prefs.sleepTime;
    final List<String> parts = initialTime.split(':');
    final TimeOfDay initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      final String formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final NotificationPreference updated = isWakeUp 
          ? prefs.copyWith(wakeUpTime: formatted)
          : prefs.copyWith(sleepTime: formatted);
      await ref.read(notificationPreferencesProvider.notifier).updatePrefs(updated);
    }
  }

  Future<void> _selectQuietHours(BuildContext context, WidgetRef ref, NotificationPreference prefs, bool isStart) async {
    final String initialTime = isStart ? prefs.quietHoursStart : prefs.quietHoursEnd;
    final List<String> parts = initialTime.split(':');
    final TimeOfDay initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      final String formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final NotificationPreference updated = isStart 
          ? prefs.copyWith(quietHoursStart: formatted)
          : prefs.copyWith(quietHoursEnd: formatted);
      await ref.read(notificationPreferencesProvider.notifier).updatePrefs(updated);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<NotificationPreference> prefsState = ref.watch(notificationPreferencesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        centerTitle: true,
      ),
      body: prefsState.when(
        data: (NotificationPreference prefs) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: <Widget>[
              // Section 1: Main Controls
              _buildSectionHeader(theme, 'General Settings'),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Enable wellness alerts and recommendations'),
                value: prefs.pushEnabled,
                onChanged: (bool value) {
                  ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                    prefs.copyWith(pushEnabled: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Sound Alerts'),
                value: prefs.soundEnabled,
                onChanged: (bool value) {
                  ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                    prefs.copyWith(soundEnabled: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Vibration Alerts'),
                value: prefs.vibrationEnabled,
                onChanged: (bool value) {
                  ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                    prefs.copyWith(vibrationEnabled: value),
                  );
                },
              ),
              const Divider(height: 24),

              // Section 2: Sub-Alerts Config
              _buildSectionHeader(theme, 'Notification Types'),
              CheckboxListTile(
                title: const Text('Daily Reminders'),
                subtitle: const Text('Mood checking and daily goal reminders'),
                value: prefs.dailyReminders,
                onChanged: (bool? value) {
                  if (value != null) {
                    ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                      prefs.copyWith(dailyReminders: value),
                    );
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('Weekly Summaries'),
                value: prefs.weeklySummaries,
                onChanged: (bool? value) {
                  if (value != null) {
                    ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                      prefs.copyWith(weeklySummaries: value),
                    );
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('AI Suggestions'),
                value: prefs.aiSuggestions,
                onChanged: (bool? value) {
                  if (value != null) {
                    ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                      prefs.copyWith(aiSuggestions: value),
                    );
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('Motivational Messages'),
                value: prefs.motivationMessages,
                onChanged: (bool? value) {
                  if (value != null) {
                    ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                      prefs.copyWith(motivationMessages: value),
                    );
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('Goal Achievements'),
                value: prefs.goalReminders,
                onChanged: (bool? value) {
                  if (value != null) {
                    ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                      prefs.copyWith(goalReminders: value),
                    );
                  }
                },
              ),
              const Divider(height: 24),

              // Section 3: Time Schedulers
              _buildSectionHeader(theme, 'Schedules & Reminders'),
              ListTile(
                title: const Text('Wake Up Reminder'),
                trailing: Text(prefs.wakeUpTime, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                onTap: () => _selectTime(context, ref, prefs, true),
              ),
              ListTile(
                title: const Text('Sleep Reminder'),
                trailing: Text(prefs.sleepTime, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                onTap: () => _selectTime(context, ref, prefs, false),
              ),
              ListTile(
                title: const Text('Water Intake Frequency'),
                subtitle: const Text('How often you get desk hydration prompts'),
                trailing: DropdownButton<int>(
                  value: prefs.waterFrequencyHours,
                  onChanged: (int? value) {
                    if (value != null) {
                      ref.read(notificationPreferencesProvider.notifier).updatePrefs(
                        prefs.copyWith(waterFrequencyHours: value),
                      );
                    }
                  },
                  items: const <DropdownMenuItem<int>>[
                    DropdownMenuItem<int>(value: 1, child: Text('Every Hour')),
                    DropdownMenuItem<int>(value: 2, child: Text('Every 2 Hours')),
                    DropdownMenuItem<int>(value: 3, child: Text('Every 3 Hours')),
                  ],
                ),
              ),
              const Divider(height: 24),

              // Section 4: Quiet Hours
              _buildSectionHeader(theme, 'Quiet Hours'),
              ListTile(
                title: const Text('Quiet Hours Start'),
                trailing: Text(prefs.quietHoursStart, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                onTap: () => _selectQuietHours(context, ref, prefs, true),
              ),
              ListTile(
                title: const Text('Quiet Hours End'),
                trailing: Text(prefs.quietHoursEnd, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                onTap: () => _selectQuietHours(context, ref, prefs, false),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load settings: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
