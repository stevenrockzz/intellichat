import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChats(String userId) {
    return _firestore.collection("chats")
        .where('users', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> searchUsers(String query) {
    return _firestore.collection("users")
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String message, String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'isEdited': false,
      });

      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUser.uid, receiverId],
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).delete();
  }

  Future<void> editMessage(String chatId, String messageId, String newMessage) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'text': newMessage,
      'isEdited': true,
    });
  }

  Future<void> markMessagesAsRead(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'read': true,
    });
  }

  Future<String?> getChatroom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatQuery = await _firestore
          .collection('chats')
          .where('users', arrayContains: currentUser.uid)
          .get();

      final chats = chatQuery.docs
          .where((chat) => chat['users'].contains(receiverId))
          .toList();
      if (chats.isNotEmpty) {
        return chats.first.id;
      }
    }
    return null;
  }

  Future<String> createChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatRoom = await _firestore.collection('chats').add({
        'users': [currentUser.uid, receiverId],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return chatRoom.id;
    }
    throw Exception('current user is null');
  }
}
