import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../../domain/entities/privacy_settings.dart';

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PrivacySettings> state = ref.watch(privacySettingsStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Consents'),
        centerTitle: true,
      ),
      body: state.when(
        data: (PrivacySettings privacy) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              SwitchListTile(
                title: const Text('Analytics Collection'),
                subtitle: const Text('Share anonymized crash statistics and workflow logs to optimize software performance.'),
                value: privacy.analyticsCollection,
                onChanged: (bool val) {
                  ref.read(privacySettingsStateProvider.notifier).updatePrivacy(
                    privacy.copyWith(analyticsCollection: val),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('AI Personalization'),
                subtitle: const Text('Permit ML pipelines to inspect historical logs to customize stress relief activities.'),
                value: privacy.aiPersonalization,
                onChanged: (bool val) {
                  ref.read(privacySettingsStateProvider.notifier).updatePrivacy(
                    privacy.copyWith(aiPersonalization: val),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Location Access'),
                subtitle: const Text('Enable weather checking features to adapt recommendations to your current local climate.'),
                value: privacy.locationAccess,
                onChanged: (bool val) {
                  ref.read(privacySettingsStateProvider.notifier).updatePrivacy(
                    privacy.copyWith(locationAccess: val),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Notification Permissions'),
                subtitle: const Text('Deliver immediate motivational and hydration reminders to your system tray.'),
                value: privacy.notificationPermissions,
                onChanged: (bool val) {
                  ref.read(privacySettingsStateProvider.notifier).updatePrivacy(
                    privacy.copyWith(notificationPermissions: val),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Anonymized Data Sharing'),
                subtitle: const Text('Help wellness research by sharing generalized workspace health indices.'),
                value: privacy.dataSharing,
                onChanged: (bool val) {
                  ref.read(privacySettingsStateProvider.notifier).updatePrivacy(
                    privacy.copyWith(dataSharing: val),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load privacy: $err')),
      ),
    );
  }
}
