import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // EKLENDİ
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  // AuthRepositoryRef -> Ref
  return AuthRepository(supabase.Supabase.instance.client.auth);
}

@Riverpod(keepAlive: true)
Stream<supabase.User?> authStateChanges(Ref ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield repository.currentUser;
  yield* repository.authStateChanges();
}

class AuthRepository {
  final supabase.GoTrueClient _auth;

  AuthRepository(this._auth);

  Stream<supabase.User?> authStateChanges() {
    return _auth.onAuthStateChange.map((event) => event.session?.user);
  }

  supabase.User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email, password: password);
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

    await _auth.signUp(
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
    await _auth.signOut();
  }
}
