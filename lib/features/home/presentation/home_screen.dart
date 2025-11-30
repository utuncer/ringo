import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../../post/data/post_repository.dart';
import '../../post/domain/post.dart';
import '../../post/presentation/post_card.dart';



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceDark,
            child: const TabBar(
              indicatorColor: AppColors.accentHighlight,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Keşfet'),
                Tab(text: 'Alanlar'),
                Tab(text: 'Yıldızlılar'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _FeedList(type: 'discovery'),
                _FeedList(type: 'interests'),
                _FeedList(type: 'saved_users'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedList extends ConsumerWidget {
  final String type;

  const _FeedList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Use specific providers based on type
    // For now, just fetching all posts for all tabs to demonstrate UI
    final postsAsync = ref.watch(postsProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(type),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            // ref.refresh(postsProvider);
            // In riverpod 2.0 we invalidate
            ref.invalidate(postsProvider);
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(
                post: posts[index],
                // onTap parametresini kaldırın, zaten PostCard içinde InkWell var
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Hata: $err', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _getEmptyMessage(String type) {
    switch (type) {
      case 'discovery':
        return 'Henüz gönderi paylaşılmamış';
      case 'interests':
        return 'İlgi alanlarınıza ait gönderi bulunamadı';
      case 'saved_users':
        return 'Henüz yıldızlı hesap yok';
      default:
        return 'Gönderi yok';
    }
  }
}


