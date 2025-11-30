import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // EKLENDİ
import '../domain/user_profile.dart';
import '../../post/domain/post.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  // ProfileRepositoryRef -> Ref
  return ProfileRepository(Supabase.instance.client);
}

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<UserProfile> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(response);
  }

  Future<List<Post>> getUserPosts(String userId) async {
    final response = await _client
        .from('posts')
        .select('*, users(username, full_name, avatar_url, role)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Post.fromJson(e)).toList();
  }

  Future<int> getPostCount(String userId) async {
    final response = await _client
        .from('posts')
        .select('*', const FetchOptions(count: CountOption.exact))
        .eq('user_id', userId);
    return response.count ?? 0;
  }

  // Team specific methods
  Future<List<UserProfile>> getTeamMembers(String teamId) async {
    final response = await _client
        .from('team_members')
        .select('users(*)')
        .eq('team_id', teamId);

    return (response as List)
        .map((e) => UserProfile.fromJson(e['users']))
        .toList();
  }

  Future<void> updateProfile({
    required String userId,
    required String avatarType,
    String? avatarGender,
    String? avatarBgColor,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          'avatar_type': avatarType,
          'avatar_gender': avatarGender,
          'avatar_bg_color': avatarBgColor,
        },
      ),
    );

    await _client
        .from('users')
        .update({
          'avatar_type': avatarType,
          'avatar_gender': avatarGender,
          'avatar_bg_color': avatarBgColor,
        })
        .eq('id', userId);
  }

  Future<void> blockUser(String userId) async {
    final myId = _client.auth.currentUser!.id;
    await _client.from('blocked_users').insert({
      'blocker_id': myId,
      'blocked_id': userId,
    });
  }
}
