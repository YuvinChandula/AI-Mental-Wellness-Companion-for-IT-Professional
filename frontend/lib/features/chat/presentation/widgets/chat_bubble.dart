import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareMessage(BuildContext context) {
    // Quick sharing mock simulation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message ready to share!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isModel = message.sender == 'model';
    final formattedTime = DateFormat('h:mm a').format(message.createdAt);

    return Align(
      alignment: isModel ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (isModel) ...<Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: context.colorScheme.secondary.withOpacity(0.12),
                child: Icon(Icons.auto_awesome, color: context.colorScheme.secondary, size: 14),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isModel ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: <Widget>[
                  Semantics(
                    label: '${isModel ? "AI response" : "User message"}: ${message.message}',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isModel
                            ? context.colorScheme.surface
                            : context.colorScheme.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isModel ? 4 : 16),
                          bottomRight: Radius.circular(isModel ? 16 : 4),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: MarkdownText(
                        text: message.message,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isModel
                              ? context.colorScheme.onSurface
                              : Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bubble Footer: Time + Quick Copy/Share actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        formattedTime,
                        style: context.textTheme.labelSmall?.copyWith(fontSize: 9),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context),
                        child: Icon(
                          Icons.copy,
                          size: 10,
                          color: context.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _shareMessage(context),
                        child: Icon(
                          Icons.share,
                          size: 10,
                          color: context.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isModel) ...<Widget>[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 14,
                backgroundColor: context.colorScheme.primary.withOpacity(0.12),
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MarkdownText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split('\n');
    final children = <Widget>[];

    for (final paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) continue;

      final isBullet = paragraph.trim().startsWith('-') ||
          (paragraph.trim().startsWith('*') && !paragraph.trim().startsWith('**'));
      final isNumbered = RegExp(r'^\d+\.').hasMatch(paragraph.trim());

      String cleanText = paragraph;
      if (isBullet) {
        cleanText = cleanText.trim().substring(1).trim();
      } else if (isNumbered) {
        final match = RegExp(r'^\d+\.').firstMatch(cleanText.trim());
        if (match != null) {
          cleanText = cleanText.trim().substring(match.end).trim();
        }
      }

      final spans = _parseInlineFormatting(cleanText, context);

      if (isBullet) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('• ', style: style?.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: spans, style: style),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (isNumbered) {
        final dotIdx = paragraph.trim().indexOf('.');
        final prefix = dotIdx != -1 ? paragraph.trim().substring(0, dotIdx + 1) : '1.';
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('$prefix ', style: style?.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: spans, style: style),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              text: TextSpan(children: spans, style: style),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<InlineSpan> _parseInlineFormatting(String text, BuildContext context) {
    final spans = <InlineSpan>[];
    final regExp = RegExp(r'(\*\*.*?\*\*|\*.*?\*)');
    final matches = regExp.allMatches(text);

    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final matchText = match.group(0)!;
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (matchText.startsWith('*') && matchText.endsWith('*')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
