import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../data/search_repository.dart';
import '../../profile/domain/user_profile.dart';

part 'search_screen.g.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      // Debounce could be added here
                      setState(() => _query = val);
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı veya Takım Ara...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/saved-users');
                    },
                    icon: const Icon(
                      Icons.star,
                      color: AppColors.accentHighlight,
                    ),
                    label: const Text('Yıldızlı Hesaplar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      foregroundColor: Colors.white,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: _query.isEmpty
                  ? const Center(
                      child: Text(
                        'Arama yapmak için yazmaya başlayın',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : searchResultsAsync.when(
                      data: (users) {
                        if (users.isEmpty) {
                          return const Center(
                            child: Text(
                              '🔍 Kullanıcı bulunamadı',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return _UserListItem(user: users[index]);
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Hata: $err')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserProfile user;

  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
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
      title: Text(user.fullName, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        '@${user.username}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Navigate to profile
        context.push('/profile/${user.id}');
      },
    );
  }
}

@riverpod
Future<List<UserProfile>> searchResults(Ref ref, String query) async {
  return ref.read(searchRepositoryProvider).searchUsers(query);
}
