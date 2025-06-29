import 'package:extroza/features/chats/models/chat_model.dart';
import 'package:extroza/features/chats/widgets/chat_list_item.dart';
import 'package:extroza/features/contacts/screens/contacts_screen.dart'; 
import 'package:extroza/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  final List<Chat> dummyChats = const [
    Chat(
      otherUserId: 'extroza_team_support',
      name: 'Extroza Team',
      lastMessage: 'Welcome to Extroza! Tap here for tips.',
      avatarUrl: 'https://placehold.co/100x100/3A76F0/FFFFFF?text=E',
      timestamp: '20:15',
      unreadCount: 1,
    ),
    Chat(
      otherUserId: 'user_2_jane',
      name: 'Jane Doe',
      lastMessage: 'Sounds good, see you then!',
      avatarUrl: 'https://placehold.co/100x100/E6E6E6/000000?text=JD',
      timestamp: '19:22',
      unreadCount: 2,
    ),
    Chat(
      otherUserId: 'user_3_john',
      name: 'John Smith',
      lastMessage: 'Haha, that\'s hilarious �',
      avatarUrl: 'https://placehold.co/100x100/D4EDDA/000000?text=JS',
      timestamp: '18:45',
    ),
    Chat(
      otherUserId: 'group_sa_tech',
      name: 'SA Tech Group',
      lastMessage: 'Peter: Don\'t forget to push your code.',
      avatarUrl: 'https://placehold.co/100x100/F8D7DA/000000?text=ST',
      timestamp: '17:30',
      unreadCount: 5,
      isMuted: true,
    ),
     Chat(
      otherUserId: 'user_4_mom',
      name: 'Mom',
      lastMessage: 'Please call me when you get a chance.',
      avatarUrl: 'https://placehold.co/100x100/FFF3CD/000000?text=M',
      timestamp: '15:12',
    ),
    Chat(
      otherUserId: 'user_5_david',
      name: 'David',
      lastMessage: 'You sent a photo.',
      avatarUrl: 'https://placehold.co/100x100/C3E6CB/000000?text=D',
      timestamp: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              print("Search button pressed");
            },
          ),
          // --- Updated More Options Menu ---
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                 Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
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
      body: ListView.separated(
        itemCount: dummyChats.length,
        itemBuilder: (context, index) {
          final chat = dummyChats[index];
          return ChatListItem(chat: chat);
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 80,
          endIndent: 16,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ContactsScreen()),
          );
        },
        child: const Icon(Icons.message_rounded),
      ),
    );
  }
}
