import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/analytics_providers.dart';
import '../widgets/burnout_chart.dart';
import '../widgets/mood_chart.dart';
import '../widgets/sleep_quality_chart.dart';
import '../widgets/hydration_chart.dart';
import '../widgets/exercise_chart.dart';
import '../widgets/stress_trend_chart.dart';
import '../widgets/time_filter_selector.dart';
import '../widgets/wellness_score_analytics_card.dart';
import '../widgets/goals_dashboard_widget.dart';
import '../widgets/report_history_panel.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics & Reports'),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            tabs: const <Widget>[
              Tab(icon: Icon(Icons.analytics_outlined), text: 'Dashboard'),
              Tab(icon: Icon(Icons.description_outlined), text: 'Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _buildDashboardTab(context, ref),
            _buildReportsTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(analyticsSummaryStateProvider);
    final trendsState = ref.watch(trendDataStateProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsSummaryStateProvider);
        ref.invalidate(trendDataStateProvider);
      },
      child: CustomScrollView(
        slivers: <Widget>[
          // Time filter fixed at top of list
          const SliverToBoxAdapter(child: TimeFilterSelector()),
          
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: summaryState.when(
                data: (summary) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      WellnessScoreAnalyticsCard(
                        score: summary.overallWellnessScore,
                        change: 4.5, // Mock change percentage
                        burnoutRisk: summary.burnoutRisk,
                        successRate: summary.successRate,
                      ),
                      const SizedBox(height: 16),
                      
                      // Goals & badges checklist card
                      GoalsDashboardWidget(
                        goalCompletionRate: summary.goalCompletionRate,
                        successRate: summary.successRate,
                      ),
                      const SizedBox(height: 20),
                      
                      // Title for charts
                      Text(
                        'Wellbeing Analytics Trends',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
                loading: () => _buildSummaryShimmer(context),
                error: (err, stack) => _buildErrorCard(context, 'Summary Load Error: $err'),
              ),
            ),
          ),

          // Render trend charts
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: trendsState.when(
                data: (trends) {
                  return Column(
                    children: <Widget>[
                      _buildChartCard(
                        context,
                        'Burnout Risk Timeline',
                        'Monitors developmental stress aggregates.',
                        BurnoutChart(trends: trends),
                      ),
                      _buildChartCard(
                        context,
                        'Emotional Mood Distribution',
                        'Visualizes daily mood score trends and mood frequency ratios.',
                        MoodChart(trends: trends),
                      ),
                      _buildChartCard(
                        context,
                        'Sleep Hygiene Consistency',
                        'Optimal sleep duration window highlighted (7-9 hours).',
                        SleepQualityChart(trends: trends),
                      ),
                      _buildChartCard(
                        context,
                        'Hydration Goal Completion',
                        'Daily target water glasses (8 glasses) baseline indicated.',
                        HydrationChart(trends: trends),
                      ),
                      _buildChartCard(
                        context,
                        'Active Workday Exercise',
                        'Workout active minutes tracked vs target (30 mins).',
                        ExerciseChart(trends: trends),
                      ),
                      _buildChartCard(
                        context,
                        'Stress Indices',
                        'Analyzes daily peak and average coding anxiety indexes.',
                        StressTrendChart(trends: trends),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
                loading: () => _buildChartsShimmer(context),
                error: (err, stack) => _buildErrorCard(context, 'Chart Trends Load Error: $err'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(pastReportsProvider);
      },
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.0),
        child: ReportHistoryPanel(),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, String subtitle, Widget chart) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            const Divider(height: 20, thickness: 0.5),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryShimmer(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.onSurface.withOpacity(0.08),
      highlightColor: theme.colorScheme.onSurface.withOpacity(0.03),
      child: Column(
        children: <Widget>[
          Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsShimmer(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.onSurface.withOpacity(0.08),
      highlightColor: theme.colorScheme.onSurface.withOpacity(0.03),
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            height: 260,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        )),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
