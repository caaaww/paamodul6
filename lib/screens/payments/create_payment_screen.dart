import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/booking_model.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreatePaymentScreen extends StatefulWidget {
  final BookingModel booking;
  const CreatePaymentScreen({super.key, required this.booking});
  @override
  State<CreatePaymentScreen> createState() => _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends State<CreatePaymentScreen> {
  String _method = 'transfer_bank';
  final _bankCtrl = TextEditingController(text: 'BCA');
  final _accNumCtrl = TextEditingController();
  final _accNameCtrl = TextEditingController();
  final _trxIdCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  final _methods = [
    {'value': 'transfer_bank', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'value': 'kartu_kredit', 'label': 'Kartu Kredit', 'icon': Icons.credit_card},
    {'value': 'kartu_debit', 'label': 'Kartu Debit', 'icon': Icons.credit_card_outlined},
    {'value': 'e_wallet', 'label': 'E-Wallet', 'icon': Icons.account_balance_wallet},
    {'value': 'tunai', 'label': 'Tunai', 'icon': Icons.money},
  ];

  Future<void> _submit() async {
    if (_method == 'transfer_bank' || _method == 'kartu_kredit' || _method == 'kartu_debit') {
      if (_accNumCtrl.text.trim().isEmpty) { setState(() => _error = 'Nomor rekening/kartu wajib diisi'); return; }
      if (_accNameCtrl.text.trim().isEmpty) { setState(() => _error = 'Nama rekening wajib diisi'); return; }
    }
    setState(() { _loading = true; _error = null; });
    final res = await PaymentService.createPayment(
      bookingId: widget.booking.id,
      method: _method,
      bankName: _bankCtrl.text.trim().isNotEmpty ? _bankCtrl.text.trim() : null,
      accountNumber: _accNumCtrl.text.trim().isNotEmpty ? _accNumCtrl.text.trim() : null,
      accountName: _accNameCtrl.text.trim().isNotEmpty ? _accNameCtrl.text.trim() : null,
      transactionId: _trxIdCtrl.text.trim().isNotEmpty ? _trxIdCtrl.text.trim() : null,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil dikirim!'), backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating));
      Navigator.pop(context, true);
    } else {
      setState(() => _error = res['message'] ?? 'Gagal mengirim pembayaran');
    }
  }

  @override
  void dispose() { _bankCtrl.dispose(); _accNumCtrl.dispose(); _accNameCtrl.dispose(); _trxIdCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Amount
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            const Text('Total Pembayaran', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            Text(fmt.format(widget.booking.totalPrice), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Booking #${widget.booking.id.substring(0, 8)}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 24),

        if (_error != null) ...[
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [const Icon(Icons.error_outline, color: AppColors.accentRed, size: 16), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.accentRed, fontSize: 12)))])),
          const SizedBox(height: 16),
        ],

        const Text('Metode Pembayaran', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...(_methods.map((m) => GestureDetector(
          onTap: () => setState(() => _method = m['value'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _method == m['value'] ? AppColors.accentBlue.withOpacity(0.1) : AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _method == m['value'] ? AppColors.accentBlue : AppColors.border, width: _method == m['value'] ? 1.5 : 1),
            ),
            child: Row(children: [
              Icon(m['icon'] as IconData, color: _method == m['value'] ? AppColors.accentBlue : AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(m['label'] as String, style: TextStyle(color: _method == m['value'] ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 14, fontWeight: _method == m['value'] ? FontWeight.w600 : FontWeight.w400))),
              if (_method == m['value']) const Icon(Icons.check_circle, color: AppColors.accentBlue, size: 20),
            ]),
          ),
        ))),
        const SizedBox(height: 20),

        if (_method == 'transfer_bank' || _method == 'kartu_kredit' || _method == 'kartu_debit') ...[
          const Text('Informasi Rekening Pengirim', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          CustomTextField(controller: _bankCtrl, label: 'Nama Bank / Provider', hint: 'BCA / Mandiri / VISA', prefixIcon: Icons.account_balance),
          const SizedBox(height: 12),
          CustomTextField(controller: _accNumCtrl, label: 'Nomor Rekening / Kartu', hint: '1234567890', prefixIcon: Icons.payment_outlined, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          CustomTextField(controller: _accNameCtrl, label: 'Nama Pemilik Rekening / Kartu', hint: 'Nama Anda', prefixIcon: Icons.person_outlined),
          const SizedBox(height: 12),
        ],

        CustomTextField(controller: _trxIdCtrl, label: 'ID Transaksi / ID Referensi (opsional)', hint: 'TRX-12345', prefixIcon: Icons.tag),
        const SizedBox(height: 12),
        CustomTextField(controller: _notesCtrl, label: 'Catatan (opsional)', hint: 'Catatan tambahan...', prefixIcon: Icons.note_outlined, maxLines: 2),
        const SizedBox(height: 28),
        CustomButton(text: 'Kirim Pembayaran', onPressed: _submit, isLoading: _loading, gradient: AppColors.primaryGradient, icon: Icons.send_rounded),
      ])),
    );
  }
}
