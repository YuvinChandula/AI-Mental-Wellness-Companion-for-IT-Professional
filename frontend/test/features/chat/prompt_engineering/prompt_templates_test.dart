import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/chat/prompt_engineering/prompt_templates.dart';

void main() {
  group('Prompt Engineering Templates Tests', () {
    test('System instruction holds persona and medical disclaimers', () {
      const instruction = PromptTemplates.systemInstruction;
      expect(instruction, contains('MindSync AI'));
      expect(instruction, contains('Senior IT Wellness Guide'));
      expect(instruction, contains('NOT a doctor'));
      expect(instruction, contains('988')); // Crisis hotline check
    });

    test('User prompt correctly encapsulates query and context maps', () {
      final userPrompt = PromptTemplates.buildUserPrompt('Test query', 'Sleep: 8 hours');
      expect(userPrompt, contains('Test query'));
      expect(userPrompt, contains('Sleep: 8 hours'));
    });
  });
}
