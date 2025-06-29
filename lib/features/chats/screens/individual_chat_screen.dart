import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/features/chats/models/chat_model.dart';
import 'package:extroza/features/chats/services/chat_service.dart';
import 'package:extroza/features/chats/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class IndividualChatScreen extends StatefulWidget {
  final Chat chat;
  const IndividualChatScreen({super.key, required this.chat});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = 'user_1_leeroy';

  @override
  void initState() {
    super.initState();
    // When the screen loads, mark incoming messages as read.
    _chatService.markMessagesAsRead('extroza_team_chat', _currentUserId);
  }

  void _handleSendPressed() {
    if (_textController.text.isNotEmpty) {
      _chatService.sendMessage('extroza_team_chat', _textController.text);
      _textController.clear();
    }
  }
  
  void _showEditMessageDialog(Message message) {
    final editController = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: editController, autofocus: true, decoration: const InputDecoration(hintText: "Enter new message")),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                _chatService.editMessage('extroza_team_chat', message.id, editController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, Message message) {
    if (message.isDeleted) return;

    final isMyMessage = message.senderId == _currentUserId;
    final canDeleteForEveryone = DateTime.now().difference(message.timestamp.toDate()).inMinutes < 15;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy Text'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.text));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                },
              ),
              if (isMyMessage)
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEditMessageDialog(message);
                  },
                ),
              if (isMyMessage)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('Delete for Everyone'),
                  enabled: canDeleteForEveryone,
                  onTap: canDeleteForEveryone ? () {
                    _chatService.deleteMessageForEveryone('extroza_team_chat', message.id);
                    Navigator.of(context).pop();
                  } : null,
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.chat.avatarUrl)),
            const SizedBox(width: 12),
            Text(widget.chat.name),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessagesStream('extroza_team_chat'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hi!'));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong...'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = Message.fromFirestore(messages[index]);
                    final bool isSentByMe = message.senderId == _currentUserId;

                    bool showDateSeparator = false;
                    if (index < messages.length - 1) {
                      final prevMessage = Message.fromFirestore(messages[index + 1]);
                      final currentMessageDate = message.timestamp.toDate();
                      final prevMessageDate = prevMessage.timestamp.toDate();
                      if (currentMessageDate.day != prevMessageDate.day ||
                          currentMessageDate.month != prevMessageDate.month ||
                          currentMessageDate.year != prevMessageDate.year) {
                        showDateSeparator = true;
                      }
                    } else {
                      showDateSeparator = true;
                    }

                    return Column(
                      children: [
                        if (showDateSeparator)
                          _DateSeparator(date: _formatDateSeparator(message.timestamp.toDate())),
                        MessageBubble(
                          message: message,
                          isSentByMe: isSentByMe,
                          onLongPress: () => _showMessageOptions(context, message),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildTextInputArea(),
        ],
      ),
    );
  }

  Widget _buildTextInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {}),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onSubmitted: (_) => _handleSendPressed(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded, color: Theme.of(context).primaryColor),
              onPressed: _handleSendPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        date,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
