class AppNotification {
  final String id;
  final String userId;
  final String type; // 'invitation', 'like', 'comment'
  final String title;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata; // e.g., team_id, post_id

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      content: json['content'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }
}
