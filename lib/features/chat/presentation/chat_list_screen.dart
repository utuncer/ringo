import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_screen.g.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(chatConversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Text(
                'Henüz mesaj yok',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  backgroundImage: conversation['avatar_url'] != null
                      ? NetworkImage(conversation['avatar_url'])
                      : null,
                  child: conversation['avatar_url'] == null
                      ? Text(conversation['full_name'][0].toUpperCase())
                      : null,
                ),
                title: Text(
                  conversation['full_name'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  conversation['last_message'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  context.push(
                    '/chat-room/${conversation['user_id']}',
                    extra: conversation['full_name'],
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/search');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}

@riverpod
Future<List<Map<String, dynamic>>> chatConversations(Ref ref) async {
  final client = Supabase.instance.client;
  final myId = client.auth.currentUser!.id;

  // Fetch unique users I've chatted with.
  // This is a bit hacky without a proper conversations table, but works for prototype.
  // We fetch messages where I am sender or receiver.

  final sentMessages = await client
      .from('messages')
      .select(
        'receiver_id, content, created_at, users:receiver_id(full_name, avatar_url)',
      )
      .eq('sender_id', myId)
      .order('created_at', ascending: false);

  final receivedMessages = await client
      .from('messages')
      .select(
        'sender_id, content, created_at, users:sender_id(full_name, avatar_url)',
      )
      .eq('receiver_id', myId)
      .order('created_at', ascending: false);

  // Combine and deduplicate by user ID
  final Map<String, Map<String, dynamic>> conversationsMap = {};

  for (final msg in sentMessages) {
    final otherId = msg['receiver_id'];
    if (!conversationsMap.containsKey(otherId)) {
      conversationsMap[otherId] = {
        'user_id': otherId,
        'full_name': msg['users']['full_name'],
        'avatar_url': msg['users']['avatar_url'],
        'last_message': msg['content'],
        'created_at': DateTime.parse(msg['created_at']),
      };
    }
  }

  for (final msg in receivedMessages) {
    final otherId = msg['sender_id'];
    // If we already have this user, check if this message is newer
    if (conversationsMap.containsKey(otherId)) {
      final existingTime = conversationsMap[otherId]!['created_at'] as DateTime;
      final newTime = DateTime.parse(msg['created_at']);
      if (newTime.isAfter(existingTime)) {
        conversationsMap[otherId] = {
          'user_id': otherId,
          'full_name': msg['users']['full_name'],
          'avatar_url': msg['users']['avatar_url'],
          'last_message': msg['content'],
          'created_at': newTime,
        };
      }
    } else {
      conversationsMap[otherId] = {
        'user_id': otherId,
        'full_name': msg['users']['full_name'],
        'avatar_url': msg['users']['avatar_url'],
        'last_message': msg['content'],
        'created_at': DateTime.parse(msg['created_at']),
      };
    }
  }

  final sortedList = conversationsMap.values.toList()
    ..sort(
      (a, b) =>
          (b['created_at'] as DateTime).compareTo(a['created_at'] as DateTime),
    );

  return sortedList;
}
