import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/profile/presentation/providers/profile_providers.dart';
import '../../../../core/services/inactivity_service.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  final _passwordKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final TextEditingController _deleteEmailController = TextEditingController();
  final TextEditingController _deletePasswordController = TextEditingController();

  bool _isUpdatingPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deleteEmailController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_passwordKey.currentState!.validate()) return;

    setState(() => _isUpdatingPassword = true);
    try {
      final notifier = ref.read(profileStateProvider.notifier);
      // Re-authenticate first
      await ref.read(profileRepositoryProvider).reauthenticate(
        '', // Email derived inside auth
        _currentPasswordController.text,
      );
      // Update password
      await ref.read(profileRepositoryProvider).changePassword(_newPasswordController.text);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  void _triggerDeleteAccountFlow() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account - Warning 1/2', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text(
            'Warning: Deleting your account will permanently wipe all your logged journals, exercise logs, notifications, and profile details from our databases. This action is irreversible.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                _showSecondDeleteConfirmation();
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  void _showSecondDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Confirm Deletion - Warning 2/2', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Are you absolutely sure? Please re-authenticate by entering your current password to authorize final deletion.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deletePasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deletePasswordController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  // Re-authenticate and execute deletion
                  await ref.read(profileRepositoryProvider).reauthenticate(
                    '', 
                    _deletePasswordController.text,
                  );
                  await ref.read(profileStateProvider.notifier).deleteUserAccount();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.go('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete Forever'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Change Password Form
            Text('Change Password', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _passwordKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || val.length < 6) ? 'Enter correct password' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || val.length < 6) ? 'Password must be 6+ chars' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isUpdatingPassword ? null : _changePassword,
                      child: _isUpdatingPassword
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 36),

            // Auto Sign-Out on Inactivity
            Text('Auto Sign-Out & Session Security', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final inactivityService = ref.watch(inactivityServiceProvider);
                final bool isEnabled = inactivityService.isEnabled;
                final int timeoutMinutes = inactivityService.timeoutMinutes;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: <Widget>[
                      SwitchListTile(
                        secondary: const Icon(Icons.timer_off, color: Colors.indigo),
                        title: const Text('Auto Sign-Out on Inactivity', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Automatically logs out user when idle to protect sensitive mental health logs.'),
                        value: isEnabled,
                        onChanged: (bool value) {
                          inactivityService.updateSettings(enabled: value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value ? 'Auto sign-out enabled.' : 'Auto sign-out disabled.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      if (isEnabled) ...<Widget>[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.access_time, color: Colors.indigo),
                          title: const Text('Inactivity Timeout'),
                          subtitle: Text('Sign out after $timeoutMinutes minute${timeoutMinutes == 1 ? '' : 's'} of no interaction.'),
                          trailing: DropdownButton<int>(
                            value: [1, 5, 15, 30, 60].contains(timeoutMinutes) ? timeoutMinutes : 15,
                            underline: const SizedBox(),
                            items: const <DropdownMenuItem<int>>[
                              DropdownMenuItem(value: 1, child: Text('1 min (Demo)')),
                              DropdownMenuItem(value: 5, child: Text('5 mins')),
                              DropdownMenuItem(value: 15, child: Text('15 mins')),
                              DropdownMenuItem(value: 30, child: Text('30 mins')),
                              DropdownMenuItem(value: 60, child: Text('60 mins')),
                            ],
                            onChanged: (int? newMinutes) {
                              if (newMinutes != null) {
                                inactivityService.updateSettings(timeoutMinutes: newMinutes);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Idle timeout updated to $newMinutes minute${newMinutes == 1 ? '' : 's'}.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 36),

            // Active Sessions Logs
            Text('Recent Sessions & Devices', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const <Widget>[
                  ListTile(
                    leading: Icon(Icons.phone_android, color: Colors.green),
                    title: Text('Google Pixel 7 (Active Session)'),
                    subtitle: Text('Colombo, Sri Lanka - IP: 192.168.1.10'),
                  ),
                  ListTile(
                    leading: Icon(Icons.laptop, color: Colors.grey),
                    title: Text('MacBook Pro (Chrome Web App)'),
                    subtitle: Text('Last access: 2 hours ago'),
                  ),
                ],
              ),
            ),
            const Divider(height: 36),

            // Danger Zone
            Text('Danger Zone', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Delete Account Permanently', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Wipe all logs and profile data from cloud storage folders.'),
                trailing: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: _triggerDeleteAccountFlow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
