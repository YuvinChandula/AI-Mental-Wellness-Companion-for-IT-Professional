import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class JournalDraftField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const JournalDraftField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<JournalDraftField> createState() => _JournalDraftFieldState();
}

class _JournalDraftFieldState extends State<JournalDraftField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant JournalDraftField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the draft was loaded asynchronously after init, update controller text
    if (widget.initialValue != oldWidget.initialValue && _controller.text.isEmpty) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Daily Notes / Thoughts',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _controller,
                  maxLines: 6,
                  minLines: 3,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    hintText: 'Write down your thoughts, stress factors, or achievements today...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    counterText: '', // Hide default counter to customize layout
                  ),
                  style: context.textTheme.bodyMedium?.copyWith(height: 1.4),
                  onChanged: widget.onChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.save_outlined, size: 14, color: context.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'Draft auto-saved',
                          style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (BuildContext context, Widget? child) {
                        final count = _controller.text.length;
                        return Text(
                          '$count/1000',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: count >= 500 ? context.colorScheme.primary : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
