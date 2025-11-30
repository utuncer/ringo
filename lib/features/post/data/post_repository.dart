import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/post.dart';
import '../domain/comment.dart';

part 'post_repository.g.dart';

@riverpod
PostRepository postRepository(Ref ref) {
  return PostRepository(Supabase.instance.client);
}

class PostRepository {
  final SupabaseClient _client;

  PostRepository(this._client);

  Future<List<Post>> getPosts() async {
    final userId = _client.auth.currentUser?.id;

    final response = await _client
        .from('posts')
        .select('*, users!posts_user_id_fkey(username, full_name, avatar_url, role), post_tags(interests(name))')
        .order('created_at', ascending: false);

    final posts = (response as List).map((e) => Post.fromJson(e)).toList();

    return _attachUserVotes(posts, userId);
  }

  Future<List<Post>> getUserPosts(String userId) async {
    final currentUserId = _client.auth.currentUser?.id;

    final response = await _client
        .from('posts')
        .select('*, users!posts_user_id_fkey(username, full_name, avatar_url, role), post_tags(interests(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final posts = (response as List).map((e) => Post.fromJson(e)).toList();

    return _attachUserVotes(posts, currentUserId);
  }

  Future<List<Post>> _attachUserVotes(List<Post> posts, String? userId) async {
    if (userId == null || posts.isEmpty) return posts;

    final postIds = posts.map((e) => e.id).toList();
    
    // Fetch user votes for these posts
    final votesResponse = await _client
        .from('votes')
        .select('post_id, value')
        .eq('user_id', userId)
        .in_('post_id', postIds);
    
    final votesMap = {
        for (var v in (votesResponse as List)) v['post_id'] as String: v['value'] as int
    };

    // Recreate posts with userVote
    return posts.map((p) {
        final vote = votesMap[p.id];
        if (vote != null) {
             return Post(
                id: p.id,
                userId: p.userId,
                content: p.content,
                imageUrl: p.imageUrl,
                imageAspectRatio: p.imageAspectRatio,
                createdAt: p.createdAt,
                user: p.user,
                voteCount: p.voteCount,
                commentCount: p.commentCount,
                isSaved: p.isSaved,
                userVote: vote,
                tags: p.tags,
                likes: p.likes,
                comments: p.comments,
                isOwnPost: p.isOwnPost,
            );
        }
        return p;
    }).toList();
  }

  Future<void> votePost(String postId, int value) async {
    final userId = _client.auth.currentUser!.id;
    if (value == 0) {
        // Remove vote
        await _client.from('votes').delete().match({'user_id': userId, 'post_id': postId});
    } else {
        // Upsert vote
        await _client.from('votes').upsert({
            'user_id': userId,
            'post_id': postId,
            'value': value,
        });
    }
  }

  Future<void> createPost({
    String? content,
    File? imageFile,
    required List<String> tags,
  }) async {
    final userId = _client.auth.currentUser!.id;
    String? imageUrl;
    double? aspectRatio;

    if (imageFile != null) {
      final fileName = '${DateTime.now().toIso8601String()}_$userId.jpg';
      try {
        await _client.storage.from('post_images').upload(fileName, imageFile);
        imageUrl = _client.storage.from('post_images').getPublicUrl(fileName);
        aspectRatio = 16 / 9;
      } catch (e) {
        throw Exception('Resim yüklenemedi: ${e.toString()}');
      }
    }

    await _ensureUserExists();

    final postResponse = await _client.from('posts').insert({
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'image_aspect_ratio': aspectRatio,
    }).select().single();
    
    final postId = postResponse['id'];

    // Insert tags
    if (tags.isNotEmpty) {
        // First get interest IDs
        final interestsResponse = await _client
            .from('interests')
            .select('id, name')
            .in_('name', tags);
        
        final interestMap = {
            for (var i in (interestsResponse as List)) i['name'] as String: i['id'] as int
        };

        final postTags = tags.map((tag) {
            final interestId = interestMap[tag];
            if (interestId != null) {
                return {'post_id': postId, 'interest_id': interestId};
            }
            return null;
        }).where((e) => e != null).toList();

        if (postTags.isNotEmpty) {
            await _client.from('post_tags').insert(postTags);
        }
    }
  }

  Future<void> _ensureUserExists() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final data =
          await _client.from('users').select('id').eq('id', user.id).maybeSingle();

      if (data == null) {
        await _client.from('users').insert({
          'id': user.id,
          'email': user.email!,
          'full_name': user.userMetadata?['full_name'] ?? '',
          'username': user.userMetadata?['username'] ??
              'user_${user.id.substring(0, 8)}',
          'role': user.userMetadata?['role'] ?? 'competitor',
          'avatar_url': user.userMetadata?['avatar_url'],
          'avatar_type': user.userMetadata?['avatar_type'] ?? 'preset',
          'avatar_gender': user.userMetadata?['avatar_gender'],
          'avatar_bg_color': user.userMetadata?['avatar_bg_color'],
        });
      }
    } catch (e) {
      print('Error ensuring user exists: $e');
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    final response = await _client
        .from('comments')
        .select('*, users(username, full_name, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Comment.fromJson(e)).toList();
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('comments').insert({
      'user_id': userId,
      'post_id': postId,
      'content': content,
    });
  }

  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }
}

@riverpod
Future<List<Post>> posts(Ref ref) async {
  return ref.read(postRepositoryProvider).getPosts();
}