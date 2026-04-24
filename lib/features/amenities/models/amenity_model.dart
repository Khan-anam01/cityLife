class AmenityModel {
  final String id;
  final String name;
  final String category;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? hours;
  final double rating;
  final int ratingCount;
  final bool isOpen;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AmenityModel({
    required this.id,
    required this.name,
    required this.category,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.hours,
    this.rating = 0,
    this.ratingCount = 0,
    this.isOpen = true,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get categoryLabel {
    switch (category) {
      case 'hospital':
        return 'Hospital';
      case 'school':
        return 'School';
      case 'restaurant':
        return 'Restaurant';
      case 'police':
        return 'Police';
      case 'transport':
        return 'Transport';
      case 'bank':
        return 'Bank';
      case 'pharmacy':
        return 'Pharmacy';
      case 'park':
        return 'Park';
      default:
        return category;
    }
  }

  factory AmenityModel.fromMap(Map<String, dynamic> map) {
    return AmenityModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      address: map['address'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      phone: map['phone'] as String?,
      email: map['contact_email'] as String?,
      website: map['website'] as String?,
      hours: map['hours'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: map['rating_count'] as int? ?? 0,
      isOpen: (map['is_open'] as int? ?? 1) == 1,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'contact_email': email,
        'website': website,
        'hours': hours,
        'rating': rating,
        'rating_count': ratingCount,
        'is_open': isOpen ? 1 : 0,
        'description': description,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
