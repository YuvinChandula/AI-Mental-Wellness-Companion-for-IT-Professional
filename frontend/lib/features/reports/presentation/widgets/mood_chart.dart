import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/trend_data.dart';

class MoodChart extends StatefulWidget {
  final List<TrendData> trends;

  const MoodChart({super.key, required this.trends});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart> {
  bool _showTimeline = true;

  Color _getMoodColor(int score) {
    if (score >= 8) return const Color(0xFF43A047); // Good/Happy
    if (score >= 6) return const Color(0xFF00ACC1); // Neutral/Calm
    if (score >= 4) return const Color(0xFFFFA726); // Sad/Tired
    return const Color(0xFFD84315); // Angry/Exhausted
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.trends.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No mood data logged yet.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      );
    }

    return Column(
      children: <Widget>[
        // Switch Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              _showTimeline ? 'Timeline Bar' : 'Distribution Donut',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _showTimeline,
              onChanged: (bool val) => setState(() => _showTimeline = val),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _showTimeline ? _buildTimelineChart(theme) : _buildDistributionChart(theme),
      ],
    );
  }

  Widget _buildTimelineChart(ThemeData theme) {
    final List<BarChartGroupData> groups = widget.trends.asMap().entries.map((MapEntry<int, TrendData> entry) {
      final int idx = entry.key;
      final int score = entry.value.moodScore;
      return BarChartGroupData(
        x: idx,
        barRods: <BarChartRodData>[
          BarChartRodData(
            toY: score.toDouble(),
            color: _getMoodColor(score),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.04),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 12),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() % 2 != 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int idx = value.toInt();
                  if (idx >= 0 && idx < widget.trends.length) {
                    final String date = widget.trends[idx].date;
                    final List<String> parts = date.split('-');
                    final String label = parts.length > 2 ? '${parts[1]}/${parts[2]}' : date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (BarChartGroupData group) => theme.colorScheme.surface.withOpacity(0.9),
              getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                final int idx = group.x;
                return BarTooltipItem(
                  'Score: ${rod.toY.toInt()}/10',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          maxY: 10,
          barGroups: groups,
        ),
      ),
    );
  }

  Widget _buildDistributionChart(ThemeData theme) {
    // Count score ranges
    int happy = 0;
    int calm = 0;
    int sad = 0;
    int angry = 0;
    for (final TrendData t in widget.trends) {
      if (t.moodScore >= 8) {
        happy++;
      } else if (t.moodScore >= 6) {
        calm++;
      } else if (t.moodScore >= 4) {
        sad++;
      } else {
        angry++;
      }
    }

    final double total = widget.trends.length.toDouble();
    final List<PieChartSectionData> sections = <PieChartSectionData>[
      if (happy > 0)
        PieChartSectionData(
          value: happy.toDouble(),
          color: const Color(0xFF43A047),
          title: '${(happy / total * 100).toInt()}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (calm > 0)
        PieChartSectionData(
          value: calm.toDouble(),
          color: const Color(0xFF00ACC1),
          title: '${(calm / total * 100).toInt()}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (sad > 0)
        PieChartSectionData(
          value: sad.toDouble(),
          color: const Color(0xFFFFA726),
          title: '${(sad / total * 100).toInt()}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (angry > 0)
        PieChartSectionData(
          value: angry.toDouble(),
          color: const Color(0xFFD84315),
          title: '${(angry / total * 100).toInt()}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];

    return SizedBox(
      height: 200,
      child: Row(
        children: <Widget>[
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          // Legend Panel
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildLegendItem(const Color(0xFF43A047), 'Happy/Great ($happy)'),
                const SizedBox(height: 6),
                _buildLegendItem(const Color(0xFF00ACC1), 'Calm/Neutral ($calm)'),
                const SizedBox(height: 6),
                _buildLegendItem(const Color(0xFFFFA726), 'Sad/Fatigued ($sad)'),
                const SizedBox(height: 6),
                _buildLegendItem(const Color(0xFFD84315), 'Exhausted/Angry ($angry)'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
