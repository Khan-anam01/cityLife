class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? userName;
  final String? userInitials;
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
    required this.content,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String?,
      userInitials: map['user_initials'] as String?,
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
        'content': content,
        'likes': likes,
        'is_liked': isLiked ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };
}
