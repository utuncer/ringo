import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // EKLENDİ

part 'search_repository.g.dart';

@riverpod
SearchRepository searchRepository(Ref ref) {
  // SearchRepositoryRef -> Ref
  return SearchRepository(Supabase.instance.client);
}

class SearchRepository {
  final SupabaseClient _client;

  SearchRepository(this._client);

  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from('users')
        .select()
        .or('username.ilike.%$query%,full_name.ilike.%$query%')
        .order('username');

    return (response as List).map((e) => UserProfile.fromJson(e)).toList();
  }

  Future<List<UserProfile>> getSavedUsers() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('saved_users')
        .select('saved_user_id, users:saved_user_id(*)')
        .eq('user_id', userId);

    return (response as List)
        .map((e) => UserProfile.fromJson(e['users']))
        .toList();
  }

  Future<void> toggleSaveUser(String savedUserId) async {
    final userId = _client.auth.currentUser!.id;

    // Check if exists
    final exists = await _client
        .from('saved_users')
        .select()
        .eq('user_id', userId)
        .eq('saved_user_id', savedUserId)
        .maybeSingle();

    if (exists != null) {
      await _client
          .from('saved_users')
          .delete()
          .eq('user_id', userId)
          .eq('saved_user_id', savedUserId);
    } else {
      await _client.from('saved_users').insert({
        'user_id': userId,
        'saved_user_id': savedUserId,
      });
    }
  }
}
