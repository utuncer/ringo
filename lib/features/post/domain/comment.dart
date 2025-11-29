class Comment {
  final String id;
  final String userId;
  final String postId;
  final String content;
  final DateTime createdAt;
  final String username;
  final String fullName;
  final String? userAvatarUrl;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.username,
    required this.fullName,
    this.userAvatarUrl,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      username: json['users']['username'],
      fullName: json['users']['full_name'],
      userAvatarUrl: json['users']['avatar_url'],
    );
  }
}
