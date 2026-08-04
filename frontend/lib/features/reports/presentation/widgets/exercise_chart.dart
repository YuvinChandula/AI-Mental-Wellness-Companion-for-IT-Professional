import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/trend_data.dart';

class ExerciseChart extends StatelessWidget {
  final List<TrendData> trends;

  const ExerciseChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (trends.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No exercise logs available.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      );
    }

    final List<BarChartGroupData> groups = trends.asMap().entries.map((MapEntry<int, TrendData> entry) {
      final int idx = entry.key;
      final int mins = entry.value.exerciseMinutes;
      return BarChartGroupData(
        x: idx,
        barRods: <BarChartRodData>[
          BarChartRodData(
            toY: mins.toDouble(),
            color: mins >= 30 ? Colors.green.shade400 : theme.colorScheme.secondary,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 60,
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
                reservedSize: 28,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() % 20 != 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}m',
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
                  if (idx >= 0 && idx < trends.length) {
                    final String date = trends[idx].date;
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
                return BarTooltipItem(
                  'Active: ${rod.toY.toInt()} Mins',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          maxY: 60,
          // Goal baseline line at 30 mins
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 30,
                color: Colors.green.withOpacity(0.6),
                strokeWidth: 2,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                  labelResolver: (line) => 'Goal (30m)',
                ),
              ),
            ],
          ),
          barGroups: groups,
        ),
      ),
    );
  }
}
