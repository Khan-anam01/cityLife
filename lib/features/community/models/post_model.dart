class PostModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userInitials;
  final String? userPhotoUrl;
  final String userRole; // 'user' | 'company' | 'admin'
  final String content;
  final String? imageUrl;
  final int likes;
  final int commentsCount;
  final int reposts;
  final bool isLiked;
  final bool isReposted;
  final String? county;
  final String? constituency;
  final String? groupId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userInitials,
    this.userPhotoUrl,
    this.userRole = 'user',
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.commentsCount = 0,
    this.reposts = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.county,
    this.constituency,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompany => userRole == 'company';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  // ── Realtime Database ──────────────────────────────────
  /// Converts to a map suitable for Firebase Realtime Database.
  Map<String, dynamic> toRealtimeDb() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_initials': userInitials,
        'user_photo_url': userPhotoUrl,
        'user_role': userRole,
        'content': content,
        'image_url': imageUrl,
        'likes': likes,
        'comments_count': commentsCount,
        'reposts': reposts,
        'county': county,
        'constituency': constituency,
        'group_id': groupId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory PostModel.fromRealtimeDb(Map<dynamic, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String?,
      userInitials: map['user_initials'] as String?,
      userPhotoUrl: map['user_photo_url'] as String?,
      userRole: map['user_role'] as String? ?? 'user',
      content: map['content'] as String,
      imageUrl: map['image_url'] as String?,
      likes: map['likes'] as int? ?? 0,
      commentsCount: map['comments_count'] as int? ?? 0,
      reposts: map['reposts'] as int? ?? 0,
      county: map['county'] as String?,
      constituency: map['constituency'] as String?,
      groupId: map['group_id'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int? ?? 0),
    );
  }

  // ── SQLite (local cache) ───────────────────────────────
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String?,
      userInitials: map['user_initials'] as String?,
      userPhotoUrl: map['user_photo_url'] as String?,
      userRole: map['user_role'] as String? ?? 'user',
      content: map['content'] as String,
      imageUrl: map['image_url'] as String?,
      likes: map['likes'] as int? ?? 0,
      commentsCount: map['comments_count'] as int? ?? 0,
      reposts: map['reposts'] as int? ?? 0,
      isLiked: (map['is_liked'] as int? ?? 0) == 1,
      isReposted: (map['is_reposted'] as int? ?? 0) == 1,
      county: map['county'] as String?,
      constituency: map['constituency'] as String?,
      groupId: map['group_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_initials': userInitials,
        'user_photo_url': userPhotoUrl,
        'user_role': userRole,
        'content': content,
        'image_url': imageUrl,
        'likes': likes,
        'comments_count': commentsCount,
        'reposts': reposts,
        'is_liked': isLiked ? 1 : 0,
        'is_reposted': isReposted ? 1 : 0,
        'county': county,
        'constituency': constituency,
        'group_id': groupId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  PostModel copyWith({
    int? likes,
    int? commentsCount,
    int? reposts,
    bool? isLiked,
    bool? isReposted,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      userName: userName,
      userInitials: userInitials,
      userPhotoUrl: userPhotoUrl,
      userRole: userRole,
      content: content,
      imageUrl: imageUrl,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      reposts: reposts ?? this.reposts,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      county: county,
      constituency: constituency,
      groupId: groupId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
