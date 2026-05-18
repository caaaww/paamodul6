import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_widgets.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});
  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  List<PaymentModel> _payments = [];
  bool _loading = true;
  String? _filter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await PaymentService.getPayments(limit: 50, status: _filter);
    if (!mounted) return;
    setState(() { _payments = res['success'] == true ? res['payments'] as List<PaymentModel> : []; _loading = false; });
  }

  Future<void> _verify(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('Verifikasi Pembayaran?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Apakah Anda yakin ingin memverifikasi pembayaran ini?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Verifikasi', style: TextStyle(color: AppColors.accentGreen)))],
    ));
    if (confirm != true) return;
    final res = await PaymentService.verifyPayment(id);
    if (!mounted) return;
    if (res['success'] == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran diverifikasi'), backgroundColor: AppColors.accentGreen, behavior: SnackBarBehavior.floating)); _load(); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
  }

  Future<void> _refund(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('Refund Pembayaran?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Apakah Anda yakin ingin merefund pembayaran ini?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Refund', style: TextStyle(color: AppColors.accentOrange)))],
    ));
    if (confirm != true) return;
    final res = await PaymentService.refundPayment(id);
    if (!mounted) return;
    if (res['success'] == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran direfund'), backgroundColor: AppColors.accentOrange, behavior: SnackBarBehavior.floating)); _load(); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: AppColors.accentRed, behavior: SnackBarBehavior.floating)); }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy HH:mm');
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kelola Pembayaran', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          const Text('Verifikasi dan kelola pembayaran', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
            _Chip('Semua', _filter == null, () { _filter = null; _load(); }),
            _Chip('Pending', _filter == 'pending', () { _filter = 'pending'; _load(); }),
            _Chip('Verified', _filter == 'verified', () { _filter = 'verified'; _load(); }),
            _Chip('Refunded', _filter == 'refunded', () { _filter = 'refunded'; _load(); }),
          ])),
        ])),
        const SizedBox(height: 12),
        Expanded(child: _loading
            ? const LoadingWidget()
            : _payments.isEmpty
                ? const EmptyState(icon: Icons.payment_outlined, title: 'Tidak ada pembayaran')
                : RefreshIndicator(onRefresh: _load, color: AppColors.accentOrange, child: ListView.builder(
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
                              if (p.user != null) Text('oleh: ${p.user!.name}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              if (p.createdAt != null) Text(dateFmt.format(p.createdAt!.toLocal()), style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                            ])),
                            StatusBadge(status: p.status),
                          ]),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('ID: ${p.id.length > 8 ? p.id.substring(0, 8) : p.id}...', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            Text(fmt.format(p.amount), style: const TextStyle(color: AppColors.accentOrange, fontSize: 15, fontWeight: FontWeight.w700)),
                          ]),
                          if (p.paymentProof != null && p.paymentProof!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(children: [const Icon(Icons.image, size: 14, color: AppColors.accentBlue), const SizedBox(width: 4), Expanded(child: Text('Bukti: ${p.paymentProof}', style: const TextStyle(color: AppColors.accentBlue, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                          ],
                          // Actions
                          if (p.isPending) ...[
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(child: SizedBox(height: 36, child: CustomButton(text: 'Verifikasi', onPressed: () => _verify(p.id), color: AppColors.accentGreen, height: 36))),
                              const SizedBox(width: 8),
                              Expanded(child: SizedBox(height: 36, child: CustomButton(text: 'Refund', onPressed: () => _refund(p.id), color: AppColors.accentPurple, outlined: true, height: 36))),
                            ]),
                          ],
                          if (p.isVerified) ...[
                            const SizedBox(height: 10),
                            SizedBox(height: 36, child: CustomButton(text: 'Refund', onPressed: () => _refund(p.id), color: AppColors.accentPurple, outlined: true, height: 36)),
                          ],
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
