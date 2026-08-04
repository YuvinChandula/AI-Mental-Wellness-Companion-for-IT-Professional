import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class WellnessScoreCard extends StatelessWidget {
  final int score;
  final String explanation;

  const WellnessScoreCard({
    super.key,
    required this.score,
    required this.explanation,
  });

  Color _getScoreColor(BuildContext context, int score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (score >= 80) {
      return isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    } else if (score >= 60) {
      return isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    } else {
      return isDark ? AppColors.darkError : AppColors.lightError;
    }
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Moderate';
    return 'Action Needed';
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(context, score);
    final scoreLabel = _getScoreLabel(score);

    return Semantics(
      label: 'Wellness Score: $score out of 100, $scoreLabel. $explanation',
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showScoreDetails(context),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  scoreColor.withOpacity(0.08),
                  context.colorScheme.surface,
                ],
              ),
            ),
            child: Row(
              children: <Widget>[
                // Animated Circle Score Indicator
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 84,
                      width: 84,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: score / 100),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutBack,
                        builder: (BuildContext context, double value, Widget? child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 10,
                            backgroundColor: scoreColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            strokeCap: StrokeCap.round,
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$score',
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scoreColor,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          '/100',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Score Details & explanation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: scoreColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              scoreLabel,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Today's Score",
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScoreDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final scoreColor = _getScoreColor(context, score);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: <Widget>[
              Icon(Icons.spa, color: scoreColor, size: 28),
              const SizedBox(width: 10),
              const Text('Wellness Score Details'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your score of $score is calculated based on today\'s tracking activities:',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildDetailItem(context, Icons.directions_walk, 'Steps Walked', '64% of goal reached (+10 pts)'),
              _buildDetailItem(context, Icons.local_drink, 'Water Hydration', '48% of goal reached (+8 pts)'),
              _buildDetailItem(context, Icons.nights_stay, 'Sleep Quality', '85% of sleep goal (+35 pts)'),
              _buildDetailItem(context, Icons.mood, 'Mood Journal', 'Positive/Neutral entries (+29 pts)'),
              const Divider(height: 24),
              Text(
                'Tip: Complete your remaining steps and water intake to boost your score to excellent!',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.secondary,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: context.colorScheme.primary.withOpacity(0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(value, style: TextStyle(fontSize: 12, color: context.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
