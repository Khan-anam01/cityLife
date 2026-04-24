class NewsModel {
  final String id;
  final String title;
  final String body;
  final String? summary;
  final String? imageUrl;
  final String? author;
  final String? category;
  final List<String> tags;
  final int views;
  final int likes;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.body,
    this.summary,
    this.imageUrl,
    this.author,
    this.category,
    this.tags = const [],
    this.views = 0,
    this.likes = 0,
    this.isPublished = true,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get timeAgo {
    final date = publishedAt ?? createdAt;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  String get categoryEmoji {
    switch (category) {
      case 'Transport':
        return '🚌';
      case 'Health':
        return '🏥';
      case 'Education':
        return '🎓';
      case 'Technology':
        return '💻';
      case 'Business':
        return '💼';
      case 'Environment':
        return '🌿';
      case 'Security':
        return '🛡️';
      case 'Sports':
        return '🏃';
      case 'Politics':
        return '🏛️';
      default:
        return '📰';
    }
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      summary: map['summary'] as String?,
      imageUrl: map['image_url'] as String?,
      author: map['author'] as String?,
      category: map['category'] as String?,
      tags:
          (map['tags'] as String?)?.split(',').map((t) => t.trim()).toList() ??
              [],
      views: map['views'] as int? ?? 0,
      likes: map['likes'] as int? ?? 0,
      isPublished: (map['is_published'] as int? ?? 1) == 1,
      publishedAt: map['published_at'] != null
          ? DateTime.parse(map['published_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'summary': summary,
        'image_url': imageUrl,
        'author': author,
        'category': category,
        'tags': tags.join(','),
        'views': views,
        'likes': likes,
        'is_published': isPublished ? 1 : 0,
        'published_at': publishedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
