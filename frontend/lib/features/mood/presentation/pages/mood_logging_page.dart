import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/mood_log.dart';
import '../providers/mood_providers.dart';
import '../widgets/journal_draft_field.dart';
import '../widgets/mood_selector_grid.dart';
import '../widgets/stress_energy_sliders.dart';
import '../widgets/tracker_input_fields.dart';

class MoodLoggingPage extends ConsumerStatefulWidget {
  final MoodLog? entryToEdit;

  const MoodLoggingPage({
    super.key,
    this.entryToEdit,
  });

  @override
  ConsumerState<MoodLoggingPage> createState() => _MoodLoggingPageState();
}

class _MoodLoggingPageState extends ConsumerState<MoodLoggingPage> {
  String? _selectedMood;
  int _moodScore = 3;
  double _stressLevel = 5.0;
  double _energyLevel = 5.0;
  double _sleepHours = 8.0;
  int _waterIntakeMl = 1000;
  int _exerciseMinutes = 15;
  String _notes = '';

  @override
  void initState() {
    super.initState();

    if (widget.entryToEdit != null) {
      final edit = widget.entryToEdit!;
      _selectedMood = edit.mood;
      _moodScore = edit.moodScore;
      _stressLevel = edit.stressLevel.toDouble();
      _energyLevel = edit.energyLevel.toDouble();
      _sleepHours = edit.sleepHours;
      _waterIntakeMl = edit.waterIntake;
      _exerciseMinutes = edit.exerciseMinutes;
      _notes = edit.notes;
    } else {
      // If creating new, read notes from draft asynchronously
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final draftText = ref.read(draftProvider);
        if (draftText.isNotEmpty) {
          setState(() {
            _notes = draftText;
          });
        }
      });
    }
  }

  void _saveLog() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your mood to log this entry.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authState = ref.read(authStateProvider);
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication required to save entry.')),
      );
      return;
    }

    final userId = authState.user.uid;
    final logId = widget.entryToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final createdAt = widget.entryToEdit?.createdAt ?? DateTime.now();

    final log = MoodLog(
      id: logId,
      userId: userId,
      mood: _selectedMood!,
      moodScore: _moodScore,
      stressLevel: _stressLevel.toInt(),
      energyLevel: _energyLevel.toInt(),
      sleepHours: _sleepHours,
      waterIntake: _waterIntakeMl,
      exerciseMinutes: _exerciseMinutes,
      notes: _notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    if (widget.entryToEdit != null) {
      ref.read(moodHistoryProvider.notifier).updateLog(log);
    } else {
      ref.read(moodHistoryProvider.notifier).addLog(log);
      // Clear drafts on successful save
      ref.read(draftProvider.notifier).clearDraft();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.entryToEdit != null ? 'Entry updated successfully!' : 'Today\'s entry saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.entryToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Wellness Log' : 'Daily Journal Log'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveLog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Mood Select Grid
            MoodSelectorGrid(
              selectedMood: _selectedMood,
              onSelected: (MoodItem item) {
                setState(() {
                  _selectedMood = item.label;
                  _moodScore = item.score;
                });
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // 2. Stress & Energy sliders
            StressEnergySliders(
              stressLevel: _stressLevel,
              energyLevel: _energyLevel,
              onStressChanged: (double val) => setState(() => _stressLevel = val),
              onEnergyChanged: (double val) => setState(() => _energyLevel = val),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // 3. Trackers (sleep, water, exercise)
            TrackerInputFields(
              sleepHours: _sleepHours,
              waterIntakeMl: _waterIntakeMl,
              exerciseMinutes: _exerciseMinutes,
              onSleepChanged: (double val) => setState(() => _sleepHours = val),
              onWaterChanged: (int val) => setState(() => _waterIntakeMl = val),
              onExerciseChanged: (int val) => setState(() => _exerciseMinutes = val),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // 4. Notes textarea
            JournalDraftField(
              initialValue: _notes,
              onChanged: (String value) {
                _notes = value;
                if (!isEditing) {
                  ref.read(draftProvider.notifier).updateDraft(value);
                }
              },
            ),
            const SizedBox(height: 28),

            // 5. Actions row
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveLog,
                    child: const Text('Save Entry'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
