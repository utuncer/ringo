import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/post.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback? onDelete;
  final VoidCallback? onSave;
  final bool showActions;

  const PostCard({
    super.key,
    required this.post,
    this.onDelete,
    this.onSave,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/post-detail', extra: post),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım: kullanıcı bilgileri ve menü
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profil fotoğrafı
                  CircleAvatar(
                    backgroundImage: post.user?.avatarUrl != null
                        ? NetworkImage(post.user!.avatarUrl!)
                        : null,
                    backgroundColor: AppColors.primary,
                    child: post.user?.avatarUrl == null
                        ? Text(
                            post.user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Kullanıcı adı, rol ve zaman damgası
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.user?.username ?? 'user',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Rol rozeti
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(post.user?.role),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getRoleText(post.user?.role),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(post.createdAt),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 3 noktalı menü
                  if (showActions)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: AppColors.surfaceDark,
                      onSelected: (value) {
                        if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        } else if (value == 'save' && onSave != null) {
                          onSave!();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(Icons.bookmark, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Kaydet'),
                            ],
                          ),
                        ),
                        if (post.isOwnPost) // Sadece kendi gönderisini silebilir
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Sil'),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // Görsel varsa
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: AppColors.surfaceDark,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: AppColors.surfaceDark,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                ),
              ),

            // İçerik ve etiketler
            if (post.content != null && post.content!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.content!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    // Etiketler
                    if (post.tags != null && post.tags!.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _buildTags(post.tags!),
                      ),
                  ],
                ),
              ),

            // Alt kısım: etkileşim butonları
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tarih, oy ve yorum
                  Flexible(
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likes ?? 0}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.comment, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${post.comments ?? 0}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Kaydet butonu
                  if (showActions)
                    IconButton(
                      icon: Icon(
                        post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: post.isSaved ? AppColors.accentHighlight : Colors.grey[400],
                      ),
                      onPressed: onSave,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Etiketleri oluşturan yardımcı metot
  List<Widget> _buildTags(List<String> tags) {
    const maxVisibleTags = 3;
    final visibleTags = tags.take(maxVisibleTags).toList();
    final remainingCount = tags.length - maxVisibleTags;

    return [
      ...visibleTags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          )).toList(),
      if (remainingCount > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentHighlight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '+$remainingCount',
            style: const TextStyle(
              color: AppColors.accentHighlight,
              fontSize: 12,
            ),
          ),
        ),
    ];
  }

  // Role göre renk döndüren yardımcı metot
  Color _getRoleColor(String? role) {
    switch (role) {
      case 'team':
        return AppColors.roleTeam;
      case 'instructor':
      case 'competitor':
        return AppColors.roleInstructorCompetitor;
      default:
        return AppColors.roleInterests;
    }
  }

  // Role göre metin döndüren yardımcı metot
  String _getRoleText(String? role) {
    switch (role) {
      case 'team':
        return 'Takım';
      case 'instructor':
        return 'Eğitmen';
      case 'competitor':
        return 'Yarışmacı';
      default:
        return 'Kullanıcı';
    }
  }

  // Tarihi formatlayan yardımcı metot
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}