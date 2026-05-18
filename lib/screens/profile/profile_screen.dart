import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final u = await AuthService.getMe();
    if (mounted) setState(() { _user = u; _loading = false; });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('Logout?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: AppColors.accentRed)))],
    ));
    if (confirm != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  void _showEditProfile() {
    if (_user == null) return;
    final nameCtrl = TextEditingController(text: _user!.name);
    final phoneCtrl = TextEditingController(text: _user!.phone);
    final addressCtrl = TextEditingController(text: _user!.address ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: AppColors.surfaceBg, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Edit Profil', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          CustomTextField(controller: nameCtrl, label: 'Nama', prefixIcon: Icons.person_outlined),
          const SizedBox(height: 12),
          CustomTextField(controller: phoneCtrl, label: 'Telepon', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          CustomTextField(controller: addressCtrl, label: 'Alamat', prefixIcon: Icons.location_on_outlined, maxLines: 2),
          const SizedBox(height: 20),
          CustomButton(text: 'Simpan', gradient: AppColors.primaryGradient, onPressed: () async {
            final res = await AuthService.updateProfile(name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(), address: addressCtrl.text.trim());
            if (ctx.mounted) Navigator.pop(ctx);
            if (res['success'] == true) { _load(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diperbarui'), backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating)); }
            else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
          }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(child: _loading
          ? const LoadingWidget()
          : _user == null
              ? EmptyState(icon: Icons.person_off, title: 'Gagal memuat profil', action: ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')))
              : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
                  const SizedBox(height: 16),
                  // Avatar
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.accentBlue.withOpacity(0.3), blurRadius: 20)]),
                    child: Center(child: Text(_user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(height: 16),
                  Text(_user!.name, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: _user!.isAdmin ? AppColors.accentOrange.withOpacity(0.15) : AppColors.accentBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(_user!.isAdmin ? 'Admin' : 'User', style: TextStyle(color: _user!.isAdmin ? AppColors.accentOrange : AppColors.accentBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),

                  // Info
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Informasi Akun', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      InfoRow(label: 'Email', value: _user!.email, icon: Icons.email_outlined),
                      InfoRow(label: 'Telepon', value: _user!.phone, icon: Icons.phone_outlined),
                      if (_user!.address != null && _user!.address!.isNotEmpty)
                        InfoRow(label: 'Alamat', value: _user!.address!, icon: Icons.location_on_outlined),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  _MenuItem(icon: Icons.edit_outlined, label: 'Edit Profil', onTap: _showEditProfile),
                  _MenuItem(icon: Icons.lock_outlined, label: 'Ubah Password', onTap: () => _showChangePassword()),
                  const SizedBox(height: 24),
                  CustomButton(text: 'Logout', icon: Icons.logout, color: AppColors.accentRed, onPressed: _logout),
                  const SizedBox(height: 40),
                ])),
      ),
    );
  }

  void _showChangePassword() {
    final curCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: AppColors.surfaceBg, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Ubah Password', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          CustomTextField(controller: curCtrl, label: 'Password Saat Ini', prefixIcon: Icons.lock_outlined, obscureText: true),
          const SizedBox(height: 12),
          CustomTextField(controller: newCtrl, label: 'Password Baru', prefixIcon: Icons.lock_outlined, obscureText: true),
          const SizedBox(height: 20),
          CustomButton(text: 'Simpan', gradient: AppColors.primaryGradient, onPressed: () async {
            if (curCtrl.text.isEmpty || newCtrl.text.isEmpty) return;
            final res = await AuthService.updatePassword(currentPassword: curCtrl.text, newPassword: newCtrl.text);
            if (ctx.mounted) Navigator.pop(ctx);
            if (res['success'] == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password diperbarui'), backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating)); }
            else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
          }),
        ]),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Row(children: [Icon(icon, color: AppColors.accentBlue, size: 20), const SizedBox(width: 14), Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))), const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20)]),
  ));
}
