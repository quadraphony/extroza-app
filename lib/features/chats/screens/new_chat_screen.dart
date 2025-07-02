import 'package:extroza/core/services/database_service.dart';
import 'package:extroza/features/chats/models/chat_model.dart';
import 'package:extroza/features/chats/screens/individual_chat_screen.dart';
import 'package:extroza/models/user_model.dart';
import 'package:flutter/material.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _db.getUsers();
  }

  String getInitials(String name) {
    if (name.isEmpty) return 'EX';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final hasImage = user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty;

              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: hasImage ? NetworkImage(user.profilePictureUrl!) : null,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: !hasImage
                      ? Text(
                          getInitials(user.fullName),
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                title: Text(user.fullName),
                subtitle: Text(user.username),
                onTap: () {
                  // Create a Chat object to pass to the chat screen
                  final chat = Chat(
                    otherUserId: user.uid,
                    name: user.fullName,
                    avatarUrl: user.profilePictureUrl ?? '',
                    lastMessage: '', // Not needed for a new chat
                    timestamp: '',   // Not needed for a new chat
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => IndividualChatScreen(chat: chat),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
