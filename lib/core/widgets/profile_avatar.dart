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
    final bgColor = backgroundColor ?? AppColors.primary;

    // 1. Check for Network URL (Custom Uploads)
    if (avatarUrl != null && avatarUrl!.startsWith('http')) {
      imageProvider = NetworkImage(avatarUrl!);
      // Custom uploads fill the circle
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: imageProvider,
        child: null,
      );
    }

    // 2. Check for Preset Team Logos or Gender Presets
    else {
      if (avatarUrl != null && avatarUrl!.startsWith('team_logo')) {
        imageProvider = AssetImage('assets/images/$avatarUrl.png');
      } else if (avatarGender == 'male') {
        imageProvider = const AssetImage('assets/images/icon_m.png');
      } else if (avatarGender == 'female') {
        imageProvider = const AssetImage('assets/images/icon_w.png');
      }

      if (imageProvider != null) {
        // Presets are rendered as children (75% of diameter) to show background color
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          backgroundImage: null,
          child: Image(
            image: imageProvider,
            width: radius * 1.5, // 75% of diameter (radius * 2 * 0.75)
            height: radius * 1.5,
            fit: BoxFit.contain,
          ),
        );
      }
    }

    // 3. Fallback
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: _buildFallbackChild(),
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
