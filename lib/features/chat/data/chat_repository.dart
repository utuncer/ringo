import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // EKLENDİ
import '../domain/message.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  // ChatRepositoryRef -> Ref
  return ChatRepository(Supabase.instance.client);
}

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository(this._client);

  Stream<List<Message>> getMessages(String otherUserId) {
    final myId = _client.auth.currentUser!.id;

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) {
          return maps.map((e) => Message.fromJson(e)).where((msg) {
            // Filter logic if needed, but RLS should handle most.
            // Also need to filter deleted messages for me?
            // "deleted_by" array check.
            return !msg.deletedBy.contains(myId);
          }).toList();
        });
  }

  Future<void> sendMessage({
    required String content,
    String? receiverId,
    String? teamId,
  }) async {
    final myId = _client.auth.currentUser!.id;
    await _client.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'team_id': teamId,
      'content': content,
    });
  }

  Future<void> deleteMessage(String messageId) async {
    final myId = _client.auth.currentUser!.id;
    // Append myId to deleted_by array
    // Supabase doesn't support array_append easily via basic update, might need RPC or raw SQL or fetch-update.
    // For now, let's fetch, append, update.
    final msg = await _client
        .from('messages')
        .select('deleted_by')
        .eq('id', messageId)
        .single();
    List<dynamic> deletedBy = List.from(msg['deleted_by'] ?? []);
    if (!deletedBy.contains(myId)) {
      deletedBy.add(myId);
      await _client
          .from('messages')
          .update({'deleted_by': deletedBy})
          .eq('id', messageId);
    }
  }
}
