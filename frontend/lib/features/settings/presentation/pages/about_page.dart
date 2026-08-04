import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About MindSync AI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // App Logo Placeholder
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              child: Icon(Icons.auto_awesome, size: 40, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'MindSync AI',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              'Version 1.0.0 (Build 240)',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            
            // App Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'MindSync AI is an intelligent mental wellness companion built explicitly for software developers and IT professionals. It leverages state-of-the-art Random Forest machine learning models to track burnout tendencies and recommend balance.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Lists
            ListTile(
              title: const Text('Developer Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('MindSync AI Team & Google DeepMind Paired Engineers'),
              trailing: const Icon(Icons.code),
            ),
            const Divider(),
            ListTile(
              title: const Text('Acknowledgements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Built using Flutter, FastAPI, Scikit-learn, ReportLab, and FL Chart'),
              trailing: const Icon(Icons.favorite, color: Colors.red),
            ),
            const Divider(),
            ListTile(
              title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Software Licenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'MindSync AI',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
