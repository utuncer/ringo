import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/user_profile.dart';

part 'team_repository.g.dart';

@riverpod
TeamRepository teamRepository(Ref ref) {
  // TeamRepositoryRef -> Ref
  return TeamRepository(Supabase.instance.client);
}



@riverpod
Future<List<UserProfile>> teamMembers(Ref ref, String teamId) {
  return ref.read(teamRepositoryProvider).getMembers(teamId);
}

class TeamRepository {
  final SupabaseClient _client;

  TeamRepository(this._client);

  Future<String?> getMyTeamId() async {
    final userId = _client.auth.currentUser!.id;

    // Check if I am a team account
    final user = await _client
        .from('users')
        .select('role')
        .eq('id', userId)
        .single();
    if (user['role'] == 'team') return userId;

    // Check if I am a member of a team
    final membership = await _client
        .from('team_members')
        .select('team_id')
        .eq('user_id', userId)
        .maybeSingle();

    return membership?['team_id'];
  }

  Future<List<UserProfile>> getMembers(String teamId) async {
    final response = await _client
        .from('team_members')
        .select('users(*)')
        .eq('team_id', teamId);

    return (response as List)
        .map((e) => UserProfile.fromJson(e['users']))
        .toList();
  }

  Future<void> leaveTeam(String teamId) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('team_members')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', userId);
  }

  Future<void> removeMember(String teamId, String userId) async {
    await _client
        .from('team_members')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', userId);
  }

  Future<void> inviteUser(String teamId, String userId) async {
    // Check if pending invite exists
    final existing = await _client
        .from('invitations')
        .select()
        .eq('team_id', teamId)
        .eq('user_id', userId)
        .eq('status', 'pending')
        .maybeSingle();

    if (existing != null) throw Exception('Zaten davet edildi');

    await _client.from('invitations').insert({
      'team_id': teamId,
      'user_id': userId,
    });
  }
}
