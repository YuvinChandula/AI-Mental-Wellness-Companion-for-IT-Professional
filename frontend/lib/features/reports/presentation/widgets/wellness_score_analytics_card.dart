import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WellnessScoreAnalyticsCard extends StatelessWidget {
  final double score;
  final double change;
  final String burnoutRisk;
  final double successRate;

  const WellnessScoreAnalyticsCard({
    super.key,
    required this.score,
    required this.change,
    required this.burnoutRisk,
    required this.successRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImprovement = change >= 0;
    
    Color riskColor = Colors.green;
    if (burnoutRisk.toLowerCase() == 'high') {
      riskColor = Colors.redAccent;
    } else if (burnoutRisk.toLowerCase() == 'medium') {
      riskColor = Colors.orangeAccent;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.primary.withOpacity(0.04),
              theme.colorScheme.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: <Widget>[
            // Big Score Circle
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 85,
                  height: 85,
                  child: CircularProgressIndicator(
                    value: score / 100.0,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${score.toInt()}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Wellness',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
            
            // Stats Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Overall Wellbeing Score',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  
                  // Improvement variance badge
                  Row(
                    children: <Widget>[
                      Icon(
                        isImprovement ? Icons.trending_up : Icons.trending_down,
                        color: isImprovement ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change.abs()}% ${isImprovement ? "increase" : "decline"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isImprovement ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        ' vs. prev. range',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const Divider(height: 16, thickness: 0.5),
                  
                  // Secondary specs: Burnout & Success rate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'BURNOUT RISK',
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            burnoutRisk,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'AI REC SUCCESS',
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${successRate.toInt()}%',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
