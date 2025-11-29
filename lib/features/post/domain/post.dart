class Post {
  final String id;
  final String userId;
  final String? content;
  final String? imageUrl;
  final double? imageAspectRatio;
  final DateTime createdAt;
  final PostUser? user; // Değişti
  final int voteCount;
  final int commentCount;
  final bool isSaved;
  final int userVote;
  final List<String>? tags; // Eklendi
  final int? likes; // Eklendi
  final int? comments; // Eklendi
  final bool isOwnPost; // Eklendi

  Post({
    required this.id,
    required this.userId,
    this.content,
    this.imageUrl,
    this.imageAspectRatio,
    required this.createdAt,
    this.user,
    this.voteCount = 0,
    this.commentCount = 0,
    this.isSaved = false,
    this.userVote = 0,
    this.tags,
    this.likes,
    this.comments,
    this.isOwnPost = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      imageAspectRatio: json['image_aspect_ratio']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      user: json['users'] != null ? PostUser.fromJson(json['users']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isSaved: json['is_saved'] ?? false,
      isOwnPost: json['is_own_post'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'image_aspect_ratio': imageAspectRatio,
      'created_at': createdAt.toIso8601String(),
      'tags': tags,
      'likes': likes,
      'comments': comments,
    };
  }
}

// Yeni sınıf ekleyin
class PostUser {
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String role;

  PostUser({
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.role,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'],
    );
  }
}