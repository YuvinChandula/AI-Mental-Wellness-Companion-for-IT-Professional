import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class SuggestedPromptsList extends StatelessWidget {
  final ValueChanged<String> onTapPrompt;

  const SuggestedPromptsList({
    super.key,
    required this.onTapPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> prompts = const <String>[
      'How is my mood this week?',
      'Give me stress reduction tips.',
      'Summarize my sleep habits.',
      'How can I improve my wellness score?',
      'What should I focus on today?',
      'Explain my mood trend.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, color: context.colorScheme.secondary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Suggested Topics',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: prompts.length,
            itemBuilder: (BuildContext context, int index) {
              final text = prompts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ActionChip(
                  label: Text(text),
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: () => onTapPrompt(text),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
