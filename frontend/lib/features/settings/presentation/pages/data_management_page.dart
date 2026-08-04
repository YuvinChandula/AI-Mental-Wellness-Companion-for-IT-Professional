import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../providers/settings_providers.dart';
import '../../domain/entities/application_settings.dart';

class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  bool _isExporting = false;
  String? _exportFormat;

  Future<void> _exportData(String format) async {
    setState(() {
      _isExporting = true;
      _exportFormat = format;
    });

    try {
      final List<int> bytes = await ref.read(settingsRepositoryProvider).exportPersonalData(format);
      
      final Directory tempDir = Directory.systemTemp;
      final File file = File('${tempDir.path}/mindsync_backup_data.$format');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup exported successfully: ${file.path}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export backup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportFormat = null;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      final box = StorageService.getBox(AppConstants.cacheBoxName);
      await box.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local Hive cache cleared successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear cache: $e')),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    try {
      final ApplicationSettings defaults = ApplicationSettings(
        theme: 'system',
        fontSize: 'medium',
        animationsEnabled: true,
        updatedAt: DateTime.now(),
      );
      await ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(defaults);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application settings reset to defaults.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Storage'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Section 1: Backup Exporter
          Text(
            'Export Personal Data',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Download a complete copy of your profile configurations, settings preferences, and telemetry indexes.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  _buildExportItem('JSON Format', 'Complete database structure representation.', 'json'),
                  const Divider(height: 20),
                  _buildExportItem('CSV Format', 'Tabular sheet mapping logged metrics.', 'csv'),
                  const Divider(height: 20),
                  _buildExportItem('PDF Format', 'Formatted document overview report.', 'pdf'),
                ],
              ),
            ),
          ),
          const Divider(height: 36),

          // Section 2: Storage Reset
          Text(
            'Storage & Cache Actions',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined, color: Colors.orange),
            title: const Text('Clear Cached Files', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Deletes local Hive cache databases. Data is re-fetched when connected online.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearCache,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore_outlined, color: Colors.orange),
            title: const Text('Reset App Configurations', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Restores default font configurations, themes, and notification intervals.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _resetSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildExportItem(String label, String desc, String format) {
    final bool loadingThis = _isExporting && _exportFormat == format;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      trailing: ElevatedButton(
        onPressed: _isExporting ? null : () => _exportData(format),
        child: loadingThis
            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Export'),
      ),
    );
  }
}
