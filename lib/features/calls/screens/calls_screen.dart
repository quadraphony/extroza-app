import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/core/services/database_service.dart';
import 'package:extroza/features/calls/models/call_model.dart';
import 'package:extroza/features/calls/screens/call_screen.dart';
import 'package:extroza/features/calls/service/call_service.dart';
import 'package:extroza/features/chats/screens/new_chat_screen.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final CallService _callService = CallService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_call),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const NewChatScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _callService.getCallHistoryStream(),
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
                  'No recent calls.\nTap the phone icon to start a call.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final callDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: callDocs.length,
            itemBuilder: (context, index) {
              final call = CallModel.fromFirestore(callDocs[index]);
              return _CallHistoryListItem(
                call: call,
                currentUserId: _currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class _CallHistoryListItem extends StatelessWidget {
  final CallModel call;
  final String currentUserId;
  const _CallHistoryListItem(
      {required this.call, required this.currentUserId});

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM').format(date);
    }
  }

  String getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 1 ? 2 : 1;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutgoing = call.callerId == currentUserId;
    final CallStatus status = isOutgoing
        ? CallStatus.outgoing
        : (call.durationInSeconds == null ? CallStatus.missed : CallStatus.incoming);

    final bool isMissed = status == CallStatus.missed;
    final String displayName = isOutgoing ? call.receiverName : call.callerName;
    final String avatarUrl =
        isOutgoing ? call.receiverAvatarUrl ?? '' : call.callerAvatarUrl ?? '';
    final Color titleColor =
        isMissed ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color!;
    final bool hasImage = avatarUrl.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: hasImage ? NetworkImage(avatarUrl) : null,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: !hasImage
            ? Text(
                getInitials(displayName),
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        displayName,
        style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
      ),
      subtitle: Row(
        children: [
          Icon(
            isOutgoing ? Icons.call_made : Icons.call_received,
            size: 16,
            color: isMissed ? Colors.red : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            _formatTimestamp(call.timestamp),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          call.type == CallType.video
              ? Icons.videocam_rounded
              : Icons.call_rounded,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () async {
          final dbService = DatabaseService();
          final otherUserId = isOutgoing ? call.receiverId : call.callerId;
          final userToCallBack = await dbService.getUserProfile(otherUserId);

          if (userToCallBack != null) {
            final cameraStatus = await Permission.camera.request();
            final micStatus = await Permission.microphone.request();

            if (cameraStatus.isGranted && micStatus.isGranted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CallScreen(receiver: userToCallBack),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera and Microphone permissions are required to make calls.'))
              );
            }
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not find user to call back.'))
            );
          }
        },
      ),
    );
  }
}
