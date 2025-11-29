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
    final response = await _client
        .from('posts')
        // 'users' yerine 'users!posts_user_id_fkey' kullanarak doğru ilişkiyi belirtiyoruz
        .select('*, users!posts_user_id_fkey(username, full_name, avatar_url, role)')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Post.fromJson(e)).toList();
  }

  // Belirli bir kullanıcının gönderilerini getiren yeni metot
  Future<List<Post>> getUserPosts(String userId) async {
    final response = await _client
        .from('posts')
        .select('*, users!posts_user_id_fkey(username, full_name, avatar_url, role)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Post.fromJson(e)).toList();
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
        // HATA: Resim yüklenemediğinde işlemi durdur ve hatayı yukarı fırlat.
        // Bu sayede UI katmanı hatayı yakalayıp kullanıcıya gösterebilir.
        throw Exception('Resim yüklenemedi: ${e.toString()}');
      }
    }

    await _client.from('posts').insert({
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'image_aspect_ratio': aspectRatio,
    });
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