import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/mood_log.dart';
import '../providers/mood_providers.dart';
import '../widgets/mood_calendar_view.dart';
import '../widgets/mood_log_list_item.dart';
import '../widgets/mood_selector_grid.dart'; // To get emojis list
import '../widgets/mood_stats_charts.dart';

class MoodJournalPage extends ConsumerStatefulWidget {
  const MoodJournalPage({super.key});

  @override
  ConsumerState<MoodJournalPage> createState() => _MoodJournalPageState();
}

class _MoodJournalPageState extends ConsumerState<MoodJournalPage> {
  int _currentViewIndex = 0; // 0 = History, 1 = Calendar, 2 = Analytics
  DateTime _selectedCalendarDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(filteredMoodHistoryProvider);
    final rawHistoryState = ref.watch(moodHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Wellness Journal'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 12),
          // View Switch Selector (Segmented Button)
          Center(
            child: SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 0, label: Text('History'), icon: Icon(Icons.history_toggle_off)),
                ButtonSegment<int>(value: 1, label: Text('Calendar'), icon: Icon(Icons.calendar_month_outlined)),
                ButtonSegment<int>(value: 2, label: Text('Analytics'), icon: Icon(Icons.analytics_outlined)),
              ],
              selected: <int>{_currentViewIndex},
              onSelectionChanged: (Set<int> selection) {
                setState(() {
                  _currentViewIndex = selection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Dynamic Body Area
          Expanded(
            child: rawHistoryState.when(
              data: (List<MoodLog> rawLogs) {
                if (_currentViewIndex == 0) {
                  return _buildHistoryView(historyState);
                } else if (_currentViewIndex == 1) {
                  return _buildCalendarView(rawLogs);
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MoodStatsCharts(logs: rawLogs),
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object err, StackTrace? stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                      const SizedBox(height: 12),
                      const Text('Failed to load journal logs.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(moodHistoryProvider.notifier).loadHistory(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.logMood),
        icon: const Icon(Icons.edit_note),
        label: const Text('Log Mood'),
      ),
    );
  }

  Widget _buildHistoryView(AsyncValue<List<MoodLog>> historyState) {
    final query = ref.watch(searchQueryProvider);
    final activeFilter = ref.watch(moodFilterProvider);

    return Column(
      children: <Widget>[
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SearchBar(
            hintText: 'Search journal notes...',
            leading: const Icon(Icons.search, size: 20),
            onChanged: (String val) {
              ref.read(searchQueryProvider.notifier).state = val;
            },
          ),
        ),
        const SizedBox(height: 12),
        // Horizontally scrollable mood filter chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: supportedMoods.length + 1,
            itemBuilder: (BuildContext context, int index) {
              final isAll = index == 0;
              final label = isAll ? 'All' : supportedMoods[index - 1].label;
              final emoji = isAll ? '✨' : supportedMoods[index - 1].emoji;
              final filterValue = isAll ? null : label;

              final isSelected = activeFilter == filterValue;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text('$emoji $label'),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    ref.read(moodFilterProvider.notifier).state = selected ? filterValue : null;
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Filtered logs list
        Expanded(
          child: historyState.when(
            data: (List<MoodLog> logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.notes, size: 64, color: context.colorScheme.onSurface.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      const Text(
                        'No entries match filters.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('Try resetting search parameters or log a new mood.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: logs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: MoodLogListItem(log: logs[index]),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(List<MoodLog> rawLogs) {
    // Check if the selected date has an entry
    final targetDate = DateTime(_selectedCalendarDate.year, _selectedCalendarDate.month, _selectedCalendarDate.day);
    MoodLog? selectedDayLog;
    for (final log in rawLogs) {
      final logDate = DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day);
      if (logDate.isAtSameMomentAs(targetDate)) {
        selectedDayLog = log;
        break;
      }
    }

    final formattedDate = DateFormat('MMMM d, yyyy').format(_selectedCalendarDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MoodCalendarView(
            logs: rawLogs,
            selectedDate: _selectedCalendarDate,
            onDateSelected: (DateTime date) {
              setState(() {
                _selectedCalendarDate = date;
              });
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Selected Date: $formattedDate',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedDayLog != null)
            MoodLogListItem(log: selectedDayLog)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.edit_calendar_outlined,
                      size: 40,
                      color: context.colorScheme.secondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No journal entry logged for this day.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Log Mood for this Date'),
                        onPressed: () {
                          // Open form. We pass a mock creation skeleton containing the custom selected date!
                          // This lets the user backdate their entries. That's a highly thoughtful feature!
                          final backdatedSkeleton = MoodLog(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: '',
                            mood: '',
                            moodScore: 3,
                            stressLevel: 5,
                            energyLevel: 5,
                            sleepHours: 8.0,
                            waterIntake: 1000,
                            exerciseMinutes: 15,
                            notes: '',
                            createdAt: _selectedCalendarDate,
                            updatedAt: DateTime.now(),
                          );
                          context.push(AppRouter.logMood, extra: backdatedSkeleton);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
