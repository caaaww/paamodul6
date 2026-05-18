import 'booking_model.dart';
import 'user_model.dart';

class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String? paymentProof;
  final String status;
  final String? notes;
  final BookingModel? booking;
  final UserModel? user;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.paymentProof,
    required this.status,
    this.notes,
    this.booking,
    this.user,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
  bool get isRefunded => status == 'refunded';

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    BookingModel? booking;
    final bookingData = json['booking'] ?? json['bookingId'];
    if (bookingData is Map<String, dynamic>) {
      booking = BookingModel.fromJson(bookingData);
    }

    UserModel? user;
    final userData = json['user'] ?? json['userId'];
    if (userData is Map<String, dynamic>) {
      user = UserModel.fromJson(userData);
    }

    String bookingId = '';
    if (bookingData is String) {
      bookingId = bookingData;
    } else if (bookingData is Map<String, dynamic>) {
      bookingId = bookingData['_id'] ?? '';
    }

    String userId = '';
    if (userData is String) {
      userId = userData;
    } else if (userData is Map<String, dynamic>) {
      userId = userData['_id'] ?? '';
    }

    return PaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: bookingId,
      userId: userId,
      amount: parseDouble(json['amount']),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? '',
      paymentProof: json['paymentProof'] ?? json['payment_proof'],
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      booking: booking,
      user: user,
      verifiedAt: json['verifiedAt'] != null ? DateTime.tryParse(json['verifiedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}
