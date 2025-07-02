import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/core/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enum to define the type of message.
enum MessageType { text, image }

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  // --- GET CHATS STREAM ---
  Stream<QuerySnapshot> getChatsStream() {
    final String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  String getChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) > 0 ? '$userId1-$userId2' : '$userId2-$userId1';
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- SEND TEXT MESSAGE ---
  Future<void> sendTextMessage(String chatId, String text, String recipientId) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    final Message newMessage = Message(
      id: '', 
      senderId: currentUserId,
      text: text,
      timestamp: timestamp,
      type: MessageType.text, // Explicitly set type
      isRead: false,
    );
    
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toJson());

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, recipientId],
      'lastMessageText': text,
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': currentUserId,
    }, SetOptions(merge: true));
  }

  // --- NEW: SEND IMAGE MESSAGE ---
  Future<void> sendImageMessage(String chatId, File imageFile, String recipientId) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // 1. Upload image and get URL
    String? imageUrl = await _storageService.uploadImageToChat(imageFile, chatId);

    if (imageUrl != null) {
      // 2. Create message with image URL
      final Message newMessage = Message(
        id: '',
        senderId: currentUserId,
        text: imageUrl, // The text field now holds the URL
        timestamp: timestamp,
        type: MessageType.image, // Set the type to image
        isRead: false,
      );

      // 3. Save message to Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(newMessage.toJson());

      // 4. Update the chat preview
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUserId, recipientId],
        'lastMessageText': '📷 Photo', // Use a placeholder for the preview
        'lastMessageTimestamp': timestamp,
        'lastMessageSenderId': currentUserId,
      }, SetOptions(merge: true));
    }
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
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({'isDeleted': true});
  }
}

// --- UPDATED MESSAGE MODEL ---
class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final MessageType type; // NEW
  final bool isEdited;
  final bool isDeleted;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text, // NEW
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
      // Read the type from Firestore, default to text if not present
      type: MessageType.values[data['type'] ?? MessageType.text.index], // NEW
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
      'type': type.index, // NEW: Store the enum index
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'isRead': isRead,
    };
  }
}
