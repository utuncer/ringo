import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../domain/post.dart';
import '../data/post_repository.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback? onDelete;
  final VoidCallback? onSave;
  final VoidCallback? onTap;
  final bool showActions;
  final bool isDetail;

  const PostCard({
    super.key,
    required this.post,
    this.onDelete,
    this.onSave,
    this.onTap,
    this.showActions = true,
    this.isDetail = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: isDetail
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceDark,
      shape: isDetail
          ? null
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ??
            (isDetail ? null : () => context.push('/post-detail', extra: post)),
        borderRadius: isDetail ? null : BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Image
            if (post.imageUrl != null) _buildImage(context),

            // Content
            if (post.content != null && post.content!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  post.content!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),

            // Tags (Interests) - Moved after content
            if (post.tags != null && post.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _buildTags(post.tags!),
                ),
              ),

            const SizedBox(height: 12),

            // Footer (Voting & Actions)
            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Profil fotoğrafı
          ProfileAvatar(
            avatarUrl: post.user?.avatarUrl,
            avatarGender: post.user?.avatarGender,
            backgroundColor: post.user?.avatarBgColor != null
                ? AppColors.parseColor(post.user!.avatarBgColor!)
                : null,
            username: post.user?.username,
            radius: 20,
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
                } else if (value == 'report') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bildirildi.')),
                  );
                  // TODO: Call backend API to report this post
                  // ref.read(postRepositoryProvider).reportPost(post.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.bookmark, color: Colors.white),
                      SizedBox(width: 8),
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
                        SizedBox(width: 8),
                        Text('Sil'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Şikayet Et'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: isDetail
          ? BorderRadius.zero
          : const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: post.imageUrl!,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 300,
          color: AppColors.surfaceDark,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 300,
          color: AppColors.surfaceDark,
          child: const Center(
            child: Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Voting System
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: post.userVote == 1 ? AppColors.primary : Colors.grey,
                  ),
                  onPressed: () {
                    final newVote = post.userVote == 1 ? 0 : 1;
                    ref.read(postRepositoryProvider).votePost(post.id, newVote);
                    ref.invalidate(postsProvider);
                  },
                  constraints: const BoxConstraints(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                Text(
                  '${post.voteCount + (post.userVote)}', // Simple logic
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    color: post.userVote == -1
                        ? AppColors.actionError
                        : Colors.grey,
                  ),
                  onPressed: () {
                    final newVote = post.userVote == -1 ? 0 : -1;
                    ref.read(postRepositoryProvider).votePost(post.id, newVote);
                    ref.invalidate(postsProvider);
                  },
                  constraints: const BoxConstraints(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
          ),

          // Comments
          Row(
            children: [
              const Icon(Icons.comment, color: Colors.grey, size: 20),
              const SizedBox(width: 6),
              Text(
                '${post.commentCount}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          // Save
          if (showActions)
            IconButton(
              icon: Icon(
                post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: post.isSaved ? AppColors.accentHighlight : Colors.grey,
              ),
              onPressed: onSave,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildTags(List<String> tags) {
    final maxVisibleTags = isDetail ? tags.length : 3;
    final visibleTags = tags.take(maxVisibleTags).toList();
    final remainingCount = tags.length - maxVisibleTags;

    return [
      ...visibleTags
          .map((tag) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
      if (remainingCount > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.accentHighlight.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.accentHighlight.withOpacity(0.3)),
          ),
          child: Text(
            '+$remainingCount',
            style: const TextStyle(
              color: AppColors.accentHighlight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    ];
  }

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
