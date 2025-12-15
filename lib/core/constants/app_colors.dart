import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF006BA6);
  static const Color actionError = Color(0xFFDA291C);
  static const Color accentHighlight = Color(0xFFFFB81C);
  static const Color surfaceDark = Color(0xFF333F48);

  static const Color background = Color(0xFF1E1E1E);
  // static const Color background = Color(0xFF121212); // Standard dark background

  static const Color surface = Color(0xFF1E1E1E); // Slightly lighter surface
  static const Color surfaceLight =
      Color(0xFF455A64); // Lighter surface for tags

  // Role Badges
  static const Color roleTeam = Color(0xFFDA291C);
  static const Color roleInstructorCompetitor = Color(0xFF006BA6);
  static const Color roleInterests = Color(0xFFFFB81C);

  // Avatar Backgrounds
  static const List<Color> avatarBackgrounds = [
    Color(0xFFDA291C),
    Color(0xFF006BA6),
    Color(0xFFFFB81C),
  ];

  static Color parseColor(String colorString) {
    try {
      final buffer = StringBuffer();
      if (colorString.length == 6 || colorString.length == 7) buffer.write('ff');
      buffer.write(colorString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return primary;
    }
  }
}
