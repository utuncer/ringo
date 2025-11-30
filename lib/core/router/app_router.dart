import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/post/presentation/create_post_screen.dart';
import '../../features/post/presentation/post_detail_screen.dart';
import '../../features/post/domain/post.dart';
import '../../features/search/presentation/saved_users_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/domain/user_profile.dart';
import '../../features/team/presentation/team_dashboard_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_room_screen.dart';
import '../../features/notification/presentation/notification_list_screen.dart';
import '../../core/widgets/scaffold_with_navbar.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/home/presentation/placeholder_screens.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // --- Independent Routes (No Bottom Bar, No Drawer) ---
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post-detail',
        builder: (context, state) {
          final post = state.extra as Post;
          return PostDetailScreen(post: post);
        },
      ),
      GoRoute(
        path: '/saved-users',
        builder: (context, state) => const SavedUsersScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final profile = state.extra as UserProfile;
          return EditProfileScreen(profile: profile);
        },
      ),
      GoRoute(
        path: '/team-dashboard',
        builder: (context, state) => const TeamDashboardScreen(),
      ),
      GoRoute(
        path: '/chat-room/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final userName = state.extra as String? ?? 'Sohbet';
          return ChatRoomScreen(otherUserId: userId, otherUserName: userName);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        path: '/edit-interests',
        builder: (context, state) => const EditInterestsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // --- Shell Route (With Bottom Bar & Drawer) ---
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavbar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedPostsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(
        authStateChangesProvider,
      );

      if (authState.isLoading || authState.hasError) return null;

      final isLoggedIn = authState.value != null;

      final isSplash = state.uri.toString() == '/';
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';
      final isOnboarding = state.uri.toString() == '/onboarding';

      if (isSplash) {
        return isLoggedIn ? '/home' : '/onboarding';
      }

      if (!isLoggedIn) {
        if (!isLoggingIn && !isRegistering && !isOnboarding) {
          return '/login';
        }
      }

      if (isLoggedIn) {
        if (isLoggingIn || isRegistering || isOnboarding) {
          return '/home';
        }
      }

      return null;
    },
  );
}
