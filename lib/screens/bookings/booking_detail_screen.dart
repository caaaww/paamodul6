import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_widgets.dart';
import '../payments/create_payment_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});
  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  BookingModel? _booking;
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final b = await BookingService.getBookingById(widget.bookingId);
    if (mounted) setState(() { _booking = b; _loading = false; });
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('Batalkan Pemesanan?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Apakah Anda yakin ingin membatalkan pemesanan ini?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Batalkan', style: TextStyle(color: AppColors.accentRed)))],
    ));
    if (confirm != true) return;
    setState(() => _actionLoading = true);
    final res = await BookingService.cancelBooking(widget.bookingId);
    if (!mounted) return;
    setState(() => _actionLoading = false);
    if (res['success'] == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemesanan dibatalkan'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); _load(); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy');
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(title: const Text('Detail Pemesanan')),
      body: _loading
          ? const LoadingWidget()
          : _booking == null
              ? const EmptyState(icon: Icons.error_outline, title: 'Pemesanan tidak ditemukan')
              : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Status header
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Column(children: [
                      StatusBadge(status: _booking!.status, fontSize: 13, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
                      const SizedBox(height: 10),
                      Text('ID: ${_booking!.id.substring(0, 8)}...', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Car info
                  if (_booking!.car != null) Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 70, height: 50,
                        child: _booking!.car!.primaryImage.isNotEmpty
                            ? Image.network(_booking!.car!.primaryImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.cardBg2, child: const Icon(Icons.directions_car, color: AppColors.textMuted, size: 24)))
                            : Container(color: AppColors.cardBg2, child: const Icon(Icons.directions_car, color: AppColors.textMuted, size: 24)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_booking!.car!.name.isNotEmpty ? _booking!.car!.name : _booking!.car!.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('${_booking!.car!.brand} • ${_booking!.car!.transmission}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Detail Pemesanan', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      InfoRow(label: 'Tanggal Mulai', value: dateFmt.format(_booking!.startDate), icon: Icons.calendar_today),
                      InfoRow(label: 'Tanggal Selesai', value: dateFmt.format(_booking!.endDate), icon: Icons.event),
                      InfoRow(label: 'Durasi', value: '${_booking!.totalDays} hari', icon: Icons.timer_outlined),
                      if (_booking!.pickupLocation != null && _booking!.pickupLocation!.isNotEmpty)
                        InfoRow(label: 'Lokasi Pengambilan', value: _booking!.pickupLocation!, icon: Icons.location_on_outlined),
                      if (_booking!.returnLocation != null && _booking!.returnLocation!.isNotEmpty)
                        InfoRow(label: 'Lokasi Pengembalian', value: _booking!.returnLocation!, icon: Icons.location_on_outlined),
                      const Divider(color: AppColors.divider, height: 20),
                      InfoRow(label: 'Total Harga', value: fmt.format(_booking!.totalPrice), valueColor: AppColors.accentOrange, icon: Icons.payments_outlined),
                      if (_booking!.notes != null && _booking!.notes!.isNotEmpty)
                        InfoRow(label: 'Catatan', value: _booking!.notes!, icon: Icons.note_outlined),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  if (_booking!.isPending) ...[
                    CustomButton(text: 'Bayar Sekarang', icon: Icons.payment, gradient: AppColors.primaryGradient,
                      onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePaymentScreen(booking: _booking!))); if (r == true) _load(); }),
                    const SizedBox(height: 10),
                    CustomButton(text: 'Batalkan Pemesanan', icon: Icons.cancel_outlined, color: AppColors.accentRed, outlined: true, isLoading: _actionLoading, onPressed: _cancel),
                  ],
                  if (_booking!.isConfirmed)
                    CustomButton(text: 'Bayar Sekarang', icon: Icons.payment, gradient: AppColors.primaryGradient,
                      onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePaymentScreen(booking: _booking!))); if (r == true) _load(); }),
                ])),
    );
  }
}
