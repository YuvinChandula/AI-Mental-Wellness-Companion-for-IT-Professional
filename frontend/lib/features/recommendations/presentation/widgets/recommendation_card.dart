import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/recommendation.dart';
import 'feedback_dialog.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onCompleteToggle;
  final VoidCallback onSaveToggle;
  final ValueChanged<Map<String, dynamic>> onFeedbackSubmit;
  final VoidCallback? onHide;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onCompleteToggle,
    required this.onSaveToggle,
    required this.onFeedbackSubmit,
    this.onHide,
  });

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('sleep')) return Icons.nights_stay;
    if (lower.contains('stress') || lower.contains('mindful')) return Icons.spa;
    if (lower.contains('water') || lower.contains('hydr')) return Icons.local_drink;
    if (lower.contains('exercise') || lower.contains('fit')) return Icons.directions_run;
    if (lower.contains('work')) return Icons.work_history;
    return Icons.wb_sunny;
  }

  Color _getPriorityColor(String priority) {
    final lower = priority.toLowerCase();
    if (lower == 'critical') return Colors.red.shade700;
    if (lower == 'high') return Colors.orange.shade700;
    if (lower == 'medium') return Colors.blue.shade700;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    final categoryIcon = _getCategoryIcon(recommendation.category);
    final confidencePct = (recommendation.confidence * 100).toInt();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: priorityColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Category, Priority Badge, Confidence
              Row(
                children: <Widget>[
                  Icon(categoryIcon, size: 18, color: context.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    recommendation.category,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: priorityColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      recommendation.priority,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$confidencePct% match',
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                recommendation.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              // Description
              Text(
                recommendation.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              // Why generated / Explainability banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.info_outline, size: 12, color: context.colorScheme.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'Why generated (${recommendation.source})',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.reason,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colorScheme.onSurface.withOpacity(0.65),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Time, Difficulty, Benefit indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '🕒 ${recommendation.estimatedTime} • ${recommendation.difficultyLevel}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  if (recommendation.expectedBenefit.isNotEmpty)
                    Flexible(
                      child: Text(
                        'Benefit: ${recommendation.expectedBenefit}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Action Buttons Bottom Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          recommendation.completed ? Icons.check_circle : Icons.check_circle_outline,
                          color: recommendation.completed ? Colors.green : null,
                        ),
                        tooltip: 'Mark Complete',
                        onPressed: onCompleteToggle,
                      ),
                      IconButton(
                        icon: Icon(
                          recommendation.saved ? Icons.bookmark : Icons.bookmark_border,
                          color: recommendation.saved ? context.colorScheme.primary : null,
                        ),
                        tooltip: 'Save',
                        onPressed: onSaveToggle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.feedback_outlined),
                        tooltip: 'Give Feedback',
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) => FeedbackDialog(onSubmit: onFeedbackSubmit),
                          );
                        },
                      ),
                    ],
                  ),
                  if (onHide != null)
                    TextButton.icon(
                      icon: const Icon(Icons.visibility_off_outlined, size: 14),
                      label: const Text('Hide', style: TextStyle(fontSize: 12)),
                      onPressed: onHide,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
