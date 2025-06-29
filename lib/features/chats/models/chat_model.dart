class Chat {
  final String otherUserId; // The unique ID of the person we are chatting with
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isMuted;

  const Chat({
    required this.otherUserId,
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isMuted = false,
  });
}
