import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';

class MoodSummaryCard extends StatelessWidget {
  final String moodEmoji;
  final String moodTrend;
  final String lastEntry;

  const MoodSummaryCard({
    super.key,
    required this.moodEmoji,
    required this.moodTrend,
    required this.lastEntry,
  });

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
      case 'rising':
        return Icons.trending_up;
      case 'declining':
      case 'falling':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(BuildContext context, String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
      case 'rising':
        return Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF81C784)
            : const Color(0xFF43A047);
      case 'declining':
      case 'falling':
        return Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFFF7043)
            : const Color(0xFFD84315);
      default:
        return context.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendColor = _getTrendColor(context, moodTrend);
    final trendIcon = _getTrendIcon(moodTrend);

    return Semantics(
      label: 'Mood Summary. Current mood is represented by $moodEmoji. Trend is $moodTrend. Last entry logged $lastEntry.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go(AppRouter.moodJournal),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Mood Summary',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.mood,
                      color: context.colorScheme.primary.withOpacity(0.5),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    // Large Emoji representation
                    Container(
                      height: 56,
                      width: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        moodEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(trendIcon, color: trendColor, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                moodTrend,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: trendColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last entry: $lastEntry',
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    // Navigation Shortcut Arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: context.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
