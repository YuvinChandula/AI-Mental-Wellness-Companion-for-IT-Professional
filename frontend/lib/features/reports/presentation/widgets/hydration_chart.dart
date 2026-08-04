import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/trend_data.dart';

class HydrationChart extends StatelessWidget {
  final List<TrendData> trends;

  const HydrationChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (trends.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No hydration logs available.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      );
    }

    final List<BarChartGroupData> groups = trends.asMap().entries.map((MapEntry<int, TrendData> entry) {
      final int idx = entry.key;
      final int glasses = entry.value.waterGlasses;
      return BarChartGroupData(
        x: idx,
        barRods: <BarChartRodData>[
          BarChartRodData(
            toY: glasses.toDouble(),
            color: glasses >= 8 ? theme.colorScheme.primary : Colors.blue.shade300,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 12,
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
                  if (value.toInt() % 4 != 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}g',
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
                  'Hydration: ${rod.toY.toInt()} Glasses',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          maxY: 12,
          // Custom grid line indicating target 8 glasses
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 8,
                color: theme.colorScheme.primary.withOpacity(0.6),
                strokeWidth: 2,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  labelResolver: (line) => 'Goal (8g)',
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
