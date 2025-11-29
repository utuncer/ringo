import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/profile_screen.dart';
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
                const Center(
                  child: Text(
                    'Takım Sohbeti (Yakında)',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
