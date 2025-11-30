import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ShellRoute içinde kullanılacak - Scaffold YOK
class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Kaydedilen gönderiler burada gösterilecek',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

// Bağımsız route - Kendi Scaffold'u var
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

// Bağımsız route - Kendi Scaffold'u var
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
