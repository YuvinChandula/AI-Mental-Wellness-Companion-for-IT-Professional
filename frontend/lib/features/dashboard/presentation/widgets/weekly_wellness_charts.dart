import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class WeeklyWellnessCharts extends StatefulWidget {
  final List<double> weeklyMoods;
  final List<double> weeklySleepHours;
  final List<double> weeklyWaterIntake;
  final List<double> weeklyExercise;

  const WeeklyWellnessCharts({
    super.key,
    required this.weeklyMoods,
    required this.weeklySleepHours,
    required this.weeklyWaterIntake,
    required this.weeklyExercise,
  });

  @override
  State<WeeklyWellnessCharts> createState() => _WeeklyWellnessChartsState();
}

class _WeeklyWellnessChartsState extends State<WeeklyWellnessCharts> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = const <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Weekly Trends',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.insert_chart_outlined,
                  color: context.colorScheme.primary.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
          // Tab bar selection for metrics
          TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: context.colorScheme.primary,
            unselectedLabelColor: context.colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: context.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: const <Widget>[
              Tab(text: 'Mood'),
              Tab(text: 'Sleep'),
              Tab(text: 'Water'),
              Tab(text: 'Activity'),
            ],
          ),
          const SizedBox(height: 16),
          // Chart viewport
          Container(
            height: 200,
            padding: const EdgeInsets.only(right: 24, left: 8, bottom: 8),
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildMoodChart(),
                _buildSleepChart(),
                _buildWaterChart(),
                _buildActivityChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    final values = widget.weeklyMoods.isNotEmpty
        ? widget.weeklyMoods
        : <double>[4.0, 3.5, 4.5, 3.0, 4.0, 3.8, 4.2];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        minY: 1.0,
        maxY: 5.0,
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: List<FlSpot>.generate(
              values.length,
              (int i) => FlSpot(i.toDouble(), values[i]),
            ),
            isCurved: true,
            color: Colors.pink,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (FlSpot spot, double xPercent, LineChartBarData bar, int index) =>
                  FlDotCirclePainter(
                color: Colors.pink,
                strokeColor: Colors.white,
                strokeWidth: 2,
                radius: 4,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.pink.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot spot) => Colors.black.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                return LineTooltipItem(
                  'Mood: ${spot.y.toStringAsFixed(1)}/5.0',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSleepChart() {
    final values = widget.weeklySleepHours.isNotEmpty
        ? widget.weeklySleepHours
        : <double>[7.0, 6.5, 8.0, 7.5, 6.0, 8.5, 7.8];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        minY: 0.0,
        maxY: 10.0,
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: List<FlSpot>.generate(
              values.length,
              (int i) => FlSpot(i.toDouble(), values[i]),
            ),
            isCurved: true,
            color: Colors.indigo,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (FlSpot spot, double xPercent, LineChartBarData bar, int index) =>
                  FlDotCirclePainter(
                color: Colors.indigo,
                strokeColor: Colors.white,
                strokeWidth: 2,
                radius: 4,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.indigo.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot spot) => Colors.black.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                return LineTooltipItem(
                  'Sleep: ${spot.y.toStringAsFixed(1)} hrs',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWaterChart() {
    final values = widget.weeklyWaterIntake.isNotEmpty
        ? widget.weeklyWaterIntake
        : <double>[2.0, 1.5, 2.5, 1.8, 2.2, 2.0, 1.9];

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        barGroups: List<BarChartGroupData>.generate(
          values.length,
          (int i) => BarChartGroupData(
            x: i,
            barRods: <BarChartRodData>[
              BarChartRodData(
                toY: values[i],
                color: Colors.blue,
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (BarChartGroupData group) => Colors.black.withOpacity(0.8),
            getTooltipItem: (BarChartGroupData group, int rodIndex, BarChartRodData rod, int groupIndex) {
              return BarTooltipItem(
                'Water: ${rod.toY.toStringAsFixed(1)} L',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    final values = widget.weeklyExercise.isNotEmpty
        ? widget.weeklyExercise
        : <double>[30, 20, 45, 15, 60, 25, 40];

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        barGroups: List<BarChartGroupData>.generate(
          values.length,
          (int i) => BarChartGroupData(
            x: i,
            barRods: <BarChartRodData>[
              BarChartRodData(
                toY: values[i],
                color: Colors.green,
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (BarChartGroupData group) => Colors.black.withOpacity(0.8),
            getTooltipItem: (BarChartGroupData group, int rodIndex, BarChartRodData rod, int groupIndex) {
              return BarTooltipItem(
                'Exercise: ${rod.toY.toInt()} min',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            final int index = value.toInt();
            if (index >= 0 && index < _days.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _days[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
    );
  }
}
