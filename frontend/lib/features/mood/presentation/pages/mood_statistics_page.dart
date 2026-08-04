import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/mood_providers.dart';
import '../widgets/mood_stats_charts.dart';

class MoodStatisticsPage extends ConsumerWidget {
  const MoodStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(moodHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Analytics'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: historyState.when(
          data: (logs) {
            return MoodStatsCharts(logs: logs);
          },
          loading: () => _buildStatsShimmer(context),
          error: (err, stack) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                    const SizedBox(height: 12),
                    Text('Failed to load chart analytics', style: context.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(err.toString(), style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.onSurface.withOpacity(0.08),
      highlightColor: context.colorScheme.onSurface.withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(height: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ],
      ),
    );
  }
}
