enum ReportStatus { pending, inProgress, resolved, rejected }

enum ReportCategory {
  pothole,
  streetLight,
  garbage,
  water,
  sewage,
  vandalism,
  noise,
  flooding,
  other
}

class ReportModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportStatus status;
  final double latitude;
  final double longitude;
  final String? address;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.status = ReportStatus.pending,
    required this.latitude,
    required this.longitude,
    this.address,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get categoryLabel {
    switch (category) {
      case ReportCategory.pothole:
        return 'Pothole';
      case ReportCategory.streetLight:
        return 'Street Light';
      case ReportCategory.garbage:
        return 'Garbage';
      case ReportCategory.water:
        return 'Water Issue';
      case ReportCategory.sewage:
        return 'Sewage';
      case ReportCategory.vandalism:
        return 'Vandalism';
      case ReportCategory.noise:
        return 'Noise';
      case ReportCategory.flooding:
        return 'Flooding';
      case ReportCategory.other:
        return 'Other';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case ReportCategory.pothole:
        return '🕳️';
      case ReportCategory.streetLight:
        return '💡';
      case ReportCategory.garbage:
        return '🗑️';
      case ReportCategory.water:
        return '💧';
      case ReportCategory.sewage:
        return '🚰';
      case ReportCategory.vandalism:
        return '🔨';
      case ReportCategory.noise:
        return '🔊';
      case ReportCategory.flooding:
        return '🌊';
      case ReportCategory.other:
        return '📋';
    }
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: ReportCategory.values.firstWhere(
        (c) => c.name == (map['category'] as String),
        orElse: () => ReportCategory.other,
      ),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'pending'),
        orElse: () => ReportStatus.pending,
      ),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category.name,
        'status': status.name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
