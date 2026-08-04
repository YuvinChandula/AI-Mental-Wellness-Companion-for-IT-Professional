import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _feedbackController = TextEditingController();
  String _category = 'Feedback';

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) return;

    _feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you! Your $_category has been submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Section 1: FAQs
          Text('Frequently Asked Questions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const ExpansionTile(
            title: Text('How does MindSync predict burnout?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'MindSync evaluates working hours, mood journals, stress factors, and sleep metrics against our Random Forest machine learning models to forecast risk levels.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              )
            ],
          ),
          const ExpansionTile(
            title: Text('Can I use the app offline?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Yes. Telemetry records and notifications are cached locally inside Hive databases and synchronized to Firestore once you connect to the internet.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              )
            ],
          ),
          const ExpansionTile(
            title: Text('How do quiet hours shift alerts?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'If a scheduled notification falls inside quiet hours, the system shifts the alert to trigger immediately at the end of the quiet hours (e.g. 7:00 AM).',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              )
            ],
          ),
          const Divider(height: 36),

          // Section 2: Contact
          Text('Contact Support', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: Colors.teal),
            title: const Text('Email Support Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('support@mindsync.ai'),
            onTap: () {},
          ),
          const Divider(height: 36),

          // Section 3: Submit bug / feedback
          Text('Report a Bug or Send Feedback', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            onChanged: (String? val) {
              if (val != null) setState(() => _category = val);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'Feedback', child: Text('Send Feedback')),
              DropdownMenuItem<String>(value: 'Bug Report', child: Text('Report a Bug')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter a detailed description...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
              onPressed: _submitFeedback,
              child: const Text('Submit'),
            ),
          )
        ],
      ),
    );
  }
}
