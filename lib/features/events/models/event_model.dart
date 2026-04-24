class EventModel {
  final String id;
  final String title;
  final String? description;
  final String venue;
  final double? latitude;
  final double? longitude;
  final DateTime startDate;
  final DateTime? endDate;
  final String? category;
  final String? imageUrl;
  final String? organizer;
  final int? capacity;
  final double price;
  final bool isFree;
  final int attendees;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.venue,
    this.latitude,
    this.longitude,
    required this.startDate,
    this.endDate,
    this.category,
    this.imageUrl,
    this.organizer,
    this.capacity,
    this.price = 0,
    this.isFree = true,
    this.attendees = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = startDate;
    final day = days[d.weekday - 1];
    final month = months[d.month - 1];
    return '$day, $month ${d.day}';
  }

  String get formattedTime {
    final h = startDate.hour;
    final m = startDate.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  String get priceLabel => isFree ? 'Free' : 'KES ${price.toStringAsFixed(0)}';

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      venue: map['venue'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      category: map['category'] as String?,
      imageUrl: map['image_url'] as String?,
      organizer: map['organizer'] as String?,
      capacity: map['capacity'] as int?,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      isFree: (map['is_free'] as int? ?? 1) == 1,
      attendees: map['attendees'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'venue': venue,
        'latitude': latitude,
        'longitude': longitude,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'category': category,
        'image_url': imageUrl,
        'organizer': organizer,
        'capacity': capacity,
        'price': price,
        'is_free': isFree ? 1 : 0,
        'attendees': attendees,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
