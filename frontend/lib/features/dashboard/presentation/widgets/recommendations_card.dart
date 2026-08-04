import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class RecommendationsCard extends StatelessWidget {
  final String recommendationText;
  final String category;

  const RecommendationsCard({
    super.key,
    required this.recommendationText,
    required this.category,
  });

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'mindfulness':
      case 'meditation':
        return Icons.spa_outlined;
      case 'fitness':
      case 'activity':
      case 'exercise':
        return Icons.directions_run_outlined;
      case 'nutrition':
      case 'water':
      case 'diet':
        return Icons.local_drink_outlined;
      case 'focus':
      case 'work':
        return Icons.work_outline;
      case 'sleep':
      case 'rest':
        return Icons.nights_stay_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catIcon = _getCategoryIcon(category);

    return Semantics(
      label: 'Recommended action today: Category $category. Action is: $recommendationText.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                context.colorScheme.secondary.withOpacity(0.05),
                context.colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(catIcon, color: context.colorScheme.secondary, size: 20),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'AI Recommended',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recommendationText,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => _showReadMore(context),
                    icon: const Icon(Icons.arrow_right_alt, size: 18),
                    label: const Text(
                      'Read Exercise Guide',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReadMore(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, color: context.colorScheme.secondary),
              const SizedBox(width: 10),
              const Text('AI Action Guide'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                recommendationText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'How to implement this:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStep('1', 'Stop current coding task and lock your screen.'),
              _buildStep('2', 'Inhale slowly through your nose for 4 seconds, feeling your diaphragm expand.'),
              _buildStep('3', 'Hold your breath comfortably for a count of 4 seconds.'),
              _buildStep('4', 'Exhale completely through your mouth for 4 seconds, letting go of shoulder tension.'),
              _buildStep('5', 'Repeat this cycle 4 times before resuming work.'),
              const SizedBox(height: 12),
              const Text(
                'This exercise stimulates the vagus nerve to reduce heart rate variability (HRV) spikes caused by intense focus blocks.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(String index, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 9,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text(index, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(instruction, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
