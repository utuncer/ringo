// lib/core/widgets/scaffold_with_navbar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../../features/auth/data/auth_repository.dart';

class ScaffoldWithNavbar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavbar({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // currentUser'ı authStateChangesProvider'dan alarak daha reaktif hale getiriyoruz.
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            // --- DEĞİŞİKLİK 1: Profil Fotoğrafını Göster ---
            icon: CircleAvatar(
              // Eğer kullanıcı metadata'sında avatar_url varsa onu göster,
              // yoksa varsayılan bir ikon göster.
              backgroundImage:
                  (currentUser?.userMetadata?['avatar_url'] != null &&
                          currentUser!.userMetadata!['avatar_url']!.isNotEmpty)
                      ? NetworkImage(currentUser.userMetadata!['avatar_url']!)
                      : null,
              backgroundColor: Colors.grey[600], // Varsayılan arka plan rengi
              child: (currentUser?.userMetadata?['avatar_url'] == null ||
                      currentUser!.userMetadata!['avatar_url']!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            // Kullanıcı giriş yapmışsa kendi profil sayfasına yönlendir
            if (currentUser != null) {
              context.push('/profile/${currentUser.id}');
            }
          },
          child: const Text('Ringo'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.surfaceDark),
              accountName: Text(
                currentUser?.userMetadata?['full_name'] ?? 'Kullanıcı Adı',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                  '@${currentUser?.userMetadata?['username'] ?? 'username'}'),
              currentAccountPicture: CircleAvatar(
                // Burada da aynı mantığı uygulayabiliriz
                backgroundImage: (currentUser?.userMetadata?['avatar_url'] !=
                            null &&
                        currentUser!.userMetadata!['avatar_url']!.isNotEmpty)
                    ? NetworkImage(currentUser.userMetadata!['avatar_url']!)
                    : null,
                backgroundColor: AppColors.primary,
                child: (currentUser?.userMetadata?['avatar_url'] == null ||
                        currentUser!.userMetadata!['avatar_url']!.isEmpty)
                    ? Text(
                        (currentUser?.email?.substring(0, 1).toUpperCase() ??
                            'U'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title:
                  const Text('Profilim', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                if (currentUser != null) {
                  context.push('/profile/${currentUser.id}');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.white),
              title: const Text('İlgi Alanları Düzenle',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                context.push('/edit-interests');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.white),
              title:
                  const Text('Takımım', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                context.push('/team-dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title:
                  const Text('Ayarlar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                context.push('/settings');
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.actionError),
              title: const Text('Çıkış Yap',
                  style: TextStyle(color: AppColors.actionError)),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
        ),
      ),
      body: child,
      // --- DEĞİŞİKLİK 2: FAB Kontrolünü Basitleştir ---
      floatingActionButton: _shouldShowFab(context)
          ? FloatingActionButton(
              onPressed: () {
                context.push('/create-post');
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }

  // --- DEĞİŞİKLİK 3: Sadece /home'da FAB göster ---
  bool _shouldShowFab(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    return location == '/home';
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/saved')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/chat');
        break;
      case 3:
        context.go('/saved');
        break;
    }
  }
}
