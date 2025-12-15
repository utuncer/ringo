import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/domain/message.dart';
import '../data/team_repository.dart';

part 'team_dashboard_screen.g.dart';

class TeamDashboardScreen extends ConsumerStatefulWidget {
  const TeamDashboardScreen({super.key});

  @override
  ConsumerState<TeamDashboardScreen> createState() =>
      _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends ConsumerState<TeamDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final myTeamIdAsync = ref.watch(myTeamIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takımım'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: myTeamIdAsync.when(
        data: (teamId) {
          if (teamId == null) {
            return const Center(
              child: Text(
                'Henüz bir takımda değilsiniz',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return _TeamContent(teamId: teamId);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}

class _TeamContent extends ConsumerWidget {
  final String teamId;

  const _TeamContent({required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceDark,
            child: const TabBar(
              indicatorColor: AppColors.accentHighlight,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Profil Yönetimi'),
                Tab(text: 'Takım Sohbeti'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TeamManagement(teamId: teamId),
                _TeamChat(teamId: teamId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamManagement extends ConsumerWidget {
  final String teamId;

  const _TeamManagement({required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(teamMembersProvider(teamId));

    return membersAsync.when(
      data: (members) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Takım Üyeleri',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...members.map(
              (member) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(member.fullName[0].toUpperCase()),
                ),
                title: Text(
                  member.fullName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  member.role,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.actionError,
                  ),
                  onPressed: () {
                    // Remove member logic (check permissions first)
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () async {
                await ref.read(teamRepositoryProvider).leaveTeam(teamId);
                ref.invalidate(myTeamIdProvider);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.actionError,
                side: const BorderSide(color: AppColors.actionError),
              ),
              child: const Text('Takımdan Ayrıl'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: $err')),
    );
  }
}

@riverpod
Future<String?> myTeamId(Ref ref) async {
  return ref.read(teamRepositoryProvider).getMyTeamId();
}

final teamChatMessagesProvider = StreamProvider.family<List<Message>, String>((ref, teamId) {
  return ref.read(chatRepositoryProvider).getTeamMessages(teamId);
});

class _TeamChat extends ConsumerStatefulWidget {
  final String teamId;

  const _TeamChat({required this.teamId});

  @override
  ConsumerState<_TeamChat> createState() => _TeamChatState();
}

class _TeamChatState extends ConsumerState<_TeamChat> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatRepositoryProvider).sendMessage(
          content: content,
          teamId: widget.teamId,
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(teamChatMessagesProvider(widget.teamId));

    return Column(
      children: [
        Expanded(
          child: messagesStream.when(
            data: (messages) {
              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    'Henüz takım mesajı yok',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  final isMe = message.senderId ==
                      ref.read(chatRepositoryProvider).client.auth.currentUser?.id;
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            Text(
                              message.senderName ?? 'Üye',
                              style: TextStyle(
                                color: AppColors.accentHighlight,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            message.content,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Hata: $err')),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceDark,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Takıma yaz...',
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
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
