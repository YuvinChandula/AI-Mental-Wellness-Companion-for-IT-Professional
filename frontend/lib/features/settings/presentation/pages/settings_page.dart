import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../../domain/entities/application_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showThemePicker(BuildContext context, WidgetRef ref, ApplicationSettings settings) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Select Theme', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.wb_sunny_outlined),
                title: const Text('Light Mode'),
                trailing: settings.theme == 'light' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(
                    settings.copyWith(theme: 'light'),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.nightlight_outlined),
                title: const Text('Dark Mode'),
                trailing: settings.theme == 'dark' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(
                    settings.copyWith(theme: 'dark'),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_suggest_outlined),
                title: const Text('System Mode'),
                trailing: settings.theme == 'system' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(
                    settings.copyWith(theme: 'system'),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizePicker(BuildContext context, WidgetRef ref, ApplicationSettings settings) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Select Font Size', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Small Text', style: TextStyle(fontSize: 12)),
                trailing: settings.fontSize == 'small' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(
                    settings.copyWith(fontSize: 'small'),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Medium Text', style: TextStyle(fontSize: 14)),
                trailing: settings.fontSize == 'medium' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(
                    settings.copyWith(fontSize: 'medium'),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Large Text', style: TextStyle(fontSize: 18)),
                trailing: settings.fontSize == 'large' ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(
                    settings.copyWith(fontSize: 'large'),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ApplicationSettings> settingsState = ref.watch(applicationSettingsStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: settingsState.when(
        data: (ApplicationSettings settings) {
          return ListView(
            padding: const EdgeInsets.all(12.0),
            children: <Widget>[
              // Section 1: Appearance
              _buildSectionTitle(theme, 'Appearance'),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme Mode'),
                subtitle: Text(settings.theme.toUpperCase()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemePicker(context, ref, settings),
              ),
              ListTile(
                leading: const Icon(Icons.format_size_outlined),
                title: const Text('Text Size'),
                subtitle: Text(settings.fontSize.toUpperCase()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showFontSizePicker(context, ref, settings),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.animation),
                title: const Text('Enable Animations'),
                value: settings.animationsEnabled,
                onChanged: (bool value) {
                  ref.read(applicationSettingsStateProvider.notifier).updateAppSettings(
                    settings.copyWith(animationsEnabled: value),
                  );
                },
              ),
              const Divider(height: 24),

              // Section 2: Preferences Configurations
              _buildSectionTitle(theme, 'Preferences & Privacy'),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Notification Schedules'),
                subtitle: const Text('Configure mood, sleep, and water alarms'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/notifications-settings'),
              ),
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('Security & Sessions'),
                subtitle: const Text('Update passwords and manage logins'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/security-settings'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Controls'),
                subtitle: const Text('Manage analytics collection and location access'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/privacy-settings'),
              ),
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Data Management'),
                subtitle: const Text('Export logs as PDF/CSV/JSON or clear local cache'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/data-management'),
              ),
              const Divider(height: 24),

              // Section 3: Information & Support
              _buildSectionTitle(theme, 'Support & Information'),
              ListTile(
                leading: const Icon(Icons.help_outline_outlined),
                title: const Text('Help & Support FAQ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/help-support'),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About Application'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
              const Divider(height: 24),

              // Section 4: Sign out
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await ref.read(authStateProvider.notifier).logoutUser();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load settings: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
