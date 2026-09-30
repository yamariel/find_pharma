import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime time;
  final Function()? onLongPress;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.text,
    required this.time,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = DateFormatter.formatDateTime(time);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? colorScheme.primary : colorScheme.surface,
              borderRadius: isUser
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: isUser
                        ? colorScheme.onPrimary.withAlpha(180)
                        : colorScheme.onSurface.withAlpha(130),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
