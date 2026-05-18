import 'user_model.dart';
import 'car_model.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String userId;
  final String carId;
  final int rating;
  final String comment;
  final String? reply;
  final UserModel? user;
  final CarModel? car;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.carId,
    required this.rating,
    required this.comment,
    this.reply,
    this.user,
    this.car,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    UserModel? user;
    final userData = json['user'] ?? json['userId'];
    if (userData is Map<String, dynamic>) {
      user = UserModel.fromJson(userData);
    }

    CarModel? car;
    final carData = json['car'] ?? json['carId'];
    if (carData is Map<String, dynamic>) {
      car = CarModel.fromJson(carData);
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

    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: json['bookingId'] ?? json['booking'] ?? '',
      userId: userId,
      carId: carId,
      rating: parseInt(json['rating']),
      comment: json['comment'] ?? '',
      reply: json['reply'],
      user: user,
      car: car,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}
