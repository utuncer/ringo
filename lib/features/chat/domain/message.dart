class Message {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? teamId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final List<String> deletedBy;
  final String? senderName; // Joined
  final String? senderAvatar; // Joined

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.teamId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.deletedBy,
    this.senderName,
    this.senderAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      teamId: json['team_id'],
      content: json['content'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      deletedBy: List<String>.from(json['deleted_by'] ?? []),
      senderName: json['users']?['full_name'],
      senderAvatar: json['users']?['avatar_url'],
    );
  }
}
