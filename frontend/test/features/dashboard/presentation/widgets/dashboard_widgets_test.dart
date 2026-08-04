import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/dashboard/presentation/widgets/motivational_quote_card.dart';
import 'package:mindsync_ai/features/dashboard/presentation/widgets/wellness_score_card.dart';

void main() {
  group('Dashboard Presentation Widgets Tests', () {
    testWidgets('WellnessScoreCard displays score, label, explanation, and triggers popup details',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WellnessScoreCard(
              score: 85,
              explanation: 'You achieved your sleep goal today!',
            ),
          ),
        ),
      );

      // Verify that score labels and explanation exist
      expect(find.text('85'), findsOneWidget);
      expect(find.text('You achieved your sleep goal today!'), findsOneWidget);
      expect(find.text("Today's Score"), findsOneWidget);
      expect(find.text('Excellent'), findsOneWidget);

      // Tap card to launch details popup dialog
      await tester.tap(find.byType(WellnessScoreCard));
      await tester.pumpAndSettle();

      // Verify that the details modal displays
      expect(find.text('Wellness Score Details'), findsOneWidget);
      expect(find.text('Steps Walked'), findsOneWidget);
      expect(find.text('Water Hydration'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap close button and check dismiss behavior
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Wellness Score Details'), findsNothing);
    });

    testWidgets('MotivationalQuoteCard renders quotation text and author names',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MotivationalQuoteCard(
              quote: 'Code compiles, mind relaxes.',
              author: 'A Happy IT Worker',
            ),
          ),
        ),
      );

      expect(find.text('"Code compiles, mind relaxes."'), findsOneWidget);
      expect(find.text('— A Happy IT Worker'), findsOneWidget);
    });
  });
}
