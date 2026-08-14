import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/pedometer_service.dart';
import '../../domain/entities/activity_summary.dart';

class ActivitySummaryCard extends StatelessWidget {
  final ActivitySummary activity;

  const ActivitySummaryCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Activity Summary. Steps: ${activity.steps} of ${activity.stepsGoal}. Water: ${activity.waterIntakeMl} milliliters of ${activity.waterIntakeGoal}. Sleep: ${activity.sleepHours} hours of ${activity.sleepHoursGoal}. Exercise: ${activity.exerciseMinutes} minutes of ${activity.exerciseMinutesGoal}.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Daily Activity Summary',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.directions_run,
                    color: context.colorScheme.primary.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Responsive grid layout (2 columns on mobile, 4 columns on tablet)
              GridView.count(
                crossAxisCount: context.isTablet ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: <Widget>[
                  _buildActivityGauge(
                    context: context,
                    icon: Icons.directions_walk,
                    title: 'Steps',
                    value: activity.steps.toDouble(),
                    goal: activity.stepsGoal.toDouble(),
                    unit: '',
                    color: Colors.orange,
                    onTap: () => _showLogDialog(context, 'Steps', 'steps', 'Walked'),
                  ),
                  _buildActivityGauge(
                    context: context,
                    icon: Icons.local_drink,
                    title: 'Water',
                    value: activity.waterIntakeMl.toDouble(),
                    goal: activity.waterIntakeGoal.toDouble(),
                    unit: 'ml',
                    color: Colors.blue,
                    onTap: () => _showLogDialog(context, 'Water Intake', 'ml', 'Hydrated'),
                  ),
                  _buildActivityGauge(
                    context: context,
                    icon: Icons.nights_stay,
                    title: 'Sleep',
                    value: activity.sleepHours,
                    goal: activity.sleepHoursGoal,
                    unit: 'hrs',
                    color: Colors.indigo,
                    onTap: () => _showLogDialog(context, 'Sleep Hours', 'hours', 'Slept'),
                  ),
                  _buildActivityGauge(
                    context: context,
                    icon: Icons.fitness_center,
                    title: 'Exercise',
                    value: activity.exerciseMinutes.toDouble(),
                    goal: activity.exerciseMinutesGoal.toDouble(),
                    unit: 'min',
                    color: Colors.green,
                    onTap: () => _showLogDialog(context, 'Exercise', 'min', 'Exercised'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGauge({
    required BuildContext context,
    required IconData icon,
    required String title,
    required double value,
    required double goal,
    required String unit,
    required Color color,
    required VoidCallback onTap,
  }) {
    final double percentage = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Semantics(
      button: true,
      label: 'Log $title. $value of $goal $unit complete.',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 52,
                    width: 52,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 5,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${value.toInt()}/${goal.toInt()} $unit',
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogDialog(BuildContext context, String activityName, String unit, String pastTenseVerb) {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Log Today\'s $activityName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Enter the amount of $unit you $pastTenseVerb:'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: activityName,
                  suffixText: unit,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                Navigator.pop(context);
                if (text.isNotEmpty) {
                  final parsed = int.tryParse(text);
                  if (activityName == 'Steps' && parsed != null) {
                    PedometerService.instance.updateStepsManually(parsed);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged $text $unit. Wellness score updated!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
