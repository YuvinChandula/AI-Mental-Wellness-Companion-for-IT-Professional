import 'package:flutter/material.dart';

class FeedbackDialog extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;

  const FeedbackDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Feedback'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'How helpful is this wellness recommendation? Your feedback helps tailor future insights.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Thumb Ratings
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.thumb_up,
                  color: _isLiked ? Colors.green : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    if (_isLiked) _isDisliked = false;
                  });
                },
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: Icon(
                  Icons.thumb_down,
                  color: _isDisliked ? Colors.red : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _isDisliked = !_isDisliked;
                    if (_isDisliked) _isLiked = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add additional comments (optional)...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(<String, dynamic>{
              'feedback': _controller.text.trim(),
              'like': _isLiked,
              'dislike': _isDisliked,
            });
            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
