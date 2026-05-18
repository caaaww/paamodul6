import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';
import '../home/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final res = await AuthService.login(
        email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      final role = await AuthService.getRole();
      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      setState(() => _error = res['message'] ?? 'Login gagal. Cek email dan password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withOpacity(0.35),
                              blurRadius: 30,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.directions_car_rounded,
                            size: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text('Selamat Datang',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text('Masuk ke akun AutoRent Anda',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 48),

                    // Error
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.accentRed.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.accentRed, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(_error!,
                                    style: const TextStyle(
                                        color: AppColors.accentRed,
                                        fontSize: 13))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            hint: 'nama@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email wajib diisi';
                              if (!v.contains('@')) return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passCtrl,
                            label: 'Password',
                            hint: 'Masukkan password',
                            prefixIcon: Icons.lock_outlined,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password wajib diisi';
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          CustomButton(
                            text: 'Masuk',
                            onPressed: _login,
                            isLoading: _loading,
                            gradient: AppColors.primaryGradient,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun? ',
                            style: TextStyle(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen())),
                          child: const Text('Daftar Sekarang',
                              style: TextStyle(
                                  color: AppColors.accentBlue,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
