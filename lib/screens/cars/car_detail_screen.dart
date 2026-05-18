import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_widgets.dart';
import '../bookings/create_booking_screen.dart';

class CarDetailScreen extends StatefulWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});
  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  CarModel? _car;
  bool _loading = true;
  int _imgIdx = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final car = await CarService.getCarById(widget.carId);
    if (mounted) setState(() { _car = car; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    if (_loading) {
      return const Scaffold(backgroundColor: AppColors.primaryBg, body: LoadingWidget(message: 'Memuat detail...'));
    }
    if (_car == null) {
      return Scaffold(backgroundColor: AppColors.primaryBg, appBar: AppBar(), body: const EmptyState(icon: Icons.error_outline, title: 'Mobil tidak ditemukan'));
    }
    final car = _car!;
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260, pinned: true, backgroundColor: AppColors.primaryBg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: car.images.isNotEmpty
                  ? Stack(fit: StackFit.expand, children: [
                      PageView.builder(
                        itemCount: car.images.length,
                        onPageChanged: (i) => setState(() => _imgIdx = i),
                        itemBuilder: (_, i) => Image.network(car.images[i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.cardBg, child: const Icon(Icons.directions_car, size: 80, color: AppColors.textMuted))),
                      ),
                      Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 60, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.primaryBg])))),
                      if (car.images.length > 1)
                        Positioned(bottom: 12, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(car.images.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 3), width: _imgIdx == i ? 18 : 6, height: 6, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: _imgIdx == i ? AppColors.accentBlue : AppColors.textMuted.withOpacity(0.4)))))),
                    ])
                  : Container(color: AppColors.cardBg, child: const Icon(Icons.directions_car, size: 80, color: AppColors.textMuted)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(car.name.isNotEmpty ? car.name : car.fullName, style: AppTextStyles.h2)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: (car.isAvailable ? AppColors.accentGreen : AppColors.accentRed).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(car.isAvailable ? 'Tersedia' : 'Tidak Tersedia', style: TextStyle(color: car.isAvailable ? AppColors.accentGreen : AppColors.accentRed, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text('${car.brand} • ${car.category.toUpperCase()} • ${car.year}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 16),
                // Price
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Harga Sewa', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('${fmt.format(car.pricePerDay)} / hari', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(height: 20),
                // Specs
                const SectionTitle(title: 'Spesifikasi'),
                const SizedBox(height: 10),
                Row(children: [
                  _Spec(Icons.calendar_today, 'Tahun', car.year.toString()),
                  const SizedBox(width: 8),
                  _Spec(Icons.settings, 'Transmisi', car.transmission),
                  const SizedBox(width: 8),
                  _Spec(Icons.local_gas_station, 'BBM', car.fuelType),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _Spec(Icons.event_seat, 'Kursi', '${car.seats}'),
                  const SizedBox(width: 8),
                  _Spec(Icons.palette, 'Warna', car.color ?? '-'),
                  const SizedBox(width: 8),
                  _Spec(Icons.pin, 'Plat', car.licensePlate ?? '-'),
                ]),
                const SizedBox(height: 20),
                if (car.rating > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.accentYellow, size: 28),
                      const SizedBox(width: 8),
                      Text(car.rating.toStringAsFixed(1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 6),
                      Text('(${car.totalReviews} ulasan)', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],
                if (car.description.isNotEmpty) ...[
                  const SectionTitle(title: 'Deskripsi'),
                  const SizedBox(height: 8),
                  Text(car.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 20),
                ],
                if (car.features.isNotEmpty) ...[
                  const SectionTitle(title: 'Fitur'),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: car.features.map((f) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle, size: 13, color: AppColors.accentBlue), const SizedBox(width: 5), Text(f, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))]),
                  )).toList()),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surfaceBg, border: const Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          child: CustomButton(
            text: 'Pesan Sekarang', icon: Icons.calendar_month_rounded, gradient: AppColors.primaryGradient,
            onPressed: car.isAvailable ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateBookingScreen(car: car))) : null,
          ),
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon; final String label, value;
  const _Spec(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Icon(icon, size: 18, color: AppColors.accentBlue),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ));
  }
}
