import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../data/post_repository.dart';
import '../domain/post.dart';
import '../domain/comment.dart';
import 'post_card.dart';

part 'post_detail_screen.g.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    if (content.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum en az 50 karakter olmalı.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await ref
          .read(postRepositoryProvider)
          .addComment(postId: widget.post.id, content: content);
      _commentController.clear();
      ref.invalidate(commentsProvider(widget.post.id));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yorum gönderilemedi: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderi Detayı'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(
                    post: widget.post,
                  ), // Reuse PostCard but maybe disable tap
                  const Divider(color: Colors.grey),
                  commentsAsync.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Henüz yorum yok. İlk yorumu sen yap!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildCommentItem(comment);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Hata: $err')),
                  ),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final dateFormat = DateFormat('dd.MM.yyyy | HH:mm');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: comment.userAvatarUrl != null
                ? CachedNetworkImageProvider(comment.userAvatarUrl!)
                : null,
            backgroundColor: AppColors.primary,
            radius: 16,
            child: comment.userAvatarUrl == null
                ? Text(
                    comment.fullName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      dateFormat.format(comment.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                Text(
                  '@${comment.username}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceDark,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Yorum yaz... (min 50 karakter)',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: AppColors.primary),
            onPressed: _isSending ? null : _sendComment,
          ),
        ],
      ),
    );
  }
}

@riverpod
Future<List<Comment>> comments(Ref ref, String postId) async {
  return ref.read(postRepositoryProvider).getComments(postId);
}
