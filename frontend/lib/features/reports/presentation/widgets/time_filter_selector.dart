import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_providers.dart';

class TimeFilterSelector extends ConsumerWidget {
  const TimeFilterSelector({super.key});

  Future<void> _selectCustomRange(BuildContext context, WidgetRef ref) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: ref.read(customDateRangeProvider),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).state = picked;
      ref.read(filterTypeProvider.notifier).state = 'custom';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentFilter = ref.watch(filterTypeProvider);
    final DateTimeRange? currentRange = ref.watch(customDateRangeProvider);
    final theme = Theme.of(context);

    String customLabel = 'Custom';
    if (currentFilter == 'custom' && currentRange != null) {
      final String start = DateFormat('MM/dd').format(currentRange.start);
      final String end = DateFormat('MM/dd').format(currentRange.end);
      customLabel = '$start - $end';
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SegmentedButton<String>(
          segments: <ButtonSegment<String>>[
            const ButtonSegment<String>(
              value: 'today',
              label: Text('Today'),
              icon: Icon(Icons.today, size: 16),
            ),
            const ButtonSegment<String>(
              value: 'last_7_days',
              label: Text('7 Days'),
              icon: Icon(Icons.date_range, size: 16),
            ),
            const ButtonSegment<String>(
              value: 'last_30_days',
              label: Text('30 Days'),
              icon: Icon(Icons.calendar_month, size: 16),
            ),
            const ButtonSegment<String>(
              value: 'last_90_days',
              label: Text('90 Days'),
              icon: Icon(Icons.history, size: 16),
            ),
            ButtonSegment<String>(
              value: 'custom',
              label: Text(customLabel),
              icon: const Icon(Icons.tune, size: 16),
            ),
          ],
          selected: <String>{currentFilter},
          onSelectionChanged: (Set<String> newSelection) {
            final String selection = newSelection.first;
            if (selection == 'custom') {
              _selectCustomRange(context, ref);
            } else {
              ref.read(filterTypeProvider.notifier).state = selection;
              ref.read(customDateRangeProvider.notifier).state = null;
            }
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            side: WidgetStateProperty.all(BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08))),
          ),
        ),
      ),
    );
  }
}
