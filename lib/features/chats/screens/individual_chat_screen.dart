import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:extroza/features/calls/screens/call_screen.dart';
import 'package:extroza/features/chats/models/chat_model.dart';
import 'package:extroza/features/chats/services/chat_service.dart';
import 'package:extroza/features/chats/widgets/message_bubble.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' as foundation;


class IndividualChatScreen extends StatefulWidget {
  final Chat chat;
  const IndividualChatScreen({super.key, required this.chat});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid; 

  late final String _chatId;
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _chatId = _chatService.getChatId(_currentUserId, widget.chat.otherUserId);
    _chatService.markMessagesAsRead(_chatId, _currentUserId);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSendPressed() {
    if (_textController.text.isNotEmpty) {
      _chatService.sendTextMessage(_chatId, _textController.text, widget.chat.otherUserId);
      _textController.clear();
    }
  }
  
  void _handleImageSelection() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _chatService.sendImageMessage(_chatId, File(pickedFile.path), widget.chat.otherUserId);
    }
  }

  void _handleCall(bool isVideoCall) async {
    final permission = isVideoCall ? Permission.camera : Permission.microphone;
    if (await permission.request().isGranted) {
       final receiverUser = UserModel(uid: widget.chat.otherUserId, fullName: widget.chat.name, username: '', nickname: '');
       Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CallScreen(receiver: receiverUser),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isVideoCall ? "Camera" : "Microphone"} permission is required.'))
      );
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
                _chatService.editMessage(_chatId, message.id, editController.text);
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
              if (message.type == MessageType.text)
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy Text'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.text));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                  },
                ),
              if (isMyMessage && message.type == MessageType.text)
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
                    _chatService.deleteMessageForEveryone(_chatId, message.id);
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
      return DateFormat('d MMMM yy').format(date);
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
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () => _handleCall(false)),
          IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: () => _handleCall(true)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessagesStream(_chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet. Say hi to ${widget.chat.name}!'));
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
          if (_showEmojiPicker) _buildEmojiPicker(),
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
            IconButton(icon: const Icon(Icons.add_rounded), onPressed: _handleImageSelection),
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                _focusNode.unfocus();
                setState(() => _showEmojiPicker = !_showEmojiPicker);
              },
            ),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
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

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _textController.text += emoji.emoji;
        },
        config: const Config(
          // FIX: Removed incompatible 'columns' parameter.
          verticalSpacing: 0,
          horizontalSpacing: 0,
          bgColor: Color(0xFFF2F2F2),
          indicatorColor: Colors.blue,
          iconColor: Colors.grey,
          iconColorSelected: Colors.blue,
          progressIndicatorColor: Colors.blue,
          backspaceColor: Colors.blue,
          skinToneDialogBgColor: Colors.white,
          skinToneIndicatorColor: Colors.grey,
          enableSkinTones: true,
          showRecentsTab: true,
          recentsLimit: 28,
          noRecentsText: "No Recents",
          noRecentsStyle: TextStyle(fontSize: 20, color: Colors.black26),
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
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
