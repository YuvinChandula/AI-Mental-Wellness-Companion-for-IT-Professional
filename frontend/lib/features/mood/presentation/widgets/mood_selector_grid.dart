import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class MoodItem {
  final String emoji;
  final String label;
  final int score;
  final Color color;

  const MoodItem({
    required this.emoji,
    required this.label,
    required this.score,
    required this.color,
  });
}

const List<MoodItem> supportedMoods = <MoodItem>[
  MoodItem(emoji: '😁', label: 'Very Happy', score: 5, color: Colors.green),
  MoodItem(emoji: '😊', label: 'Happy', score: 4, color: Colors.lightGreen),
  MoodItem(emoji: '😐', label: 'Neutral', score: 3, color: Colors.blue),
  MoodItem(emoji: '😔', label: 'Sad', score: 2, color: Colors.blueGrey),
  MoodItem(emoji: '😢', label: 'Very Sad', score: 1, color: Colors.deepOrange),
  MoodItem(emoji: '😡', label: 'Angry', score: 2, color: Colors.red),
  MoodItem(emoji: '😰', label: 'Anxious', score: 2, color: Colors.deepPurple),
  MoodItem(emoji: '😴', label: 'Exhausted', score: 2, color: Colors.brown),
];

class MoodSelectorGrid extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<MoodItem> onSelected;

  const MoodSelectorGrid({
    super.key,
    required this.selectedMood,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'How are you feeling today? *',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.isTablet ? 4 : 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemCount: supportedMoods.length,
          itemBuilder: (BuildContext context, int index) {
            final mood = supportedMoods[index];
            final isSelected = selectedMood == mood.label;

            return Semantics(
              button: true,
              selected: isSelected,
              label: 'Mood option: ${mood.label}',
              child: InkWell(
                onTap: () => onSelected(mood),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood.color.withOpacity(0.12)
                        : context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? mood.color
                          : context.colorScheme.onSurface.withOpacity(0.12),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: mood.color.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? mood.color
                              : context.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
