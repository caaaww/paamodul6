class CarModel {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final double pricePerDay;
  final String category;
  final String transmission;
  final String fuelType;
  final int seats;
  final List<String> images;
  final bool isAvailable;
  final String description;
  final List<String> features;
  final double rating;
  final int totalReviews;
  final String? licensePlate;
  final String? color;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.category,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.images,
    required this.isAvailable,
    required this.description,
    required this.features,
    required this.rating,
    required this.totalReviews,
    this.licensePlate,
    this.color,
  });

  String get primaryImage =>
      images.isNotEmpty ? images.first : '';

  String get fullName => '$brand $model $year';

  factory CarModel.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic imgs) {
      if (imgs == null) return [];
      if (imgs is List) return imgs.map((e) => e.toString()).toList();
      return [];
    }

    List<String> parseFeatures(dynamic feats) {
      if (feats == null) return [];
      if (feats is List) return feats.map((e) => e.toString()).toList();
      return [];
    }

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

    return CarModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: parseInt(json['year']),
      pricePerDay: parseDouble(json['pricePerDay'] ?? json['price_per_day']),
      category: json['category'] ?? 'sedan',
      transmission: json['transmission'] ?? 'automatic',
      fuelType: json['fuelType'] ?? json['fuel_type'] ?? 'bensin',
      seats: parseInt(json['seats']),
      images: parseImages(json['images']),
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      description: json['description'] ?? '',
      features: parseFeatures(json['features']),
      rating: parseDouble(json['rating']),
      totalReviews: parseInt(json['totalReviews'] ?? json['total_reviews']),
      licensePlate: json['licensePlate'] ?? json['license_plate'],
      color: json['color'],
    );
  }
}
