import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Model sederhana untuk data user yang sudah login
class LoggedInUser {
  final User authUser;
  final Map<String, dynamic> profile;
  final Map<String, dynamic>? customerData;

  const LoggedInUser({
    required this.authUser,
    required this.profile,
    this.customerData,
  });

  String get fullName => profile['full_name'] ?? '';
  String get email => profile['email'] ?? authUser.email ?? '';
  String get role => profile['role'] ?? 'customer';
  bool get isCustomer => role == 'customer';
  bool get isPegawai => role == 'pegawai';
}

class AuthService {
  // ── Register ──────────────────────────────────────────────────────────────
  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String role = 'customer',
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );

    final userId = response.user?.id;
    if (userId == null) return response;

    await supabase.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'email': email,
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');

    if (role == 'customer') {
      await supabase.from('customers').upsert({
        'id': userId,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    }

    if (role == 'pegawai') {
      await supabase.from('pegawai').upsert({
        'id': userId,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    }

    return response;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  static Future<LoggedInUser> login({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Login gagal, coba lagi.');
    }

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    final role = profile['role'] as String? ?? 'customer';

    Map<String, dynamic>? extraData;
    if (role == 'customer') {
      try {
        extraData = await supabase
            .from('customers')
            .select()
            .eq('id', user.id)
            .single();
      } catch (_) {
        extraData = null;
      }
    }

    return LoggedInUser(
      authUser: user,
      profile: profile,
      customerData: extraData,
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // ── Session check ─────────────────────────────────────────────────────────
  static User? get currentUser => supabase.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ── Get profile ───────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return await supabase.from('profiles').select().eq('id', userId).single();
  }

  // ── Get customer data ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getCustomerData() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    try {
      return await supabase
          .from('customers')
          .select()
          .eq('id', userId)
          .single();
    } catch (_) {
      return null;
    }
  }

  // ── Update profile ────────────────────────────────────────────────────────
  static Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await supabase
        .from('profiles')
        .update({
          if (fullName != null) 'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // ── Update customer data ──────────────────────────────────────────────────
  static Future<void> updateCustomer({
    String? phone,
    String? address,
    DateTime? dateOfBirth,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await supabase.from('customers').upsert({
      'id': userId,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
    }, onConflict: 'id');
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  static Future<void> forgotPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.luminatravel://reset-callback/',
    );
  }

  // ── Reset Password ────────────────────────────────────────────────────────
  static Future<void> resetPassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
