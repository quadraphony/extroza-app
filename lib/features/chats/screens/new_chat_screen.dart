import 'package:extroza/core/services/database_service.dart';
import 'package:extroza/features/calls/screens/call_screen.dart';
import 'package:extroza/features/chats/models/chat_model.dart';
import 'package:extroza/features/chats/screens/individual_chat_screen.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<UserModel>> _usersFuture;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _currentUser = await _db.getUserProfile(uid);
    }
    _usersFuture = _db.getUsers();
    if (mounted) {
      setState(() {});
    }
  }

  /// Handles call initiation after checking for necessary permissions.
  Future<void> _handleCall(BuildContext context, UserModel userToCall) async {
    // Request camera and microphone permissions
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    // Check if permissions were granted before proceeding
    if (cameraStatus.isGranted && micStatus.isGranted) {
       if (_currentUser != null) {
         // Navigate to the CallScreen to start the call
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (_) => CallScreen(receiver: userToCall),
           ),
         );
       }
    } else {
       // Show a message if permissions are denied
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and Microphone permissions are required to make calls.'))
      );
    }
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
        title: const Text('Start a Conversation'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _currentUser == null) {
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.videocam, color: Theme.of(context).primaryColor),
                      onPressed: () => _handleCall(context, user),
                    ),
                  ],
                ),
                 onTap: () {
                  final chat = Chat(
                    otherUserId: user.uid,
                    name: user.fullName,
                    avatarUrl: user.profilePictureUrl ?? '',
                    lastMessage: '',
                    timestamp: '',
                  );
                  Navigator.of(context).push(
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
