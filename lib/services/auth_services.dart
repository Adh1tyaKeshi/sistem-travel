import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService {
  // ── Register ──────────────────────────────
  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName}, // masuk ke profiles via trigger
    );
  }

  // ── Login ─────────────────────────────────
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Logout ────────────────────────────────
  static Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // ── Current user ──────────────────────────
  static User? get currentUser => supabase.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  // ── Get profile data ──────────────────────
  static Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return data;
  }

  // ── Update profile ────────────────────────
  static Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('profiles')
        .update({
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        })
        .eq('id', userId);
  }
}
