import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class TrackerInputFields extends StatelessWidget {
  final double sleepHours;
  final int waterIntakeMl;
  final int exerciseMinutes;
  final ValueChanged<double> onSleepChanged;
  final ValueChanged<int> onWaterChanged;
  final ValueChanged<int> onExerciseChanged;

  const TrackerInputFields({
    super.key,
    required this.sleepHours,
    required this.waterIntakeMl,
    required this.exerciseMinutes,
    required this.onSleepChanged,
    required this.onWaterChanged,
    required this.onExerciseChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHealthySleep = sleepHours >= 7.0 && sleepHours <= 9.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Wellness Trackers',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Grid or column based on screen size
        if (context.isTablet)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _buildSleepCard(context, isHealthySleep)),
              const SizedBox(width: 12),
              Expanded(child: _buildWaterCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildExerciseCard(context)),
            ],
          )
        else ...<Widget>[
          _buildSleepCard(context, isHealthySleep),
          const SizedBox(height: 12),
          _buildWaterCard(context),
          const SizedBox(height: 12),
          _buildExerciseCard(context),
        ],
      ],
    );
  }

  Widget _buildSleepCard(BuildContext context, bool isHealthySleep) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.nights_stay, color: Colors.indigo.shade400, size: 20),
                const SizedBox(width: 8),
                const Text('Sleep Hours', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isHealthySleep)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16)
                else
                  const Icon(Icons.info_outline, color: Colors.orange, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended: 7 - 9 hours',
              style: context.textTheme.labelSmall?.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: () {
                    if (sleepHours > 0.0) {
                      onSleepChanged((sleepHours - 0.5).clamp(0.0, 24.0));
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '${sleepHours.toStringAsFixed(1)} hrs',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    onSleepChanged((sleepHours + 0.5).clamp(0.0, 24.0));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard(BuildContext context) {
    const int goal = 2000;
    final percentage = (waterIntakeMl / goal).clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.local_drink, color: Colors.blue.shade400, size: 20),
                const SizedBox(width: 8),
                const Text('Water Hydration', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Daily Goal: 2000 ml',
                  style: context.textTheme.labelSmall?.copyWith(fontSize: 11),
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: () {
                    if (waterIntakeMl > 0) {
                      onWaterChanged((waterIntakeMl - 250).clamp(0, 5000));
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$waterIntakeMl ml',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    onWaterChanged((waterIntakeMl + 250).clamp(0, 5000));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.directions_run, color: Colors.green.shade400, size: 20),
                const SizedBox(width: 8),
                const Text('Exercise Minutes', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended: 30+ minutes',
              style: context.textTheme.labelSmall?.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: () {
                    if (exerciseMinutes > 0) {
                      onExerciseChanged((exerciseMinutes - 5).clamp(0, 300));
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$exerciseMinutes min',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    onExerciseChanged((exerciseMinutes + 5).clamp(0, 300));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
