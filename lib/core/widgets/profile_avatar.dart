import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? avatarGender;
  final Color? backgroundColor;
  final String? username;
  final double radius;
  final double? fontSize;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.avatarGender,
    this.backgroundColor,
    this.username,
    this.radius = 20,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    Widget? child;

    // 1. Check for Network URL (Custom Uploads)
    if (avatarUrl != null && avatarUrl!.startsWith('http')) {
      imageProvider = NetworkImage(avatarUrl!);
    } 
    // 2. Check for Preset Team Logos (Stored as 'team_logo_X' in avatarUrl)
    else if (avatarUrl != null && avatarUrl!.startsWith('team_logo')) {
      // Assuming assets are at assets/images/team_logo_X.png
      imageProvider = AssetImage('assets/images/$avatarUrl.png');
    }
    // 3. Check for Gender-based Preset (If no specific URL/Logo is set)
    else {
      if (avatarGender == 'male') {
        imageProvider = const AssetImage('assets/images/icon_m.png');
      } else if (avatarGender == 'female') {
        imageProvider = const AssetImage('assets/images/icon_w.png');
      } else {
        // Fallback: Initials or Icon
         child = _buildFallbackChild();
      }
    }

    // Helper to extract background color from string if needed, 
    // but we expect Color object passed from parent who parses it.
    final bgColor = backgroundColor ?? AppColors.primary;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: imageProvider,
      child: imageProvider == null ? child : null,
    );
  }

  Widget _buildFallbackChild() {
    if (username != null && username!.isNotEmpty) {
      return Text(
        username!.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? radius,
        ),
      );
    }
    return Icon(Icons.person, color: Colors.white, size: radius * 1.2);
  }
}
