import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/mood_log.dart';
import 'mood_selector_grid.dart'; // To reuse MoodItem colors

class MoodCalendarView extends StatefulWidget {
  final List<MoodLog> logs;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const MoodCalendarView({
    super.key,
    required this.logs,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<MoodCalendarView> createState() => _MoodCalendarViewState();
}

class _MoodCalendarViewState extends State<MoodCalendarView> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  // Get total days in month
  int _daysInMonth(DateTime date) {
    final firstDayOfNextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDayOfMonth = firstDayOfNextMonth.subtract(const Duration(days: 1));
    return lastDayOfMonth.day;
  }

  // Helper: map a weekday (1 = Mon ... 7 = Sun) to grid start index (0-indexed)
  int _firstWeekdayOffset(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    // In Dart: Mon = 1, Sun = 7. Let's offset to align Mon at index 0.
    return firstDay.weekday - 1;
  }

  Color? _getDayColor(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    for (final log in widget.logs) {
      final logDate = DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day);
      if (logDate.isAtSameMomentAs(target)) {
        final match = supportedMoods.firstWhere(
          (MoodItem m) => m.label.toLowerCase() == log.mood.toLowerCase(),
          orElse: () => const MoodItem(emoji: '😐', label: 'Neutral', score: 3, color: Colors.blue),
        );
        return match.color;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(_currentMonth.month);
    final year = _currentMonth.year;

    final daysCount = _daysInMonth(_currentMonth);
    final offset = _firstWeekdayOffset(_currentMonth);
    final totalCells = daysCount + offset;

    final List<String> weekdays = const <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Calendar Month & Year Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                    });
                  },
                ),
                Text(
                  '$monthName $year',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Weekday Headings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays.map((String day) {
                return SizedBox(
                  width: 32,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Monthly Day Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: totalCells,
              itemBuilder: (BuildContext context, int index) {
                if (index < offset) {
                  return const SizedBox.shrink(); // Pre-month padding cells
                }

                final dayNum = index - offset + 1;
                final dayDate = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                final isSelected = widget.selectedDate.year == dayDate.year &&
                    widget.selectedDate.month == dayDate.month &&
                    widget.selectedDate.day == dayDate.day;

                final today = DateTime.now();
                final isToday = today.year == dayDate.year &&
                    today.month == dayDate.month &&
                    today.day == dayDate.day;

                final moodColor = _getDayColor(dayDate);

                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: 'Day $dayNum, ${moodColor != null ? "mood logged" : "no log"}.',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onDateSelected(dayDate),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: moodColor?.withOpacity(0.2) ??
                              (isSelected ? context.colorScheme.primary.withOpacity(0.08) : null),
                          border: Border.all(
                            color: isSelected
                                ? context.colorScheme.primary
                                : (isToday ? context.colorScheme.secondary : Colors.transparent),
                            width: isSelected ? 2 : (isToday ? 1.5 : 0),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: moodColor ??
                                (isSelected
                                    ? context.colorScheme.primary
                                    : context.colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
