class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? userName;
  final String? userInitials;
  final String? userPhotoUrl;
  final String userRole; // 'user' | 'company' | 'admin'
  final String content;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.userName,
    this.userInitials,
    this.userPhotoUrl,
    this.userRole = 'user',
    required this.content,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  bool get isCompany => userRole == 'company';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  // ── Realtime Database ──────────────────────────────────
  Map<String, dynamic> toRealtimeDb() => {
        'id': id,
        'post_id': postId,
        'user_id': userId,
        'user_name': userName,
        'user_initials': userInitials,
        'user_photo_url': userPhotoUrl,
        'user_role': userRole,
        'content': content,
        'likes': likes,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory CommentModel.fromRealtimeDb(Map<dynamic, dynamic> map, String id) {
    return CommentModel(
      id: id,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String?,
      userInitials: map['user_initials'] as String?,
      userPhotoUrl: map['user_photo_url'] as String?,
      userRole: map['user_role'] as String? ?? 'user',
      content: map['content'] as String,
      likes: map['likes'] as int? ?? 0,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
    );
  }

  // ── SQLite (local cache) ───────────────────────────────
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String?,
      userInitials: map['user_initials'] as String?,
      userPhotoUrl: map['user_photo_url'] as String?,
      userRole: map['user_role'] as String? ?? 'user',
      content: map['content'] as String,
      likes: map['likes'] as int? ?? 0,
      isLiked: (map['is_liked'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'post_id': postId,
        'user_id': userId,
        'user_name': userName,
        'user_initials': userInitials,
        'user_photo_url': userPhotoUrl,
        'user_role': userRole,
        'content': content,
        'likes': likes,
        'is_liked': isLiked ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };
}
