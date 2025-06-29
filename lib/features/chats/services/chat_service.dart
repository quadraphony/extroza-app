import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<void> sendMessage(String chatId, String text) async {
    final String currentUserId = 'user_1_leeroy'; 

    final Message newMessage = Message(
      id: '', // Firestore will generate this
      senderId: currentUserId,
      text: text,
      timestamp: Timestamp.now(),
      isRead: false, // New messages start as unread
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toJson());
  }

  // --- NEW: MARK MESSAGES AS READ ---
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

  // --- EDIT & DELETE (No changes needed here) ---
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
  final bool isRead; // New field for read status

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isEdited = false,
    this.isDeleted = false,
    this.isRead = false, // Default to false
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
      isRead: data['isRead'] ?? false, // Read the new field
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
