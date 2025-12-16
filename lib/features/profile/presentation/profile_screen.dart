import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../post/data/post_repository.dart';
import '../../post/domain/post.dart';
import '../../post/presentation/post_card.dart';
import '../domain/user_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  List<Post> _userPosts = [];
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('*, user_interests(interests(name))')
          .eq('id', widget.userId)
          .single();

      final postsResponse =
          await ref.read(postRepositoryProvider).getUserPosts(widget.userId);

      // If team, fetch members
      List<Map<String, dynamic>> teamMembers = [];
      if (response['role'] == 'team') {
        final membersResponse = await Supabase.instance.client
            .from('team_members')
            .select('users(*)')
            .eq('team_id', widget.userId);

        teamMembers = List<Map<String, dynamic>>.from(
            membersResponse.map((e) => e['users']));
      }

      setState(() {
        _userProfile = response;
        _teamMembers = teamMembers;
        _userPosts = postsResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil yüklenemedi: ${e.toString()}'),
            backgroundColor: AppColors.actionError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Profil bulunamadı')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userProfile!['username'] ?? 'Profil'),
        actions: [
          if (widget.userId == Supabase.instance.client.auth.currentUser?.id)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final userProfile = UserProfile.fromJson(_userProfile!);
                context.push('/edit-profile', extra: userProfile);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceDark,
              child: Column(
                children: [
                  ProfileAvatar(
                    radius: 50,
                    avatarUrl: _userProfile!['avatar_url'],
                    avatarGender: _userProfile!['avatar_gender'],
                    backgroundColor: _userProfile!['avatar_bg_color'] != null
                        ? AppColors.parseColor(_userProfile!['avatar_bg_color'])
                        : null,
                    username: _userProfile!['username'],
                    fontSize: 24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userProfile!['full_name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${_userProfile!['username'] ?? ''}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRoleColor(_userProfile!['role']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getRoleText(_userProfile!['role']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInterestTags(),
            const SizedBox(height: 16),
            if (_userProfile!['role'] == 'team' && _teamMembers.isNotEmpty)
              _buildTeamMembersSections(),
            if (_userPosts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Henüz gönderi yok',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userPosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: _userPosts[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMembersSections() {
    final instructors =
        _teamMembers.where((m) => m['role'] == 'instructor').toList();
    final competitors =
        _teamMembers.where((m) => m['role'] == 'competitor').toList();

    return Column(
      children: [
        if (instructors.isNotEmpty)
          _buildMemberSection('Eğitmenler', instructors),
        if (competitors.isNotEmpty)
          _buildMemberSection('Yarışmacılar', competitors),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMemberSection(String title, List<Map<String, dynamic>> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: members.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final member = members[index];
              return Column(
                children: [
                  ProfileAvatar(
                    radius: 30,
                    avatarUrl: member['avatar_url'],
                    avatarGender: member[
                        'avatar_gender'], // Assuming we select this in team query
                    backgroundColor: member['avatar_bg_color'] != null
                        ? AppColors.parseColor(member['avatar_bg_color'])
                        : null,
                    username: member['username'],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member['full_name'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'team':
        return AppColors.roleTeam;
      case 'instructor':
      case 'competitor':
        return AppColors.roleInstructorCompetitor;
      default:
        return AppColors.roleInterests;
    }
  }

  String _getRoleText(String? role) {
    switch (role) {
      case 'team':
        return 'Takım';
      case 'instructor':
        return 'Eğitmen';
      case 'competitor':
        return 'Yarışmacı';
      default:
        return 'Kullanıcı';
    }
  }

  Widget _buildInterestTags() {
    final interestsData = _userProfile!['user_interests'] as List<dynamic>?;

    if (interestsData == null || interestsData.isEmpty) {
      return const SizedBox.shrink();
    }

    final interests = interestsData.map((item) {
      final interest = item['interests'] as Map<String, dynamic>;
      return interest['name'] as String;
    }).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: interests.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: Text(
            interest,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }
}
