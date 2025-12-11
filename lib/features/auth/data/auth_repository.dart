import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // EKLENDİ
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
    required List<String> interestIds,
  }) async {
    // İlgili alanları virgülle ayrılmış bir dizeye dönüştür
    final interestsString = interestIds.join(',');

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
        'interestIds':
            interestsString, // Virgülle ayrılmış bir dize olarak geçir
      },
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
