import 'car_model.dart';
import 'user_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String carId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;
  final String status;
  final String? notes;
  final String? pickupLocation;
  final String? returnLocation;
  final CarModel? car;
  final UserModel? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isPaid;

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.pickupLocation,
    this.returnLocation,
    this.car,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.isPaid,
  });

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    // Parse car - could be an object or just an ID string
    CarModel? car;
    final carData = json['car'] ?? json['carId'];
    if (carData is Map<String, dynamic>) {
      car = CarModel.fromJson(carData);
    }

    // Parse user - could be an object or just an ID string
    UserModel? user;
    final userData = json['user'] ?? json['userId'];
    if (userData is Map<String, dynamic>) {
      user = UserModel.fromJson(userData);
    }

    String carId = '';
    if (carData is String) {
      carId = carData;
    } else if (carData is Map<String, dynamic>) {
      carId = carData['_id'] ?? '';
    }

    String userId = '';
    if (userData is String) {
      userId = userData;
    } else if (userData is Map<String, dynamic>) {
      userId = userData['_id'] ?? '';
    }

    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userId,
      carId: carId,
      startDate: DateTime.tryParse(json['startDate'] ?? json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? json['end_date'] ?? '') ?? DateTime.now(),
      totalDays: parseInt(json['totalDays'] ?? json['total_days']),
      totalPrice: parseDouble(json['totalPrice'] ?? json['total_price']),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      pickupLocation: json['pickupLocation'] ?? json['pickup_location'],
      returnLocation: json['returnLocation'] ?? json['return_location'],
      car: car,
      user: user,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      isPaid: json['isPaid'] ?? json['is_paid'],
    );
  }
}
