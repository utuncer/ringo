class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final String? avatarType;
  final String? avatarGender;
  final String? avatarBgColor;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.avatarType,
    this.avatarGender,
    this.avatarBgColor,
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
    );
  }
}
