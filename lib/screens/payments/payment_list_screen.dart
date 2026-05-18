import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';
import '../../widgets/common_widgets.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});
  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  List<PaymentModel> _payments = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await PaymentService.getPayments(limit: 50);
    if (!mounted) return;
    setState(() { _payments = res['success'] == true ? res['payments'] as List<PaymentModel> : []; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy HH:mm');
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Pembayaran', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          const Text('Riwayat pembayaran Anda', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ])),
        Expanded(
          child: _loading
              ? const LoadingWidget()
              : _payments.isEmpty
                  ? const EmptyState(icon: Icons.payment_outlined, title: 'Belum ada pembayaran')
                  : RefreshIndicator(onRefresh: _load, color: AppColors.accentBlue, child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _payments.length,
                      itemBuilder: (_, i) {
                        final p = _payments[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.payment, color: AppColors.accentPurple, size: 20)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.paymentMethod.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                                if (p.createdAt != null) Text(dateFmt.format(p.createdAt!.toLocal()), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ])),
                              StatusBadge(status: p.status),
                            ]),
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.divider, height: 1),
                            const SizedBox(height: 10),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('ID: ${p.id.length > 8 ? p.id.substring(0, 8) : p.id}...', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              Text(fmt.format(p.amount), style: const TextStyle(color: AppColors.accentOrange, fontSize: 15, fontWeight: FontWeight.w700)),
                            ]),
                          ]),
                        );
                      },
                    )),
        ),
      ])),
    );
  }
}
