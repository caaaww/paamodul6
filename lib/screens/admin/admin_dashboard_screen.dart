import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../services/user_service.dart';
import '../../widgets/common_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await UserService.getStats();
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() { _stats = res['data'] is Map ? res['data'] : res; _loading = false; });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(child: _loading
          ? const LoadingWidget(message: 'Memuat dashboard...')
          : RefreshIndicator(onRefresh: _load, color: AppColors.accentOrange, child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  ShaderMask(
                    shaderCallback: (b) => AppColors.orangeGradient.createShader(b),
                    child: const Text('Admin Panel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                  const Spacer(),
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.admin_panel_settings, color: AppColors.accentOrange, size: 22)),
                ]),
                const SizedBox(height: 4),
                const Text('Dashboard Manajemen', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 24),

                // Stats grid
                if (_stats != null) ...[
                  Row(children: [
                    _StatCard('Total User', _getVal('totalUsers'), Icons.people, AppColors.accentBlue),
                    const SizedBox(width: 12),
                    _StatCard('Total Mobil', _getVal('totalCars'), Icons.directions_car, AppColors.accentGreen),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _StatCard('Total Booking', _getVal('totalBookings'), Icons.calendar_month, AppColors.accentOrange),
                    const SizedBox(width: 12),
                    _StatCard('Pembayaran', _getVal('totalPayments'), Icons.payment, AppColors.accentPurple),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _StatCard('Pending', _getVal('pendingBookings'), Icons.pending_actions, AppColors.statusPending),
                    const SizedBox(width: 12),
                    _StatCard('Selesai', _getVal('completedBookings'), Icons.check_circle_outline, AppColors.statusCompleted),
                  ]),
                ] else
                  const EmptyState(icon: Icons.dashboard_outlined, title: 'Data tidak tersedia', subtitle: 'Pull down untuk refresh'),

                const SizedBox(height: 24),
                const Text('Tips Admin', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _TipCard(icon: Icons.payment, title: 'Verifikasi Pembayaran', desc: 'Cek tab Pembayaran untuk verifikasi pembayaran masuk', color: AppColors.accentPurple),
                const SizedBox(height: 8),
                _TipCard(icon: Icons.calendar_month, title: 'Konfirmasi Booking', desc: 'Konfirmasi atau selesaikan booking di tab Booking', color: AppColors.accentOrange),
              ]),
            ))),
    );
  }

  String _getVal(String key) {
    if (_stats == null) return '0';
    final v = _stats![key] ?? _stats!['stats']?[key];
    return v?.toString() ?? '0';
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ]),
  ));
}

class _TipCard extends StatelessWidget {
  final IconData icon; final String title, desc; final Color color;
  const _TipCard({required this.icon, required this.title, required this.desc, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
    child: Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
    ]))]),
  );
}
