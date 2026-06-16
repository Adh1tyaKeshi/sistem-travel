import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';
import '../theme.dart';
import 'login_screen.dart';

// ═════════════════════════════════════════
// PREFERENCES SERVICE
// ═════════════════════════════════════════
class PreferencesService {
  static const _keyLanguage = 'selected_language';
  static const _keyCurrency = 'selected_currency';

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'English';
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language);
  }

  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? 'USD';
  }

  static Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency);
  }
}

// ═════════════════════════════════════════
// PROFILE SCREEN
// ═════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  int _tripCount = 0;
  int _savedCount = 0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final results = await Future.wait<dynamic>([
        AuthService.getProfile(),
        AuthService.getCustomerData(),
        supabase.from('bookings').select('id').eq('user_id', userId),
        supabase.from('saved_destinations').select('id').eq('user_id', userId),
        supabase.from('reviews').select('id').eq('user_id', userId),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          final customerData = results[1] as Map<String, dynamic>?;
          if (customerData != null) {
            _profile = {...?_profile, ...customerData};
          }
          _tripCount = (results[2] as List).length;
          _savedCount = (results[3] as List).length;
          _reviewCount = (results[4] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Yakin mau Log Out?',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Color(0xFFEF5350),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name =
        _profile?['full_name'] ?? user?.email?.split('@').first ?? 'Explorer';
    final email = user?.email ?? '';
    final avatarUrl = _profile?['avatar_url'];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Header ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            ),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Avatar ──
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonalInfoScreen(
                            profile: _profile,
                            onUpdated: _loadProfile,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2.5,
                              ),
                            ),
                            child: ClipOval(
                              child: avatarUrl != null
                                  ? Image.network(avatarUrl, fit: BoxFit.cover)
                                  : Container(
                                      color: AppColors.primary.withOpacity(0.2),
                                      child: Center(
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0D0D0D),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Stats ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(label: 'Trip', value: '$_tripCount'),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.white12,
                            ),
                            _StatItem(label: 'Saved', value: '$_savedCount'),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.white12,
                            ),
                            _StatItem(label: 'Review', value: '$_reviewCount'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Account ──
                    _SectionLabel('Akun'),
                    _MenuItem(
                      icon: Icons.person_outline,
                      label: 'Info Pribadi',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonalInfoScreen(
                            profile: _profile,
                            onUpdated: _loadProfile,
                          ),
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      label: 'Privasi & Keamanan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacySecurityScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Support ──
                    _SectionLabel('Bantuan'),
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Pusat Bantuan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: 'Tentang',
                      onTap: () => _showAboutDialog(context),
                    ),

                    const SizedBox(height: 16),

                    // ── Logout ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEF5350).withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Color(0xFFEF5350),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Keluar',
                                style: TextStyle(
                                  color: Color(0xFFEF5350),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Lumina Travel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi 1.0.0',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              'Wisata | Petualangan | Relaksasi',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Oke',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════
// PERSONAL INFO SCREEN
// ═════════════════════════════════════════
class PersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final VoidCallback onUpdated;

  const PersonalInfoScreen({
    super.key,
    required this.profile,
    required this.onUpdated,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?['full_name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profile?['phone'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.updateProfile(fullName: _nameController.text.trim());
      await AuthService.updateCustomer(phone: _phoneController.text.trim());
      widget.onUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return _BaseScreen(
      title: 'Info Pribadi',
      child: Column(
        children: [
          _InfoField(
            label: 'Nama Lengkap',
            controller: _nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _InfoField(
            label: 'Email',
            initialValue: user?.email ?? '',
            icon: Icons.mail_outline,
            readOnly: true,
            hint: 'Email tidak dapat diubah',
          ),
          const SizedBox(height: 16),
          _InfoField(
            label: 'Nomor HP',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          _SaveButton(isLoading: _isLoading, onTap: _save),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════
// PRIVACY & SECURITY SCREEN
// ═════════════════════════════════════════
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru tidak sama!'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }
    if (_newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 6 karakter!'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPassController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _currentPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Privasi & Keamanan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ganti Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _InfoField(
            label: 'Password Saat Ini',
            controller: _currentPassController,
            icon: Icons.lock_outline,
            obscureText: _obscureCurrent,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
              child: Icon(
                _obscureCurrent
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoField(
            label: 'Password Baru',
            controller: _newPassController,
            icon: Icons.lock_outline,
            obscureText: _obscureNew,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureNew = !_obscureNew),
              child: Icon(
                _obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoField(
            label: 'Konfirmasi Password Baru',
            controller: _confirmPassController,
            icon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _SaveButton(
            label: 'Ubah Password',
            isLoading: _isLoading,
            onTap: _changePassword,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════
// NOTIFICATION SETTINGS SCREEN
// ═════════════════════════════════════════
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _bookingUpdates = true;
  bool _promotions = false;
  bool _reminders = true;
  bool _reviews = true;
  bool _newsletter = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _bookingUpdates = prefs.getBool('notif_booking') ?? true;
        _promotions = prefs.getBool('notif_promo') ?? false;
        _reminders = prefs.getBool('notif_reminder') ?? true;
        _reviews = prefs.getBool('notif_review') ?? true;
        _newsletter = prefs.getBool('notif_newsletter') ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_$key', value);
  }

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Notifikasi',
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                _NotifToggle(
                  icon: Icons.calendar_today_outlined,
                  label: 'Update Pemesanan',
                  subtitle: 'Status pemesanan dan konfirmasi',
                  value: _bookingUpdates,
                  onChanged: (v) {
                    setState(() => _bookingUpdates = v);
                    _toggle('booking', v);
                  },
                ),
                _NotifToggle(
                  icon: Icons.local_offer_outlined,
                  label: 'Promosi',
                  subtitle: 'Promo dan penawaran spesial',
                  value: _promotions,
                  onChanged: (v) {
                    setState(() => _promotions = v);
                    _toggle('promo', v);
                  },
                ),
                _NotifToggle(
                  icon: Icons.alarm_outlined,
                  label: 'Pengingat',
                  subtitle: 'Pengingat check-in dan perjalanan',
                  value: _reminders,
                  onChanged: (v) {
                    setState(() => _reminders = v);
                    _toggle('reminder', v);
                  },
                ),
                _NotifToggle(
                  icon: Icons.rate_review_outlined,
                  label: 'Ulasan',
                  subtitle: 'Pengingat untuk memberi ulasan',
                  value: _reviews,
                  onChanged: (v) {
                    setState(() => _reviews = v);
                    _toggle('review', v);
                  },
                ),
                _NotifToggle(
                  icon: Icons.mail_outline,
                  label: 'Newsletter',
                  subtitle: 'Tips perjalanan dan inspirasi',
                  value: _newsletter,
                  onChanged: (v) {
                    setState(() => _newsletter = v);
                    _toggle('newsletter', v);
                  },
                ),
              ],
            ),
    );
  }
}

// ═════════════════════════════════════════
// HELP CENTER SCREEN
// ═════════════════════════════════════════
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    (
      'Bagaimana cara melakukan booking?',
      'Pilih destinasi yang kamu inginkan, tap "Book Now", isi tanggal dan jumlah tamu, lalu konfirmasi booking.',
    ),
    (
      'Bagaimana cara membatalkan booking?',
      'Buka tab Bookings, pilih booking yang ingin dibatalkan, lalu tap "Cancel Booking".',
    ),
    (
      'Apakah bisa mengubah tanggal booking?',
      'Saat ini perubahan tanggal belum tersedia. Silakan batalkan booking lama dan buat booking baru.',
    ),
    (
      'Bagaimana cara menghubungi support?',
      'Kamu bisa menghubungi kami melalui email di support@luminatravel.com atau WhatsApp di +62 812-3456-7890.',
    ),
    (
      'Apakah data saya aman?',
      'Ya, semua data kamu dienkripsi dan disimpan dengan aman. Kami tidak pernah menjual data pribadi kamu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Pusat Bantuan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.headset_mic_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh bantuan?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'support@luminatravel.com',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'FAQ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => _FaqItem(question: faq.$1, answer: faq.$2)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════
// SETTINGS SCREEN
// ═════════════════════════════════════════
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Pengaturan',
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline,
            label: 'Info Pribadi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PersonalInfoScreen(profile: null, onUpdated: () {}),
              ),
            ),
          ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          _MenuItem(
            icon: Icons.lock_outline,
            label: 'Privasi & Keamanan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────
class _BaseScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const _BaseScreen({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData icon;
  final bool obscureText;
  final bool readOnly;
  final String? hint;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _InfoField({
    required this.label,
    required this.icon,
    this.controller,
    this.initialValue,
    this.obscureText = false,
    this.readOnly = false,
    this.hint,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: readOnly
                ? Colors.white.withOpacity(0.03)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TextField(
            controller: controller ?? TextEditingController(text: initialValue),
            readOnly: readOnly,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              color: readOnly ? Colors.white38 : Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(
                icon,
                color: readOnly ? Colors.white24 : Colors.white38,
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final String label;

  const _SaveButton({
    required this.isLoading,
    required this.onTap,
    this.label = 'Simpan Perubahan',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.primaryShadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : Colors.white38,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}
