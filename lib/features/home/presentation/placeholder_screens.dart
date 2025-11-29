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



class EditInterestsScreen extends StatelessWidget {
  const EditInterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlgi Alanlarını Düzenle')),
      body: const Center(
        child: Text('İlgi Alanları Düzenleme Ekranı - Yakında'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: const Center(
        child: Text('Ayarlar Ekranı - Yakında'),
      ),
    );
  }
}
