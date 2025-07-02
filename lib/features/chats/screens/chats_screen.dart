import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/core/services/database_service.dart';
import 'package:extroza/features/chats/models/chat_model.dart';
import 'package:extroza/features/chats/screens/new_chat_screen.dart';
import 'package:extroza/features/chats/services/chat_service.dart';
import 'package:extroza/features/chats/widgets/chat_list_item.dart';
import 'package:extroza/features/settings/screens/settings_screen.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatService _chatService = ChatService();
  final DatabaseService _dbService = DatabaseService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No chats yet.\nTap the message button to start a conversation!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatDoc = chatDocs[index];
              final data = chatDoc.data() as Map<String, dynamic>;
              final List<dynamic> participants = data['participants'];
              final String otherUserId =
                  participants.firstWhere((id) => id != _currentUserId, orElse: () => '');

              if (otherUserId.isEmpty) {
                // This can happen in rare cases, like a chat with a deleted user.
                // We'll just skip rendering this item.
                return const SizedBox.shrink();
              }

              // Use a FutureBuilder to get the other user's profile info
              return FutureBuilder<UserModel?>(
                future: _dbService.getUserProfile(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    // Show a placeholder while loading user data
                    return ListTile(
                      leading: const CircleAvatar(radius: 28),
                      title: Container(height: 16, color: Colors.grey.shade300),
                      subtitle: Container(height: 12, width: 100, color: Colors.grey.shade200),
                    );
                  }

                  final otherUser = userSnapshot.data;
                  if (otherUser == null) {
                    // Handle case where user profile might not exist
                     return const ListTile(
                      leading: CircleAvatar(radius: 28),
                      title: Text('Unknown User'),
                    );
                  }

                  final lastMessageTimestamp =
                      data['lastMessageTimestamp'] as Timestamp?;
                  
                  final chat = Chat(
                    otherUserId: otherUserId,
                    name: otherUser.fullName,
                    avatarUrl: otherUser.profilePictureUrl ?? '',
                    lastMessage: data['lastMessageText'] ?? '',
                    timestamp: lastMessageTimestamp != null
                        ? DateFormat('HH:mm').format(lastMessageTimestamp.toDate())
                        : '',
                  );

                  return ChatListItem(chat: chat);
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 80,
              endIndent: 16,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NewChatScreen()),
          );
        },
        child: const Icon(Icons.message_rounded),
      ),
    );
  }
}
