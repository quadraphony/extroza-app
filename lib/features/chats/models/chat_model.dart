// This class represents a single conversation in the chat list.
class Chat {
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isMuted;

  const Chat({
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isMuted = false,
  });
}
