import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/analytics_providers.dart';
import '../../domain/entities/wellness_report.dart';

class ReportHistoryPanel extends ConsumerStatefulWidget {
  const ReportHistoryPanel({super.key});

  @override
  ConsumerState<ReportHistoryPanel> createState() => _ReportHistoryPanelState();
}

class _ReportHistoryPanelState extends ConsumerState<ReportHistoryPanel> {
  bool _isGenerating = false;
  String? _exportingReportId;

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    try {
      final WellnessReport? report = await ref.read(pastReportsProvider.notifier).generateNewReport();
      if (mounted) {
        if (report != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generated report successfully! ID: ${report.reportId}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate report. Re-trying with defaults.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _exportReport(WellnessReport report, String format) async {
    setState(() => _exportingReportId = '${report.reportId}_$format');
    try {
      final List<int> bytes = await ref.read(analyticsRepositoryProvider).exportReport(
        reportData: _mapReportToFields(report),
        format: format,
      );

      Directory docDir;
      try {
        docDir = await getApplicationDocumentsDirectory();
      } catch (_) {
        docDir = Directory.systemTemp;
      }

      final File file = File('${docDir.path}/wellness_report_${report.reportId}.$format');
      await file.writeAsBytes(bytes);

      // Automatically open the report file after downloading
      final OpenResult result = await OpenFile.open(file.path);
      debugPrint('Auto-opening report file (${file.path}): ${result.type} - ${result.message}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report downloaded & opened: wellness_report_${report.reportId}.$format'),
            action: SnackBarAction(
              label: 'Reopen',
              onPressed: () {
                OpenFile.open(file.path);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingReportId = null);
    }
  }

  Map<String, dynamic> _mapReportToFields(WellnessReport r) {
    return <String, dynamic>{
      'reportId': r.reportId,
      'userId': r.userId,
      'startDate': r.startDate,
      'endDate': r.endDate,
      'wellnessScore': r.wellnessScore,
      'summaryText': r.summaryText,
      'moodAnalysis': r.moodAnalysis,
      'stressAnalysis': r.stressAnalysis,
      'sleepAnalysis': r.sleepAnalysis,
      'activityAnalysis': r.activityAnalysis,
      'hydrationAnalysis': r.hydrationAnalysis,
      'burnoutAnalysis': r.burnoutAnalysis,
      'recommendationSuccess': r.recommendationSuccess,
      'aiInsights': r.aiInsights,
      'createdAt': r.createdAt,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<WellnessReport>> reportsState = ref.watch(pastReportsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Generate Section
        Card(
          elevation: 0,
          color: theme.colorScheme.primary.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Generate Wellbeing Report',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Synthesize a full dynamic wellness summary using AI recommendations and telemetry analysis.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Generate'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // History Section
        Text(
          'Past Reports',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        reportsState.when(
          data: (List<WellnessReport> reports) {
            if (reports.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No reports generated yet.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              itemBuilder: (BuildContext context, int index) {
                final WellnessReport report = reports[index];
                final String formattedDate = report.createdAt.split('T')[0];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Report Date: $formattedDate',
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Score: ${report.wellnessScore.toInt()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.summaryText,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: _exportingReportId != null
                                  ? null
                                  : () => _exportReport(report, 'csv'),
                              icon: _exportingReportId == '${report.reportId}_csv'
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.table_chart, size: 16),
                              label: const Text('CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: _exportingReportId != null
                                  ? null
                                  : () => _exportReport(report, 'pdf'),
                              icon: _exportingReportId == '${report.reportId}_pdf'
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.picture_as_pdf, size: 16),
                              label: const Text('PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            ),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Failed to load past reports: $err'),
            ),
          ),
        ),
      ],
    );
  }
}
