import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../data/search_repository.dart';
import '../../profile/domain/user_profile.dart';

part 'saved_users_screen.g.dart';

class SavedUsersScreen extends ConsumerWidget {
  const SavedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedUsersAsync = ref.watch(savedUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yıldızlı Hesaplar'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: savedUsersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text(
                '⭐ Henüz yıldızlı hesap yok',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  backgroundColor: AppColors.primary,
                  child: user.avatarUrl == null
                      ? Text(user.fullName[0].toUpperCase())
                      : null,
                ),
                title: Text(
                  user.fullName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '@${user.username}',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.star,
                    color: AppColors.accentHighlight,
                  ),
                  onPressed: () async {
                    await ref
                        .read(searchRepositoryProvider)
                        .toggleSaveUser(user.id);
                    ref.invalidate(savedUsersProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}

@riverpod
Future<List<UserProfile>> savedUsers(Ref ref) async {
  return ref.read(searchRepositoryProvider).getSavedUsers();
}
