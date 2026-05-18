import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../widgets/common_widgets.dart';
import 'car_detail_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});
  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<CarModel> _cars = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Semua', 'value': null, 'icon': Icons.apps_rounded},
    {'label': 'SUV', 'value': 'suv', 'icon': Icons.directions_car_filled},
    {'label': 'Sedan', 'value': 'sedan', 'icon': Icons.airline_seat_recline_normal},
    {'label': 'MPV', 'value': 'mpv', 'icon': Icons.airport_shuttle},
    {'label': 'Hatchback', 'value': 'hatchback', 'icon': Icons.directions_car},
    {'label': 'Sport', 'value': 'sport', 'icon': Icons.speed},
  ];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    setState(() { _loading = true; _error = null; });
    final res = await CarService.getCars(
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      category: _selectedCategory,
      limit: 50,
    );
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() {
        _cars = res['cars'] as List<CarModel>;
        _loading = false;
      });
    } else {
      setState(() {
        _error = res['message'] ?? 'Gagal memuat mobil';
        _loading = false;
      });
    }
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _loadCars();
  }

  void _onCategoryTap(String? category) {
    setState(() => _selectedCategory = category);
    _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                          child: const Text('AutoRent',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Temukan mobil impian Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Cari mobil...',
                        prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onSubmitted: _onSearch,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final cat = _categories[i];
                        final isActive = _selectedCategory == cat['value'];
                        return GestureDetector(
                          onTap: () => _onCategoryTap(cat['value']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: isActive ? AppColors.primaryGradient : null,
                              color: isActive ? null : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: isActive ? null : Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(cat['icon'], size: 15,
                                    color: isActive ? Colors.white : AppColors.textMuted),
                                const SizedBox(width: 6),
                                Text(cat['label'],
                                    style: TextStyle(
                                        color: isActive ? Colors.white : AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Car List
            Expanded(
              child: _loading
                  ? const LoadingWidget(message: 'Memuat mobil...')
                  : _error != null
                      ? EmptyState(
                          icon: Icons.error_outline,
                          title: 'Terjadi Kesalahan',
                          subtitle: _error,
                          action: ElevatedButton(onPressed: _loadCars, child: const Text('Coba Lagi')),
                        )
                      : _cars.isEmpty
                          ? const EmptyState(icon: Icons.directions_car_outlined, title: 'Tidak ada mobil ditemukan', subtitle: 'Coba ubah filter atau kata kunci pencarian')
                          : RefreshIndicator(
                              onRefresh: _loadCars,
                              color: AppColors.accentBlue,
                              child: ListView.builder(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: _cars.length,
                                itemBuilder: (ctx, i) => _CarCard(
                                  car: _cars[i],
                                  onTap: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => CarDetailScreen(carId: _cars[i].id))),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;
  const _CarCard({required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 160,
                width: double.infinity,
                color: AppColors.cardBg2,
                child: car.primaryImage.isNotEmpty
                    ? Image.network(
                        car.primaryImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(car.name.isNotEmpty ? car.name : car.fullName,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (car.rating > 0) ...[
                        const Icon(Icons.star_rounded, color: AppColors.accentYellow, size: 16),
                        const SizedBox(width: 3),
                        Text(car.rating.toStringAsFixed(1),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${car.brand} • ${car.category.toUpperCase()} • ${car.year}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _SpecChip(icon: Icons.settings, label: car.transmission),
                      const SizedBox(width: 8),
                      _SpecChip(icon: Icons.local_gas_station, label: car.fuelType),
                      const SizedBox(width: 8),
                      _SpecChip(icon: Icons.event_seat, label: '${car.seats}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: formatter.format(car.pricePerDay),
                              style: const TextStyle(
                                  color: AppColors.accentOrange,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                          const TextSpan(
                              text: ' / hari',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: car.isAvailable
                              ? AppColors.accentGreen.withOpacity(0.15)
                              : AppColors.accentRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          car.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                          style: TextStyle(
                            color: car.isAvailable ? AppColors.accentGreen : AppColors.accentRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.cardBg2,
      child: const Center(
          child: Icon(Icons.directions_car_rounded, size: 60, color: AppColors.textMuted)),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
