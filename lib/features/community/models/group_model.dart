class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String creatorId;
  final int memberCount;
  final bool isPrivate;
  final String? county;
  final String? constituency;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.creatorId,
    this.memberCount = 0,
    this.isPrivate = false,
    this.county,
    this.constituency,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      creatorId: map['creator_id'] as String,
      memberCount: map['member_count'] as int? ?? 0,
      isPrivate: (map['is_private'] as int? ?? 0) == 1,
      county: map['county'] as String?,
      constituency: map['constituency'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'creator_id': creatorId,
        'member_count': memberCount,
        'is_private': isPrivate ? 1 : 0,
        'county': county,
        'constituency': constituency,
        'created_at': createdAt.toIso8601String(),
      };
}
