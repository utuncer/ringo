import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../post/data/post_repository.dart';
import '../../post/domain/post.dart';
import '../../post/presentation/post_card.dart';

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

      final postsResponse = await ref.read(postRepositoryProvider).getUserPosts(widget.userId);

      setState(() {
        _userProfile = response;
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
                // Edit profile navigation
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _userProfile!['avatar_url'] != null
                        ? NetworkImage(_userProfile!['avatar_url'])
                        : null,
                    backgroundColor: AppColors.primary,
                    child: _userProfile!['avatar_url'] == null
                        ? Text(
                            _userProfile!['username']?.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          )
                        : null,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_userPosts.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Gönderi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Takipçi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Takip',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
}