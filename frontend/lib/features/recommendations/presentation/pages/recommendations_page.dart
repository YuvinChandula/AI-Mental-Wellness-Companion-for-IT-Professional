import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/recommendation.dart';
import '../providers/recommendation_providers.dart';
import '../widgets/recommendation_card.dart';

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({super.key});

  @override
  ConsumerState<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends ConsumerState<RecommendationsPage> {
  int _currentFilterIndex = 0; // 0 = Today, 1 = Saved, 2 = Completed

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(recommendationsListProvider);
    final summaryState = ref.watch(dailySummaryStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Wellness Coach'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-evaluate recommendations',
            onPressed: () {
              ref.read(recommendationsListProvider.notifier).loadRecommendations();
              ref.invalidate(dailySummaryStateProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // 1. Daily Summary Panel
          summaryState.when(
            data: (Map<String, dynamic> summary) => _buildDailySummaryHeader(context, summary),
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          // 2. Filter segment switcher
          Center(
            child: SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 0, label: Text('Today'), icon: Icon(Icons.today)),
                ButtonSegment<int>(value: 1, label: Text('Saved'), icon: Icon(Icons.bookmark_outline)),
                ButtonSegment<int>(value: 2, label: Text('Completed'), icon: Icon(Icons.check_circle_outline)),
              ],
              selected: <int>{_currentFilterIndex},
              onSelectionChanged: (Set<int> selection) {
                setState(() {
                  _currentFilterIndex = selection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          // 3. Scrollable List of suggestions
          Expanded(
            child: listState.when(
              data: (List<Recommendation> recs) {
                // Filter recs based on choice
                final filtered = recs.where((Recommendation r) {
                  if (_currentFilterIndex == 0) return !r.completed;
                  if (_currentFilterIndex == 1) return r.saved;
                  return r.completed;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            _currentFilterIndex == 0
                                ? Icons.done_all
                                : (_currentFilterIndex == 1 ? Icons.bookmark_border : Icons.check_circle_outline),
                            size: 48,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentFilterIndex == 0
                                ? 'All recommendations completed! Great job!'
                                : (_currentFilterIndex == 1 ? 'No saved recommendations yet.' : 'No completed suggestions yet.'),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (BuildContext context, int index) {
                    final rec = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: RecommendationCard(
                        recommendation: rec,
                        onCompleteToggle: () {
                          ref.read(recommendationsListProvider.notifier).markCompleted(rec.recommendationId);
                        },
                        onSaveToggle: () {
                          ref.read(recommendationsListProvider.notifier).toggleSave(rec.recommendationId);
                        },
                        onFeedbackSubmit: (Map<String, dynamic> data) {
                          ref.read(recommendationsListProvider.notifier).submitFeedbackText(
                                rec.recommendationId,
                                data['feedback'] as String,
                                like: data['like'] as bool,
                                dislike: data['dislike'] as bool,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you! Your feedback will train future suggestions.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object err, StackTrace? stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.error_outline, color: Colors.orange, size: 36),
                    const SizedBox(height: 8),
                    const Text('Failed to load wellness recommendations.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(recommendationsListProvider.notifier).loadRecommendations(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryHeader(BuildContext context, Map<String, dynamic> summary) {
    final int score = summary['wellnessScore'] as int? ?? 75;
    final String focus = summary['recommendedFocus'] as String? ?? 'Rest';
    final String message = summary['motivationalMessage'] as String? ?? 'Keep stepping forward!';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorScheme.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Score Indicator Circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.primary.withOpacity(0.1),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "Today's Wellness Status",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Focus: $focus',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: context.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
