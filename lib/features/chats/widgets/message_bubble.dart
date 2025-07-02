import 'package:cached_network_image/cached_network_image.dart';
import 'package:extroza/features/chats/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSentByMe;
  final VoidCallback onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (message.isDeleted) {
      return _buildDeletedMessage(theme);
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: message.type == MessageType.image 
          ? _buildImageMessage(context, theme)
          : _buildTextMessage(context, theme),
    );
  }

  Widget _buildDeletedMessage(ThemeData theme) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: theme.dividerColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'This message was deleted',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context, ThemeData theme) {
    final formattedTime = DateFormat('HH:mm').format(message.timestamp.toDate());
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSentByMe ? theme.colorScheme.primary : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSentByMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isSentByMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isSentByMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            if (message.isEdited)
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Text(
                  'edited',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: (isSentByMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer).withOpacity(0.7),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: (isSentByMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer).withOpacity(0.7),
                ),
              ),
            ),
            if (isSentByMe)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 16,
                  color: message.isRead ? Colors.lightBlueAccent : (isSentByMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer).withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context, ThemeData theme) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: message.text,
            placeholder: (context, url) => Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
