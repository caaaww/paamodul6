import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_widgets.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});
  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<BookingModel> _bookings = [];
  bool _loading = true;
  String? _filter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await BookingService.getBookings(limit: 50, status: _filter);
    if (!mounted) return;
    setState(() { _bookings = res['success'] == true ? res['bookings'] as List<BookingModel> : []; _loading = false; });
  }

  Future<void> _confirm(String id) async {
    final res = await BookingService.confirmBooking(id);
    if (!mounted) return;
    if (res['success'] == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking dikonfirmasi'), backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating)); _load(); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
  }

  Future<void> _complete(String id) async {
    final res = await BookingService.completeBooking(id);
    if (!mounted) return;
    if (res['success'] == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking diselesaikan'), backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating)); _load(); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
  }

  Future<void> _cancel(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('Batalkan Booking?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Yakin ingin membatalkan?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya', style: TextStyle(color: AppColors.accentRed)))],
    ));
    if (confirm != true) return;
    final res = await BookingService.cancelBooking(id);
    if (!mounted) return;
    if (res['success'] == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking dibatalkan'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); _load(); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy');
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kelola Booking', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          const Text('Konfirmasi dan kelola pemesanan', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
            _Chip('Semua', _filter == null, () { _filter = null; _load(); }),
            _Chip('Pending', _filter == 'pending', () { _filter = 'pending'; _load(); }),
            _Chip('Dikonfirmasi', _filter == 'confirmed', () { _filter = 'confirmed'; _load(); }),
            _Chip('Selesai', _filter == 'completed', () { _filter = 'completed'; _load(); }),
            _Chip('Dibatalkan', _filter == 'cancelled', () { _filter = 'cancelled'; _load(); }),
          ])),
        ])),
        const SizedBox(height: 12),
        Expanded(child: _loading
            ? const LoadingWidget()
            : _bookings.isEmpty
                ? const EmptyState(icon: Icons.calendar_month_outlined, title: 'Tidak ada booking')
                : RefreshIndicator(onRefresh: _load, color: AppColors.accentOrange, child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _bookings.length,
                    itemBuilder: (_, i) {
                      final b = _bookings[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(b.car?.name ?? b.car?.fullName ?? 'Mobil', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                              if (b.user != null) Text('oleh: ${b.user!.name}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            ])),
                            StatusBadge(status: b.status),
                          ]),
                          const SizedBox(height: 8),
                          Text('${dateFmt.format(b.startDate)} - ${dateFmt.format(b.endDate)} (${b.totalDays} hari)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(fmt.format(b.totalPrice), style: const TextStyle(color: AppColors.accentOrange, fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          // Actions
                          if (b.isPending) Row(children: [
                            Expanded(child: SizedBox(height: 36, child: CustomButton(text: 'Konfirmasi', onPressed: () => _confirm(b.id), color: AppColors.accentGreen, height: 36))),
                            const SizedBox(width: 8),
                            Expanded(child: SizedBox(height: 36, child: CustomButton(text: 'Tolak', onPressed: () => _cancel(b.id), color: AppColors.accentRed, outlined: true, height: 36))),
                          ]),
                          if (b.isConfirmed) Row(children: [
                            Expanded(child: SizedBox(height: 36, child: CustomButton(text: 'Selesaikan', onPressed: () => _complete(b.id), color: AppColors.accentGreen, height: 36))),
                            const SizedBox(width: 8),
                            Expanded(child: SizedBox(height: 36, child: CustomButton(text: 'Batalkan', onPressed: () => _cancel(b.id), color: AppColors.accentRed, outlined: true, height: 36))),
                          ]),
                        ]),
                      );
                    },
                  ))),
      ])),
    );
  }
}

class _Chip extends StatelessWidget {
  final String l; final bool a; final VoidCallback t;
  const _Chip(this.l, this.a, this.t);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: t, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(gradient: a ? AppColors.orangeGradient : null, color: a ? null : AppColors.cardBg, borderRadius: BorderRadius.circular(8), border: a ? null : Border.all(color: AppColors.border)),
    child: Center(child: Text(l, style: TextStyle(color: a ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: a ? FontWeight.w600 : FontWeight.w400))),
  )));
}
