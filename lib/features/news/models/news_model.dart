import 'package:cloud_firestore/cloud_firestore.dart';

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

  // ── Time Ago Display ─────────────────────────────────────
  String get timeAgo {
    final date = publishedAt ?? createdAt;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  // ── Category Emoji ───────────────────────────────────────
  String get categoryEmoji {
    switch (category?.toLowerCase()) {
      case 'transport':
        return '🚌';
      case 'health':
        return '🏥';
      case 'education':
        return '🎓';
      case 'technology':
        return '💻';
      case 'business':
        return '💼';
      case 'environment':
        return '🌿';
      case 'security':
        return '🛡️';
      case 'sports':
        return '🏃';
      case 'politics':
        return '🏛️';
      default:
        return '📰';
    }
  }

  // ── SQLite Support (Existing) ────────────────────────────
  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      summary: map['summary'] as String?,
      imageUrl: map['image_url'] as String?,
      author: map['author'] as String?,
      category: map['category'] as String?,
      tags: (map['tags'] as String?)
              ?.split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList() ??
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

  // ── Firestore Support ────────────────────────────────────
  factory NewsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return NewsModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      summary: data['summary'] as String?,
      imageUrl: data['image_url'] as String?,
      author: data['author'] as String?,
      category: data['category'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      views: data['views'] as int? ?? 0,
      likes: data['likes'] as int? ?? 0,
      isPublished: data['is_published'] as bool? ?? true,
      publishedAt: (data['published_at'] as Timestamp?)?.toDate(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'summary': summary,
      'image_url': imageUrl,
      'author': author,
      'category': category,
      'tags': tags,
      'views': views,
      'likes': likes,
      'is_published': isPublished,
      'published_at':
          publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // ── CopyWith for easy updates ────────────────────────────
  NewsModel copyWith({
    String? id,
    String? title,
    String? body,
    String? summary,
    String? imageUrl,
    String? author,
    String? category,
    List<String>? tags,
    int? views,
    int? likes,
    bool? isPublished,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
