class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final String? avatarType;
  final String? avatarGender;
  final String? avatarBgColor;
  final List<String> interests;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.avatarType,
    this.avatarGender,
    this.avatarBgColor,
    this.interests = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'],
      avatarType: json['avatar_type'],
      avatarGender: json['avatar_gender'],
      avatarBgColor: json['avatar_bg_color'],
      interests: (json['user_interests'] as List<dynamic>?)
              ?.map((e) => e['interests']['name'] as String)
              .toList() ??
          [],
    );
  }
}
