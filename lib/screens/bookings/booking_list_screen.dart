import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../widgets/common_widgets.dart';
import 'booking_detail_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});
  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<BookingModel> _bookings = [];
  bool _loading = true;
  String? _selectedStatus;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await BookingService.getBookings(limit: 50, status: _selectedStatus);
    if (!mounted) return;
    setState(() { _bookings = res['success'] == true ? res['bookings'] as List<BookingModel> : []; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy');
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Pemesanan Saya', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            const Text('Riwayat pemesanan mobil', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 14),
            SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
              _FilterChip(label: 'Semua', active: _selectedStatus == null, onTap: () { _selectedStatus = null; _load(); }),
              _FilterChip(label: 'Pending', active: _selectedStatus == 'pending', onTap: () { _selectedStatus = 'pending'; _load(); }),
              _FilterChip(label: 'Dikonfirmasi', active: _selectedStatus == 'confirmed', onTap: () { _selectedStatus = 'confirmed'; _load(); }),
              _FilterChip(label: 'Selesai', active: _selectedStatus == 'completed', onTap: () { _selectedStatus = 'completed'; _load(); }),
              _FilterChip(label: 'Dibatalkan', active: _selectedStatus == 'cancelled', onTap: () { _selectedStatus = 'cancelled'; _load(); }),
            ])),
          ])),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const LoadingWidget()
                : _bookings.isEmpty
                    ? const EmptyState(icon: Icons.calendar_month_outlined, title: 'Belum ada pemesanan', subtitle: 'Pesan mobil untuk mulai')
                    : RefreshIndicator(onRefresh: _load, color: AppColors.accentBlue, child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: _bookings.length,
                        itemBuilder: (_, i) {
                          final b = _bookings[i];
                          return GestureDetector(
                            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.id))); _load(); },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.directions_car, color: AppColors.accentBlue, size: 20)),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(b.car?.name ?? b.car?.fullName ?? 'Mobil #${b.carId.substring(0, 6)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('${dateFmt.format(b.startDate)} - ${dateFmt.format(b.endDate)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                  ])),
                                  StatusBadge(status: b.status),
                                ]),
                                const SizedBox(height: 10),
                                const Divider(color: AppColors.divider, height: 1),
                                const SizedBox(height: 10),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('${b.totalDays} hari', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  Text(fmt.format(b.totalPrice), style: const TextStyle(color: AppColors.accentOrange, fontSize: 14, fontWeight: FontWeight.w700)),
                                ]),
                              ]),
                            ),
                          );
                        },
                      )),
          ),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(gradient: active ? AppColors.primaryGradient : null, color: active ? null : AppColors.cardBg, borderRadius: BorderRadius.circular(8), border: active ? null : Border.all(color: AppColors.border)),
    child: Center(child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
  )));
}
