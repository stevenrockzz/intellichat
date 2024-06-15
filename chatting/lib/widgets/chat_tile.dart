import 'package:chatting/widgets/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String lastMessage;
  final DateTime timestamp;
  final Map<String, dynamic> receiverData;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.lastMessage,
    required this.timestamp,
    required this.receiverData,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat('hh:mm a').format(timestamp);

    return lastMessage != ""
        ? ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(receiverData['imageUrl']),
            ),
            title: Text(receiverData['name']),
            subtitle: Text(
              lastMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              timeFormatted,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chatId,
                    receiverId: receiverData['uid'],
                  ),
                ),
              );
            },
          )
        : Container();
  }
}
