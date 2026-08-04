import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_engine.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/burnout_risk_card.dart';
import '../widgets/mood_summary_card.dart';
import '../widgets/motivational_quote_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_mood_entries.dart';
import '../widgets/recommendations_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/welcome_header.dart';
import '../widgets/wellness_score_card.dart';
import '../widgets/weekly_wellness_charts.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    await Future.wait(<Future<void>>[
      ref.read(dashboardDataProvider.notifier).loadDashboard(forceRefresh: true),
      ref.read(activitySummaryProvider.notifier).loadActivities(),
      ref.read(weatherStateProvider.notifier).loadWeather(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncEngineProvider); // Initialize background sync engine
    final dashboardState = ref.watch(dashboardDataProvider);
    final activityState = ref.watch(activitySummaryProvider);
    final isTablet = context.isTablet;

    final connectionState = ref.watch(connectivityStatusProvider);
    final isOffline = connectionState.maybeWhen(
      data: (ConnectionStatus status) => status == ConnectionStatus.offline,
      orElse: () => false,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              // Welcome Header pinned/unpinned
              const SliverToBoxAdapter(
                child: WelcomeHeader(),
              ),
              if (isOffline)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.orange.shade800,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.cloud_off, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'You are offline. Running in local cache mode.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              // Body container
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: dashboardState.when(
                    data: (data) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Critical Alert (High Priority) Banner
                          if (data.burnoutRiskLevel.toLowerCase() == 'high') ...<Widget>[
                            Card(
                              color: Colors.red.shade900.withValues(alpha: 0.85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Row(
                                      children: <Widget>[
                                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'CRITICAL ALERT: High Burnout Risk Detected',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your screen metrics, stress levels, and low sleep indicate an elevated risk of burnout. Step away for a break or consult your AI Coach.',
                                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.red.shade900,
                                            ),
                                            onPressed: () => context.go('/chat'),
                                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                            label: const Text('Open AI Coach', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Top Row: Weather & Wellness Score
                          if (isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Expanded(child: WeatherWidget()),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: WellnessScoreCard(
                                    score: data.wellnessScore,
                                    explanation: data.wellnessExplanation,
                                  ),
                                ),
                              ],
                            )
                          else ...<Widget>[
                            const WeatherWidget(),
                            const SizedBox(height: 8),
                            WellnessScoreCard(
                              score: data.wellnessScore,
                              explanation: data.wellnessExplanation,
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Mood & Burnout Index
                          if (isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: MoodSummaryCard(
                                    moodEmoji: data.moodEmoji,
                                    moodTrend: data.moodTrend,
                                    lastEntry: data.lastMoodEntry,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: BurnoutRiskCard(
                                    riskLevel: data.burnoutRiskLevel,
                                    riskPercentage: data.burnoutPercentage,
                                  ),
                                ),
                              ],
                            )
                          else ...<Widget>[
                            MoodSummaryCard(
                              moodEmoji: data.moodEmoji,
                              moodTrend: data.moodTrend,
                              lastEntry: data.lastMoodEntry,
                            ),
                            const SizedBox(height: 8),
                            BurnoutRiskCard(
                              riskLevel: data.burnoutRiskLevel,
                              riskPercentage: data.burnoutPercentage,
                            ),
                          ],
                          const SizedBox(height: 12),

                          // AI Recommendations Card
                          RecommendationsCard(
                            recommendationText: data.recommendationText,
                            category: data.recommendationCategory,
                          ),
                          const SizedBox(height: 12),

                          // Physical Activities Summary
                          activityState.when(
                            data: (activity) => ActivitySummaryCard(activity: activity),
                            loading: () => _buildActivityShimmer(context),
                            error: (err, stack) => const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Failed to load activity summary.'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Weekly Analytics Chart
                          WeeklyWellnessCharts(
                            weeklyMoods: data.weeklyMoods,
                            weeklySleepHours: data.weeklySleepHours,
                            weeklyWaterIntake: data.weeklyWaterIntake,
                            weeklyExercise: data.weeklyExercise,
                          ),
                          const SizedBox(height: 16),

                          // Quick Actions Grid
                          const QuickActionsGrid(),
                          const SizedBox(height: 20),

                          // Recent Logs
                          RecentMoodEntries(recentMoods: data.recentMoods),
                          const SizedBox(height: 16),

                          // Motivational Quote
                          MotivationalQuoteCard(
                            quote: data.quoteText,
                            author: data.quoteAuthor,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                    loading: () => _buildFullPageShimmer(context),
                    error: (Object err, StackTrace? stack) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.error_outline, size: 60, color: Colors.orange),
                              const SizedBox(height: 16),
                              Text(
                                'Error Fetching Wellness Data',
                                style: context.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                err.toString().replaceAll('Exception:', ''),
                                style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                                onPressed: () => _onRefresh(ref),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.onSurface.withOpacity(0.08),
      highlightColor: context.colorScheme.onSurface.withOpacity(0.03),
      child: Card(
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(width: 140, height: 16, color: Colors.white),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List<Widget>.generate(
                    4,
                    (int index) => Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullPageShimmer(BuildContext context) {
    final bool isTablet = context.isTablet;
    return Shimmer.fromColors(
      baseColor: context.colorScheme.onSurface.withOpacity(0.08),
      highlightColor: context.colorScheme.onSurface.withOpacity(0.03),
      child: Column(
        children: <Widget>[
          // Weather and Score cards
          if (isTablet)
            Row(
              children: <Widget>[
                Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
              ],
            )
          else ...<Widget>[
            Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 12),
            Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
          const SizedBox(height: 12),
          // Mood & Burnout Index
          Container(height: 110, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 12),
          Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 12),
          Container(height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ],
      ),
    );
  }
}
