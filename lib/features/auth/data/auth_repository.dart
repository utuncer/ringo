import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // EKLENDİ
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  // AuthRepositoryRef -> Ref
  return AuthRepository(supabase.Supabase.instance.client);
}

@Riverpod(keepAlive: true)
Stream<supabase.User?> authStateChanges(Ref ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield repository.currentUser;
  yield* repository.authStateChanges();
}

class AuthRepository {
  final supabase.SupabaseClient _client;

  AuthRepository(this._client);

  Stream<supabase.User?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  supabase.User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithUsername({
    required String username,
    required String password,
  }) async {
    // 1. Username'den Email'i bul
    final response = await _client
        .from('users')
        .select('email') // Users tablosunda email kolonu olduğunu varsayıyoruz
        .eq('username', username)
        .maybeSingle();

    if (response == null) {
      throw 'Kullanıcı bulunamadı';
    }

    final email = response['email'] as String?;
    if (email == null) {
      throw 'Bu kullanıcı adına bağlı email bulunamadı';
    }

    // 2. Email ile giriş yap
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> uploadAvatar({required String path, required File file}) async {
    await _client.storage.from('avatars').upload(path, file);
  }

  String getAvatarUrl(String path) {
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String role, // 'competitor', 'instructor', 'team'
    required String avatarType, // 'preset', 'custom'
    String? avatarUrl,
    String? avatarGender,
    String? avatarBgColor,
    required List<String> interestIds, // These are actually interest NAMES strings
  }) async {
    // 1. Sign up with Supabase Auth
    // We pass all necessary data in 'data' (metadata).
    // The Database Trigger (handle_new_user) will take care of creating the public profile
    // and inserting the selected interests.
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'full_name': fullName,
        'role': role,
        'avatar_type': avatarType,
        'avatar_url': avatarUrl,
        'avatar_gender': avatarGender,
        'avatar_bg_color': avatarBgColor,
        'interestNames': interestIds,
      },
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
