import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/trend_data.dart';

class SleepQualityChart extends StatelessWidget {
  final List<TrendData> trends;

  const SleepQualityChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (trends.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No sleep logs available.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      );
    }

    final List<FlSpot> sleepSpots = trends.asMap().entries.map((MapEntry<int, TrendData> entry) {
      final double idx = entry.key.toDouble();
      final double sleep = entry.value.sleepHours;
      return FlSpot(idx, sleep);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 12, top: 12),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (double value) => FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value % 2 != 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}h',
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
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot spot) => theme.colorScheme.surface.withOpacity(0.9),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  return LineTooltipItem(
                    'Sleep: ${spot.y.toStringAsFixed(1)} hrs',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (trends.length - 1).toDouble(),
          minY: 0,
          maxY: 12,
          // Highlight the optimal sleep band: 7h to 9h
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: 7.0,
                y2: 9.0,
                color: theme.colorScheme.secondary.withOpacity(0.06),
              ),
            ],
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: sleepSpots,
              isCurved: true,
              color: theme.colorScheme.secondary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    theme.colorScheme.secondary.withOpacity(0.15),
                    theme.colorScheme.secondary.withOpacity(0.01),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
