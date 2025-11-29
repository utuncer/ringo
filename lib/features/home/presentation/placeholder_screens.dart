import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaydedilenler')),
      body: const Center(
        child: Text('Kaydedilen gönderiler burada gösterilecek'),
      ),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbetler')),
      body: const Center(child: Text('Sohbet listesi burada gösterilecek')),
    );
  }
}

class EditInterestsScreen extends StatelessWidget {
  const EditInterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlgi Alanları Düzenle'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: const Center(
        child: Text(
          'İlgi alanları düzenleme ekranı yakında...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: const Center(
        child: Text(
          'Ayarlar ekranı yakında...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
