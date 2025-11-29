import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // EKLENDİ
import '../domain/notification.dart';

part 'notification_repository.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  // NotificationRepositoryRef -> Ref
  return NotificationRepository(Supabase.instance.client);
}

class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository(this._client);

  Stream<List<AppNotification>> getNotifications() {
    final myId = _client.auth.currentUser!.id;
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', myId)
        .order('created_at')
        .map((maps) => maps.map((e) => AppNotification.fromJson(e)).toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> acceptInvitation(String notificationId, String teamId) async {
    final myId = _client.auth.currentUser!.id;

    // Add to team members
    await _client.from('team_members').insert({
      'team_id': teamId,
      'user_id': myId,
      'role': 'member',
    });

    // Update invitation status
    await _client
        .from('invitations')
        .update({'status': 'accepted'})
        .eq('team_id', teamId)
        .eq('user_id', myId);

    // Delete notification or mark as handled
    await _client.from('notifications').delete().eq('id', notificationId);
  }

  Future<void> rejectInvitation(String notificationId, String teamId) async {
    final myId = _client.auth.currentUser!.id;

    // Update invitation status
    await _client
        .from('invitations')
        .update({'status': 'rejected'})
        .eq('team_id', teamId)
        .eq('user_id', myId);

    // Delete notification
    await _client.from('notifications').delete().eq('id', notificationId);
  }
}
