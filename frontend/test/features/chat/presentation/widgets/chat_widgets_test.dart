import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/chat/domain/entities/chat_message.dart';
import 'package:mindsync_ai/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:mindsync_ai/features/chat/presentation/widgets/suggested_prompts_list.dart';

void main() {
  group('AI Chat Module UI Widgets Tests', () {
    testWidgets('ChatBubble displays user message and formats bold markings',
        (WidgetTester tester) async {
      final msg = ChatMessage(
        messageId: 'm1',
        sessionId: 's1',
        sender: 'user',
        message: 'Hello, this is **important** information.',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(message: msg),
          ),
        ),
      );

      // Verify that message text exists
      expect(find.text('Hello, this is important information.'), findsOneWidget);
    });

    testWidgets('SuggestedPromptsList lists chips and detects clicks',
        (WidgetTester tester) async {
      String? selectedPrompt;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestedPromptsList(
              onTapPrompt: (String p) {
                selectedPrompt = p;
              },
            ),
          ),
        ),
      );

      // Verify that suggestions show up
      expect(find.text('How is my mood this week?'), findsOneWidget);
      expect(find.text('Explain my mood trend.'), findsOneWidget);

      // Tap suggestion chip
      await tester.tap(find.text('How is my mood this week?'));
      await tester.pump();

      expect(selectedPrompt, 'How is my mood this week?');
    });
  });
}
