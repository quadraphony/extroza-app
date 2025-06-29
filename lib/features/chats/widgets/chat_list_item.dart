import 'package:extroza/features/chats/models/chat_model.dart';
import 'package:extroza/features/chats/screens/individual_chat_screen.dart'; // Import the new screen
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // --- NAVIGATION UPDATE ---
        // Navigate to the individual chat screen, passing the chat data.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IndividualChatScreen(chat: chat),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(chat.avatarUrl),
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            chat.timestamp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          else
            // If there are no unread messages, show a mute icon if needed
            if (chat.isMuted)
              Icon(Icons.volume_off_rounded, size: 16, color: Colors.grey[500])
            else
              const SizedBox(height: 16), // Placeholder to keep alignment
        ],
      ),
    );
  }
}
