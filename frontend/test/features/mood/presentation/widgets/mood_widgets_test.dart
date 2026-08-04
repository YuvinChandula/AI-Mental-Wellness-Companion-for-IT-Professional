import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/mood/presentation/widgets/mood_selector_grid.dart';
import 'package:mindsync_ai/features/mood/presentation/widgets/stress_energy_sliders.dart';

void main() {
  group('Mood Module UI Widgets Tests', () {
    testWidgets('MoodSelectorGrid renders items and registers selections', (WidgetTester tester) async {
      String? selectedMood;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodSelectorGrid(
              selectedMood: selectedMood,
              onSelected: (MoodItem item) {
                selectedMood = item.label;
              },
            ),
          ),
        ),
      );

      // Verify that moods are rendered
      expect(find.text('Very Happy'), findsOneWidget);
      expect(find.text('Exhausted'), findsOneWidget);
      expect(find.text('Anxious'), findsOneWidget);

      // Tap 'Very Happy' and check callback triggers
      await tester.tap(find.text('Very Happy'));
      await tester.pump();

      expect(selectedMood, 'Very Happy');
    });

    testWidgets('StressEnergySliders renders metric headers, levels, and descriptions', (WidgetTester tester) async {
      double stress = 3.0;
      double energy = 8.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StressEnergySliders(
              stressLevel: stress,
              energyLevel: energy,
              onStressChanged: (double val) {
                stress = val;
              },
              onEnergyChanged: (double val) {
                energy = val;
              },
            ),
          ),
        ),
      );

      // Verify header texts and dynamic descriptors
      expect(find.text('Stress Level'), findsOneWidget);
      expect(find.text('Energy Level'), findsOneWidget);
      expect(find.text('3/10'), findsOneWidget);
      expect(find.text('8/10'), findsOneWidget);
      expect(find.text('Calm / Relaxed'), findsOneWidget); // Stress 3 description
      expect(find.text('Full of Vitality / Energized'), findsOneWidget); // Energy 8 description
    });
  });
}
