import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Quick Actions',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Grid responsive alignment
        GridView.count(
          crossAxisCount: context.isTablet ? 5 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: <Widget>[
            _buildActionItem(
              context: context,
              icon: Icons.mood,
              label: 'Log Mood',
              color: Colors.pink,
              onTap: () => context.go(AppRouter.moodJournal),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.chat_bubble,
              label: 'AI Chat',
              color: Colors.blue,
              onTap: () => context.go(AppRouter.aiChat),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.analytics,
              label: 'Reports',
              color: Colors.purple,
              onTap: () => context.go(AppRouter.reports),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.auto_awesome,
              label: 'Tips',
              color: Colors.teal,
              onTap: () => _showTipsSlider(context),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.settings,
              label: 'Settings',
              color: Colors.grey,
              onTap: () => context.push(AppRouter.settings),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: 'Quick action: $label',
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colorScheme.onSurface.withOpacity(0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: context.colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipsSlider(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, color: Colors.teal),
              const SizedBox(width: 8),
              Text('MindSync Wellness Tips'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: PageView(
              children: <Widget>[
                _buildTipSlide(
                  context,
                  'Screen Reliever',
                  'Follow the 20-20-20 rule: Every 20 minutes, look at something 20 feet away for at least 20 seconds to reduce IT fatigue.',
                ),
                _buildTipSlide(
                  context,
                  'Desk Stretches',
                  'Perform wrist rotations and neck rolls every 2 hours to avoid repetitive strain injury (RSI) common in programmers.',
                ),
                _buildTipSlide(
                  context,
                  'Cognitive Load Rest',
                  'Before starting a complex debugging task, take 3 deep belly breaths to clear your short-term stress response.',
                ),
              ],
            ),
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

  Widget _buildTipSlide(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: context.textTheme.bodyMedium?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Swipe to read more tips →',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
