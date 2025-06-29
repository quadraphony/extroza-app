import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- NEW: Helper function to create a unique chat ID ---
  String getChatId(String userId1, String userId2) {
    // Sort the user IDs alphabetically to ensure consistency.
    // This makes sure that the chat ID between user A and user B is the same
    // regardless of who initiates the chat.
    if (userId1.compareTo(userId2) > 0) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  // --- GET MESSAGES STREAM ---
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- SEND MESSAGE ---
  // Updated to accept the current user's ID
  Future<void> sendMessage(String chatId, String text, String currentUserId) async {
    final Message newMessage = Message(
      id: '', // Firestore will generate this
      senderId: currentUserId,
      text: text,
      timestamp: Timestamp.now(),
      isRead: false,
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toJson());
  }

  // --- MARK MESSAGES AS READ ---
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

  // --- EDIT & DELETE ---
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
