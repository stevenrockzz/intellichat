import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool isRead;
  final bool isEdited;
  final VoidCallback onLongPress;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.isRead,
    required this.isEdited,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat('hh:mm a').format(timestamp);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Material(
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
              elevation: 5.0,
              color: isMe ? Colors.blue : Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text ?? '', // Provide a default value if text is null
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEdited ?? false) // Provide a default value for isEdited
                          Text(
                            '(edited)',
                            style: TextStyle(
                              color: isMe ? const Color.fromARGB(255, 64, 251, 67) : Colors.black54,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          timeFormatted,
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black54,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        if (isMe)
                          Icon(
                            Icons.done_all,
                            size: 16.0,
                            color: isRead ? Colors.green : Colors.red,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
