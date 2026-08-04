import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/conversation_drawer.dart';
import '../widgets/suggested_prompts_list.dart';

// Import providers from dashboard to enrich AI context
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

// Local StreamProvider to monitor connectivity state
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final show = _scrollController.position.pixels <
          _scrollController.position.maxScrollExtent - 400;
      if (show != _showScrollButton) {
        setState(() {
          _showScrollButton = show;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _buildWellnessContextString() {
    final dashboard = ref.read(dashboardDataProvider).value;
    final activity = ref.read(activitySummaryProvider).value;
    final weather = ref.read(weatherStateProvider).value;

    String contextStr = 'User Daily Wellness Context:\n';
    if (dashboard != null) {
      contextStr += '- Wellness Score: ${dashboard.wellnessScore}/100\n';
      contextStr += '- Mood Status: ${dashboard.moodEmoji} (${dashboard.moodTrend})\n';
      contextStr += '- Last Entry Logged: ${dashboard.lastMoodEntry}\n';
      contextStr += '- Burnout Risk Level: ${dashboard.burnoutRiskLevel} (${dashboard.burnoutPercentage.toInt()}%)\n';
    }
    if (activity != null) {
      contextStr += '- Sleep Logged: ${activity.sleepHours} hours (Goal: ${activity.sleepHoursGoal}h)\n';
      contextStr += '- Water Hydration: ${activity.waterIntakeMl} ml (Goal: ${activity.waterIntakeGoal}ml)\n';
      contextStr += '- Exercise: ${activity.exerciseMinutes} mins (Goal: ${activity.exerciseMinutesGoal}min)\n';
      contextStr += '- Steps Walked: ${activity.steps} (Goal: ${activity.stepsGoal})\n';
    }
    if (weather != null) {
      contextStr += '- Weather at Location: ${weather.condition}, Temp: ${weather.temperature.toStringAsFixed(1)}°C\n';
    }
    return contextStr;
  }

  void _handleSend([String? queryText]) {
    final text = queryText ?? _inputController.text.trim();
    if (text.isEmpty) return;

    if (queryText == null) {
      _inputController.clear();
    }

    final contextStr = _buildWellnessContextString();
    ref.read(chatMessagesProvider.notifier).sendMessage(text, userContext: contextStr);
    _focusNode.unfocus();

    // Delay scroll to bottom slightly to allow frame rendering
    Future<void>.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _exportChatHistory(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    
    // Formatting text representation
    final buffer = StringBuffer();
    buffer.writeln('=== MindSync AI Chat Session Export ===');
    for (final msg in messages) {
      final role = msg.sender == 'user' ? 'User' : 'MindSync AI';
      buffer.writeln('\n[$role] - ${msg.createdAt}');
      buffer.writeln(msg.message);
    }

    // Mock share snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation history exported successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSessionId = ref.watch(activeSessionIdProvider);
    final sessionsState = ref.watch(chatSessionsProvider);
    final messagesState = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(chatTypingProvider);

    // Watch connectivity state
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    final bool isOffline = connectivityAsync.when(
      data: (List<ConnectivityResult> results) => results.isNotEmpty && results.first == ConnectivityResult.none,
      loading: () => false,
      error: (_, __) => false,
    );

    // Find active session title
    String appBarTitle = 'AI Wellness Guide';
    if (activeSessionId != null && sessionsState.value != null) {
      for (final s in sessionsState.value!) {
        if (s.sessionId == activeSessionId) {
          appBarTitle = s.title;
          break;
        }
      }
    }

    // Trigger scroll-to-bottom on messages updates
    ref.listen<AsyncValue<List<ChatMessage>>>(chatMessagesProvider, (prev, next) {
      if (next.value != null && next.value!.isNotEmpty) {
        Future<void>.delayed(const Duration(milliseconds: 200), _scrollToBottom);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'View Conversations',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: <Widget>[
          if (activeSessionId != null) ...<Widget>[
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Export Conversation',
              onPressed: () {
                final list = messagesState.value ?? <ChatMessage>[];
                _exportChatHistory(list);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: 'New Chat',
              onPressed: () {
                ref.read(activeSessionIdProvider.notifier).state = null;
              },
            ),
          ],
        ],
      ),
      drawer: const ConversationDrawer(),
      body: Column(
        children: <Widget>[
          // Offline Banner notification
          if (isOffline)
            Container(
              color: Colors.red.shade800,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.wifi_off, color: Colors.white, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'Offline Mode: Viewing cached chat history.',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Message viewport or welcome greetings
          Expanded(
            child: activeSessionId == null
                ? _buildWelcomeGreeting()
                : messagesState.when(
                    data: (List<ChatMessage> messages) {
                      if (messages.isEmpty) {
                        return _buildWelcomeGreeting();
                      }
                      return Stack(
                        children: <Widget>[
                          ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ChatBubble(message: messages[index]);
                            },
                          ),
                          // Scroll-to-bottom FAB overlay
                          if (_showScrollButton)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton.small(
                                heroTag: 'scroll_bottom_fab',
                                backgroundColor: context.colorScheme.surface,
                                foregroundColor: context.colorScheme.primary,
                                onPressed: _scrollToBottom,
                                child: const Icon(Icons.keyboard_double_arrow_down),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Failed to load messages: $err')),
                  ),
          ),

          // Typing Loader animation block
          if (isTyping)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: <Widget>[
                  SpinKitThreeBounce(
                    color: context.colorScheme.secondary,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MindSync AI is typing...',
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),

          // Suggested Prompts (renders only if session is new/empty)
          if (activeSessionId == null) ...<Widget>[
            SuggestedPromptsList(onTapPrompt: _handleSend),
            const SizedBox(height: 12),
          ],

          // Footer Text Entry Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    enabled: !isOffline,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: isOffline ? 'Chat disabled while offline' : 'Ask about your wellness score...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isOffline ? Colors.grey : null,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: isOffline
                        ? Colors.grey
                        : (_inputController.text.isNotEmpty
                            ? context.colorScheme.primary
                            : context.colorScheme.primary.withOpacity(0.5)),
                  ),
                  onPressed: isOffline ? null : () => _handleSend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeGreeting() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 40),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: context.colorScheme.secondary, size: 48),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'MindSync AI Wellness Assistant',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'I can analyze your sleep logs, explain mood trends, summarize activity progress, and recommend developer stress management techniques.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colorScheme.onSurface.withOpacity(0.08)),
            ),
            child: Column(
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.shield_outlined, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'AI Guide Safety Disclaimer',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'MindSync AI is here for supportive guidance only. It is not a clinical medical service and does not diagnose conditions. Please consult a health provider for professional medical care.',
                  style: context.textTheme.labelSmall?.copyWith(fontSize: 10.5, height: 1.35),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
