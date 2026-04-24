class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? senderName;
  final String? senderInitials;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.senderName,
    this.senderInitials,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      senderName: map['sender_name'] as String?,
      senderInitials: map['sender_initials'] as String?,
      content: map['content'] as String,
      isRead: (map['is_read'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'sender_name': senderName,
        'sender_initials': senderInitials,
        'content': content,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };
}
