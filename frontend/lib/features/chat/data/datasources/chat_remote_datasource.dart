import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/errors/exceptions.dart';
import '../../prompt_engineering/prompt_templates.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatSessionModel> createSession(String userId, String title);
  Future<List<ChatSessionModel>> getSessions(String userId);
  Future<List<ChatMessageModel>> getMessages(String sessionId, {String? userId});
  Future<void> saveMessage(ChatMessageModel message, {String? userId});
  Future<void> deleteSession(String sessionId);
  Future<void> renameSession(String sessionId, String newTitle);
  Future<String> getGroqResponse(String prompt, List<ChatMessageModel> history, {String? userContext});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Dio _dio;

  ChatRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    Dio? dio,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _dio = dio ?? Dio();

  CollectionReference<Map<String, dynamic>> get _sessionsCollection =>
      _firestore.collection('chat_sessions');

  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      _firestore.collection('chat_messages');

  @override
  Future<ChatSessionModel> createSession(String userId, String title) async {
    try {
      final docId = _sessionsCollection.doc().id;
      final session = ChatSessionModel(
        sessionId: docId,
        userId: userId,
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _sessionsCollection.doc(docId).set(session.toFirestore());
      return session;
    } catch (e) {
      throw ServerException(message: 'Failed to create chat session: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatSessionModel>> getSessions(String userId) async {
    try {
      final snapshot = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs.map((doc) => ChatSessionModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch chat sessions: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String sessionId, {String? userId}) async {
    try {
      Query<Map<String, dynamic>> query = _messagesCollection.where('sessionId', isEqualTo: sessionId);
      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }
      final snapshot = await query.get();

      final list = snapshot.docs.map((doc) => ChatMessageModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch chat messages: ${e.toString()}');
    }
  }

  @override
  Future<void> saveMessage(ChatMessageModel message, {String? userId}) async {
    try {
      await _messagesCollection.doc(message.messageId).set(message.toFirestore(userId));
      
      // Update session's updatedAt time
      try {
        await _sessionsCollection.doc(message.sessionId).update(<String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    } catch (e) {
      // Non-blocking catch so Firestore permission or network glitches do not fail AI chat
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Cascade delete: delete the session doc and all messages under that session ID
      await _sessionsCollection.doc(sessionId).delete();
      
      final messagesSnapshot = await _messagesCollection
          .where('sessionId', isEqualTo: sessionId)
          .get();
          
      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to delete chat session: ${e.toString()}');
    }
  }

  @override
  Future<void> renameSession(String sessionId, String newTitle) async {
    try {
      await _sessionsCollection.doc(sessionId).update(<String, dynamic>{
        'title': newTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to rename chat session: ${e.toString()}');
    }
  }

  @override
  Future<String> getGroqResponse(String prompt, List<ChatMessageModel> history, {String? userContext}) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '';

    // Safety crisis triggers detection
    final lower = prompt.toLowerCase();
    if (lower.contains('suicide') ||
        lower.contains('kill myself') ||
        lower.contains('harm myself') ||
        lower.contains('end my life') ||
        lower.contains('want to die')) {
      return "I hear how much pain you're in, and I want to support you, but as an AI wellness companion, I cannot provide crisis care. Please reach out to someone who can help. You can call or text the Suicide & Crisis Lifeline at 988 (in the US) or contact your local emergency services or a trusted crisis hotline. You are not alone.";
    }

    if (apiKey.isEmpty || apiKey == 'mock_groq_key_for_testing' || apiKey.startsWith('mock')) {
      // Mock AI replies tailored to IT stressors
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (lower.contains('mood')) {
        return "Looking at your mood trend, you've maintained a **Stable** mood today, but it is slightly lower than your weekly peak. Stressors might include sedentary desk hours. Try a 5-minute screen break.";
      } else if (lower.contains('sleep')) {
        return "Your sleep average is around **6.8 hours**, which is below the recommended 7-9 hours for IT workers. Getting an extra 30 minutes of rest can boost focus and reduce compilation stress tomorrow!";
      } else if (lower.contains('stress') || lower.contains('anxious')) {
        return "When debugging or facing tight sprint deadlines, stress can spike. I suggest a quick mindfulness reset:\n\n1. Close your IDE.\n2. Inhale for 4 seconds, hold for 4, and exhale for 4.\n3. Drink a cup of water.";
      } else if (lower.contains('doctor') || lower.contains('ill') || lower.contains('diagnose')) {
        return "I am here to support your general mental wellness and IT stress management, but I cannot diagnose illnesses or give clinical medical advice. Please consult a qualified doctor or healthcare professional for diagnosis.";
      }
      return "Hello! I am your IT wellness companion. I can help analyze your mood metrics, outline developer burnout risk indices, or suggest deep breathing break guidelines. What is on your mind today?";
    }

    try {
      // Format messages into OpenAI-compatible format for Groq API
      final messages = <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': PromptTemplates.systemInstruction,
        }
      ];

      final startIdx = history.length > 10 ? history.length - 10 : 0;
      for (int i = startIdx; i < history.length; i++) {
        final msg = history[i];
        messages.add(<String, String>{
          'role': msg.sender == 'user' ? 'user' : 'assistant',
          'content': msg.message,
        });
      }

      // Format current prompt with context info
      final fullPrompt = PromptTemplates.buildUserPrompt(prompt, userContext ?? 'No metrics logged yet today.');
      messages.add(<String, String>{
        'role': 'user',
        'content': fullPrompt,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.groq.com/openai/v1/chat/completions',
        data: <String, dynamic>{
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final choices = response.data!['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices.first as Map<String, dynamic>?;
          final message = firstChoice?['message'] as Map<String, dynamic>?;
          if (message != null) {
            final content = message['content'] as String?;
            if (content != null && content.isNotEmpty) {
              return content.trim();
            }
          }
        }
        return 'I could not parse a valid content response from the Groq API.';
      } else {
        throw ServerException(message: 'Groq server returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException(message: 'Groq API request timed out. Please try again.');
      }
      if (e.response != null) {
        final errorMsg = e.response?.data?['error']?['message']?.toString() ?? 'Groq service error';
        throw ServerException(message: errorMsg);
      }
      throw NetworkException(message: e.message ?? 'Failed to connect to AI server.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
