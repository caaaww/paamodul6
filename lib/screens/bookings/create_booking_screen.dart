import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/car_model.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateBookingScreen extends StatefulWidget {
  final CarModel car;
  const CreateBookingScreen({super.key, required this.car});
  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _pickupCtrl = TextEditingController(text: 'Kantor Pusat AutoRent');
  final _returnCtrl = TextEditingController(text: 'Kantor Pusat AutoRent');
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice => _totalDays * widget.car.pricePerDay;

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now.add(const Duration(days: 1)) : (_startDate ?? now).add(const Duration(days: 1)),
      firstDate: isStart ? now : (_startDate ?? now).add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.accentBlue, surface: AppColors.cardBg)), child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart) { _startDate = picked; if (_endDate != null && _endDate!.isBefore(picked.add(const Duration(days: 1)))) _endDate = null; }
        else { _endDate = picked; }
      });
    }
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) { setState(() => _error = 'Pilih tanggal mulai dan selesai'); return; }
    if (_totalDays <= 0) { setState(() => _error = 'Tanggal selesai harus setelah tanggal mulai'); return; }
    if (_pickupCtrl.text.trim().isEmpty) { setState(() => _error = 'Lokasi pengambilan wajib diisi'); return; }
    if (_returnCtrl.text.trim().isEmpty) { setState(() => _error = 'Lokasi pengembalian wajib diisi'); return; }
    setState(() { _loading = true; _error = null; });
    final res = await BookingService.createBooking(
      carId: widget.car.id,
      startDate: _startDate!.toIso8601String(),
      endDate: _endDate!.toIso8601String(),
      pickupLocation: _pickupCtrl.text.trim(),
      returnLocation: _returnCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Pemesanan berhasil dibuat!'), backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating));
      Navigator.pop(context, true);
    } else {
      setState(() => _error = res['message'] ?? 'Gagal membuat pemesanan');
    }
  }

  @override
  void dispose() { _pickupCtrl.dispose(); _returnCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(title: const Text('Buat Pemesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Car info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 80, height: 60,
                  child: widget.car.primaryImage.isNotEmpty
                      ? Image.network(widget.car.primaryImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.cardBg2, child: const Icon(Icons.directions_car, color: AppColors.textMuted)))
                      : Container(color: AppColors.cardBg2, child: const Icon(Icons.directions_car, color: AppColors.textMuted))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.car.name.isNotEmpty ? widget.car.name : widget.car.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${widget.car.brand} • ${widget.car.transmission}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 3),
                Text('${fmt.format(widget.car.pricePerDay)} / hari', style: const TextStyle(color: AppColors.accentOrange, fontSize: 13, fontWeight: FontWeight.w700)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [const Icon(Icons.error_outline, color: AppColors.accentRed, size: 16), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.accentRed, fontSize: 12)))]),
            ),
            const SizedBox(height: 16),
          ],

          const Text('Tanggal Sewa', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DateBox(label: 'Mulai', value: _startDate != null ? dateFmt.format(_startDate!) : 'Pilih tanggal', onTap: () => _pickDate(true))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 18)),
            Expanded(child: _DateBox(label: 'Selesai', value: _endDate != null ? dateFmt.format(_endDate!) : 'Pilih tanggal', onTap: () => _pickDate(false))),
          ]),
          const SizedBox(height: 20),

          CustomTextField(controller: _pickupCtrl, label: 'Lokasi Pengambilan', hint: 'Lokasi...', prefixIcon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          CustomTextField(controller: _returnCtrl, label: 'Lokasi Pengembalian', hint: 'Lokasi...', prefixIcon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          CustomTextField(controller: _notesCtrl, label: 'Catatan (opsional)', hint: 'Tambahkan catatan...', prefixIcon: Icons.note_outlined, maxLines: 3),
          const SizedBox(height: 24),

          // Summary
          if (_totalDays > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                _Row('Durasi Sewa', '$_totalDays hari'),
                _Row('Harga per Hari', fmt.format(widget.car.pricePerDay)),
                const Divider(color: AppColors.divider, height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(fmt.format(_totalPrice), style: const TextStyle(color: AppColors.accentOrange, fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          CustomButton(text: 'Konfirmasi Pemesanan', onPressed: _submit, isLoading: _loading, gradient: AppColors.primaryGradient, icon: Icons.check_circle_outline),
        ]),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  const _DateBox({required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Row(children: [const Icon(Icons.calendar_today, size: 14, color: AppColors.accentBlue), const SizedBox(width: 6), Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)))]),
      ]),
    ));
  }
}

class _Row extends StatelessWidget {
  final String l, r;
  const _Row(this.l, this.r);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)), Text(r, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))]));
}
