import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../services/auth_services.dart';
import 'login_screen.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // FIX: Listen to password changes agar PasswordStrengthBar rebuild
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Validasi field kosong
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surface,
          content: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Semua field harus diisi',
                style: TextStyle(color: Colors.white.withOpacity(0.85)),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Validasi password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF5350),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Password dan konfirmasi tidak cocok',
                style: TextStyle(color: Colors.white.withOpacity(0.85)),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Validasi terms
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surface,
          content: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Please agree to Terms & Privacy Policy',
                style: TextStyle(color: Colors.white.withOpacity(0.85)),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      );

      if (!mounted) return;

      // Supabase by default kirim email konfirmasi.
      // Jika email confirmation DIMATIKAN di dashboard → langsung masuk.
      // Jika email confirmation DINYALAKAN → tampilkan pesan cek email.
      if (response.user != null && response.session != null) {
        // Session langsung ada → email confirmation off → masuk ke app
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScaffold(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        // Session null → email confirmation ON → beritahu user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Row(
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Registrasi berhasil! Cek email kamu untuk konfirmasi.',
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
        // Kembali ke login setelah user baca pesan
        await Future.delayed(const Duration(seconds: 4));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(e.message)),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Terjemahkan pesan error Supabase ke bahasa yang lebih ramah
  String _friendlyError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan login.';
    }
    if (msg.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    if (msg.contains('password') && msg.contains('6')) {
      return 'Password minimal 6 karakter.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Periksa koneksi internet kamu.';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.4), AppColors.background],
              ).createShader(bounds),
              blendMode: BlendMode.srcOver,
              child: Image.network(
                'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dot grid
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DotGridPainter()),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Text(
                            'LUMINA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.5,
                            ),
                          ),
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            'TRAVEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Begin Your\n',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.8,
                              ),
                            ),
                            TextSpan(
                              text: 'Adventure.',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Form card (scrollable)
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 40,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Handle bar
                              Center(
                                child: Container(
                                  width: 44,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Join thousands of explorers worldwide',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Step indicator
                              _StepIndicator(currentStep: 1, totalSteps: 2),
                              const SizedBox(height: 24),

                              // Full name
                              _LuminaTextField(
                                controller: _nameController,
                                hint: 'Full name',
                                icon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 12),

                              // Email
                              _LuminaTextField(
                                controller: _emailController,
                                hint: 'Email address',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),

                              // Password
                              _LuminaTextField(
                                controller: _passwordController,
                                hint: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white.withOpacity(0.4),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Confirm password
                              _LuminaTextField(
                                controller: _confirmPasswordController,
                                hint: 'Confirm password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscureConfirm,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  child: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white.withOpacity(0.4),
                                    size: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // FIX: password di-pass langsung dari controller
                              // karena listener sudah memanggil setState
                              _PasswordStrengthBar(
                                password: _passwordController.text,
                              ),

                              const SizedBox(height: 20),

                              // Terms & conditions
                              GestureDetector(
                                onTap: () => setState(
                                  () => _agreedToTerms = !_agreedToTerms,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(top: 1),
                                      decoration: BoxDecoration(
                                        color: _agreedToTerms
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _agreedToTerms
                                              ? AppColors.primary
                                              : Colors.white.withOpacity(0.25),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _agreedToTerms
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 13,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.45,
                                            ),
                                            fontSize: 12,
                                            height: 1.5,
                                          ),
                                          children: const [
                                            TextSpan(
                                              text:
                                                  'By creating an account, you agree to our ',
                                            ),
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Register button
                              _GradientButton(
                                label: 'Create Account',
                                isLoading: _isLoading,
                                onTap: _handleRegister,
                              ),

                              const SizedBox(height: 24),

                              // Sign in redirect
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        // FIX: nama parameter unik, bukan _ duplikat
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const LoginScreen(),
                                        transitionsBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) => FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                        transitionDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Step $currentStep of $totalSteps',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 3,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Password Strength ────────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  int get _strength {
    if (password.length < 6) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  Color get _color {
    switch (_strength) {
      case 1:
        return const Color(0xFFFF5252);
      case 2:
        return const Color(0xFFFF9800);
      case 3:
        return const Color(0xFFFFD740);
      case 4:
        return const Color(0xFF69F0AE);
      default:
        return Colors.transparent;
    }
  }

  String get _label {
    switch (_strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final filled = i < _strength;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled ? _color : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _LuminaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _LuminaTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.35),
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
