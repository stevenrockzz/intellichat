import 'package:chatting/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receiverId;

  const ChatScreen({Key? key, required this.chatId, required this.receiverId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? loggedInUser;
  String? chatId;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void _showEditDialog(String chatId, String messageId, String initialText, ChatProvider chatProvider) {
    final TextEditingController editController = TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: editController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                chatProvider.editMessage(chatId, messageId, editController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(widget.receiverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            final receiverData = snapshot.data!.data() as Map<String, dynamic>?;

            final imageUrl = receiverData?['imageUrl'] ?? 'default_image_url';
            final name = receiverData?['name'] ?? 'Unknown';

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    SizedBox(width: 10),
                    Text(name),
                  ],
                ),
                backgroundColor: Color(0xFF3876FD), // Match the primary color
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0E0E0),
                      Color(0xFFBDBDBD),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: chatId != null && chatId!.isNotEmpty
                          ? MessagesStream(
                              chatId: chatId!,
                              receiverId: widget.receiverId,
                              onLongPress: (messageId, initialText, isSender) {
                                if (isSender) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.edit),
                                            title: Text('Edit'),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _showEditDialog(chatId!, messageId, initialText, chatProvider);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.delete),
                                            title: Text('Delete'),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              chatProvider.deleteMessage(chatId!, messageId);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            )
                          : Center(
                              child: Text("No Messages Yet"),
                            ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 120.0,
                                 // Adjust the maximum height as needed
                              ),
                              child: TextFormField(
                                controller: _textController,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: "Enter your message ...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (_textController.text.isNotEmpty) {
                                if (chatId == null || chatId!.isEmpty) {
                                  chatId = await chatProvider.createChatRoom(widget.receiverId);
                                }
                                if (chatId != null) {
                                  chatProvider.sendMessage(chatId!, _textController.text, widget.receiverId);
                                  _textController.clear();
                                }
                              }
                            },
                            icon: Icon(
                              Icons.send,
                              color: Color(0XFF3876FD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String chatId;
  final String receiverId;
  final Function(String messageId, String initialText, bool isSender) onLongPress;

  const MessagesStream({
    Key? key,
    required this.chatId,
    required this.receiverId,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>?;

          // Handle null values and check for expected fields
          final messageText = messageData?['text'] ?? '';
          final messageSender = messageData?['senderId'] ?? '';
          final messageTimestamp = messageData?['timestamp'] ?? FieldValue.serverTimestamp();
          final messageId = message.id;
          final isRead = messageData?['read'] ?? false;
          final isEdited = messageData?['isEdited'] ?? false;  // New field for edited status

          final currentUser = FirebaseAuth.instance.currentUser!.uid;
          final isSender = currentUser == messageSender;

          final messageWidget = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: isSender,
            timestamp: messageTimestamp,
            isRead: isRead,
            isEdited: isEdited,  // Pass edited status
            onLongPress: () => onLongPress(messageId, messageText, isSender),
          );
          messageWidgets.add(messageWidget);
        }
        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timestamp;
  final bool isRead;
  final bool isEdited; // New field for edited status
  final VoidCallback onLongPress;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
    required this.isRead,
    required this.isEdited, // Initialize edited status
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = (timestamp as Timestamp).toDate();
    final timeFormatted = DateFormat('hh:mm a').format(messageTime);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
              elevation: 5.0,
              color: isMe ? Colors.blue : Colors.grey.shade200,
              child: IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75, // Max width of 75% of screen width
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 15.0,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isEdited) // Display "edited" label if message is edited
                              Text(
                                '(edited)',
                                style: TextStyle(
                                  color: isMe ? Color.fromARGB(255, 64, 251, 67) : Colors.black54,
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            Spacer(),
                            Text(
                              timeFormatted,
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontSize: 12.0,
                              ),
                            ),
                            SizedBox(width: 5.0),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
