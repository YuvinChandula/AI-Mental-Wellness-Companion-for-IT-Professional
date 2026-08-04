import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/mood_log.dart';

class MoodStatsCharts extends StatefulWidget {
  final List<MoodLog> logs;

  const MoodStatsCharts({
    super.key,
    required this.logs,
  });

  @override
  State<MoodStatsCharts> createState() => _MoodStatsChartsState();
}

class _MoodStatsChartsState extends State<MoodStatsCharts> {
  bool _isWeekly = true;

  double _calculateAvgSleep() {
    if (widget.logs.isEmpty) return 0.0;
    final total = widget.logs.fold<double>(0.0, (sum, log) => sum + log.sleepHours);
    return total / widget.logs.length;
  }

  double _calculateAvgStress() {
    if (widget.logs.isEmpty) return 0.0;
    final total = widget.logs.fold<double>(0.0, (sum, log) => sum + log.stressLevel);
    return total / widget.logs.length;
  }

  double _calculateAvgWater() {
    if (widget.logs.isEmpty) return 0.0;
    final total = widget.logs.fold<double>(0.0, (sum, log) => sum + log.waterIntake);
    return total / widget.logs.length;
  }

  double _calculateAvgExercise() {
    if (widget.logs.isEmpty) return 0.0;
    final total = widget.logs.fold<double>(0.0, (sum, log) => sum + log.exerciseMinutes);
    return total / widget.logs.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'No logged data yet. Start journaling to unlock charts!',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final avgSleep = _calculateAvgSleep();
    final avgStress = _calculateAvgStress();
    final avgWater = _calculateAvgWater();
    final avgExercise = _calculateAvgExercise();

    // Sort logs chronologically for correct graph plotting
    final sortedLogs = List<MoodLog>.from(widget.logs)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // Filter to last 7 entries for weekly, or last 30 for monthly
    final displayLogs = _isWeekly
        ? sortedLogs.skip(sortedLogs.length > 7 ? sortedLogs.length - 7 : 0).toList()
        : sortedLogs.skip(sortedLogs.length > 30 ? sortedLogs.length - 30 : 0).toList();

    return Column(
      children: <Widget>[
        // Switch Selector (Weekly vs Monthly)
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment<bool>(value: true, label: Text('Weekly view')),
            ButtonSegment<bool>(value: false, label: Text('Monthly view')),
          ],
          selected: <bool>{_isWeekly},
          onSelectionChanged: (Set<bool> selection) {
            setState(() {
              _isWeekly = selection.first;
            });
          },
        ),
        const SizedBox(height: 16),

        // Averages Summary Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Averages (${_isWeekly ? "Last 7 Logs" : "Last 30 Logs"})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildSummaryItem('Sleep', '${avgSleep.toStringAsFixed(1)}h', Colors.indigo),
                    _buildSummaryItem('Stress', '${avgStress.toStringAsFixed(1)}/10', Colors.orange),
                    _buildSummaryItem('Water', '${avgWater.toInt()}ml', Colors.blue),
                    _buildSummaryItem('Exercise', '${avgExercise.toInt()}m', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Chart 1: Mood & Stress index comparison
        _buildChartCard(
          title: 'Mood & Stress Index',
          icon: Icons.psychology_outlined,
          chart: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 1.0,
                maxY: 10.0,
                lineBarsData: <LineChartBarData>[
                  // Mood line (Multiplied by 2 to align with 1-10 range)
                  LineChartBarData(
                    spots: List<FlSpot>.generate(
                      displayLogs.length,
                      (int i) => FlSpot(i.toDouble(), displayLogs[i].moodScore.toDouble() * 2),
                    ),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Stress line
                  LineChartBarData(
                    spots: List<FlSpot>.generate(
                      displayLogs.length,
                      (int i) => FlSpot(i.toDouble(), displayLogs[i].stressLevel.toDouble()),
                    ),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          legend: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildLegendDot('Mood (Scaled)', Colors.green),
              const SizedBox(width: 24),
              _buildLegendDot('Stress Level', Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chart 2: Sleep tracking
        _buildChartCard(
          title: 'Sleep Trends',
          icon: Icons.nights_stay_outlined,
          chart: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List<BarChartGroupData>.generate(
                  displayLogs.length,
                  (int i) => BarChartGroupData(
                    x: i,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: displayLogs[i].sleepHours,
                        color: Colors.indigo,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          legend: const Text('Nightly Sleep Duration (Hours)', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Widget chart,
    required Widget legend,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            chart,
            const SizedBox(height: 12),
            Center(child: legend),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(String text, Color color) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
