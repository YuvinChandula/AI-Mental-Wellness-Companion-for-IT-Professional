import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class BurnoutRiskCard extends StatelessWidget {
  final String riskLevel;
  final double riskPercentage;

  const BurnoutRiskCard({
    super.key,
    required this.riskLevel,
    required this.riskPercentage,
  });

  Color _getRiskColor(BuildContext context, String level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (level.toLowerCase()) {
      case 'high':
        return isDark ? AppColors.darkError : AppColors.lightError;
      case 'moderate':
        return isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
      case 'low':
      default:
        return isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(context, riskLevel);

    return Semantics(
      label: 'Burnout Risk Assessment. Current risk is $riskLevel at ${riskPercentage.toInt()} percent.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Burnout Risk Index',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      riskLevel.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Linear Progress indicator showing the percentage
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: riskPercentage / 100,
                            minHeight: 10,
                            backgroundColor: riskColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${riskPercentage.toInt()}% Risk Percentage (Based on activity & logs)',
                          style: context.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                      foregroundColor: riskColor,
                      elevation: 0,
                      side: BorderSide(color: riskColor.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showMLDiagnostics(context),
                    child: const Text(
                      'Details',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMLDiagnostics(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        final riskColor = _getRiskColor(context, riskLevel);
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + context.bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Burnout Predictor (ML)',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.psychology, color: riskColor, size: 28),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Our machine learning models analyze screen time, keyboard/mouse stress patterns, meeting density, and heart rate variability (HRV) logs to estimate burnout indices.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Predicted Stressor Contributions:',
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildStressorProgress(context, 'Continuous Sitting Time', 0.85, Colors.orange),
              _buildStressorProgress(context, 'Meeting Density (Calendar)', 0.60, Colors.amber),
              _buildStressorProgress(context, 'Weekly Working Hours', 0.70, Colors.orange),
              _buildStressorProgress(context, 'Sleep Recovery Index', 0.35, Colors.green),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.lightbulb_outline, color: riskColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recommendation: Standing up for 2 minutes every hour can reduce consecutive sitting stress by up to 34%.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStressorProgress(BuildContext context, String stressor, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(stressor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
