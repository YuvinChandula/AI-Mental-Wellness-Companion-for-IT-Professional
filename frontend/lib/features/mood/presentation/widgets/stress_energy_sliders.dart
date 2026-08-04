import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class StressEnergySliders extends StatelessWidget {
  final double stressLevel;
  final double energyLevel;
  final ValueChanged<double> onStressChanged;
  final ValueChanged<double> onEnergyChanged;

  const StressEnergySliders({
    super.key,
    required this.stressLevel,
    required this.energyLevel,
    required this.onStressChanged,
    required this.onEnergyChanged,
  });

  Color _getStressColor(double value) {
    if (value <= 3) return Colors.green;
    if (value <= 7) return Colors.orange;
    return Colors.red;
  }

  String _getStressDesc(double value) {
    if (value <= 3) return 'Calm / Relaxed';
    if (value <= 7) return 'Manageable Stress';
    return 'Overwhelmed / Highly Stressed';
  }

  Color _getEnergyColor(double value) {
    if (value <= 3) return Colors.orange;
    if (value <= 7) return Colors.blue;
    return Colors.green;
  }

  String _getEnergyDesc(double value) {
    if (value <= 3) return 'Low Energy / Exhausted';
    if (value <= 7) return 'Moderate / Focused';
    return 'Full of Vitality / Energized';
  }

  @override
  Widget build(BuildContext context) {
    final stressColor = _getStressColor(stressLevel);
    final energyColor = _getEnergyColor(energyLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Stress Level Slider
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Stress Level',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stressLevel.toInt()}/10',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: stressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getStressDesc(stressLevel),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: stressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Stress slider. Current: ${stressLevel.toInt()} of 10.',
                  child: Slider(
                    value: stressLevel,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    activeColor: stressColor,
                    inactiveColor: stressColor.withOpacity(0.2),
                    onChanged: onStressChanged,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    Text('1 (Calm)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('10 (Panic)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Energy Level Slider
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Energy Level',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${energyLevel.toInt()}/10',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: energyColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getEnergyDesc(energyLevel),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: energyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Energy slider. Current: ${energyLevel.toInt()} of 10.',
                  child: Slider(
                    value: energyLevel,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    activeColor: energyColor,
                    inactiveColor: energyColor.withOpacity(0.2),
                    onChanged: onEnergyChanged,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    Text('1 (Fatigued)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('10 (Hyperactive)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
