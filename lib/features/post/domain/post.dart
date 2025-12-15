class Post {
  final String id;
  final String userId;
  final String? content;
  final String? imageUrl;
  final double? imageAspectRatio;
  final DateTime createdAt;
  final PostUser? user;
  final int voteCount;
  final int commentCount;
  final bool isSaved;
  final int userVote;
  final List<String>? tags;
  final int? likes;
  final int? comments;
  final bool isOwnPost;

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
    // Handle tags from relation: post_tags -> interests -> name
    List<String>? tags;
    if (json['post_tags'] != null) {
      tags = (json['post_tags'] as List)
          .map((e) => e['interests']?['name'] as String?)
          .where((e) => e != null)
          .cast<String>()
          .toList();
    } else if (json['tags'] != null) {
      tags = List<String>.from(json['tags']);
    }

    // Handle user_vote if available (passed manually or from join)
    int userVote = 0;
    if (json['user_vote'] != null) {
        userVote = json['user_vote'] as int;
    } else if (json['my_vote'] != null && (json['my_vote'] as List).isNotEmpty) {
      userVote = json['my_vote'][0]['value'] ?? 0;
    }

    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      imageAspectRatio: json['image_aspect_ratio']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      user: json['users'] != null ? PostUser.fromJson(json['users']) : null,
      tags: tags,
      likes: json['likes'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      comments: json['comments'] ?? 0,
      isSaved: json['is_saved'] ?? false,
      isOwnPost: json['is_own_post'] ?? false,
      userVote: userVote,
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

class PostUser {
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? avatarGender;
  final String? avatarBgColor;
  final String role;

  PostUser({
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.avatarGender,
    this.avatarBgColor,
    required this.role,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      avatarGender: json['avatar_gender'],
      avatarBgColor: json['avatar_bg_color'],
      role: json['role'],
    );
  }
}