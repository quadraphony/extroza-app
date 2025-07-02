import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- GET CHATS STREAM ---
  /// Gets a real-time stream of chats for the current user.
  Stream<QuerySnapshot> getChatsStream() {
    final String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  String getChatId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) > 0) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- SEND MESSAGE ---
  /// Sends a message and updates the chat metadata.
  Future<void> sendMessage(String chatId, String text, String recipientId) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    final Message newMessage = Message(
      id: '', // Firestore will generate this
      senderId: currentUserId,
      text: text,
      timestamp: timestamp,
      isRead: false,
    );
    
    // Add the new message to the messages subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toJson());

    // Update the main chat document with the last message info
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, recipientId],
      'lastMessageText': text,
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': currentUserId,
    }, SetOptions(merge: true)); // Use merge to create or update
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final querySnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final WriteBatch batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> editMessage(String chatId, String messageId, String newText) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({'text': newText, 'isEdited': true});
  }

  Future<void> deleteMessageForEveryone(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({'text': 'This message was deleted', 'isDeleted': true});
  }
}

// Updated Message data structure
class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final bool isEdited;
  final bool isDeleted;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isEdited = false,
    this.isDeleted = false,
    this.isRead = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'isRead': isRead,
    };
  }
}
