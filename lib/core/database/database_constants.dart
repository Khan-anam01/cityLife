/// Database table names
abstract class DBTables {
  static const String users = 'users';
  static const String amenities = 'amenities';
  static const String events = 'events';
  static const String news = 'news';
  static const String posts = 'posts';
  static const String comments = 'comments';
  static const String jobs = 'jobs';
  static const String reports = 'reports';
  static const String notifications = 'notifications';
  static const String bookmarks = 'bookmarks';
}

/// Shared column names across tables
abstract class DBCols {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String postId = 'post_id';
  static const String itemId = 'item_id';
  static const String itemType = 'item_type';
  static const String name = 'name';
  static const String venue = 'venue';

  // User fields
  static const String email = 'email';
  static const String displayName = 'display_name';
  static const String photoUrl = 'photo_url';
  static const String role = 'role';
  static const String bio = 'bio';
  static const String isVerified = 'is_verified';

  // Common content fields
  static const String title = 'title';
  static const String body = 'body';
  static const String content = 'content';
  static const String description = 'description';
  static const String summary = 'summary';
  static const String category = 'category';
  static const String tags = 'tags';
  static const String imageUrl = 'image_url';
  static const String logoUrl = 'logo_url';
  static const String status = 'status';
  static const String author = 'author';
  static const String organizer = 'organizer';

  // Contact fields
  static const String phone = 'phone';
  static const String email2 = 'contact_email';
  static const String website = 'website';
  static const String address = 'address';
  static const String location = 'location';
  static const String applyUrl = 'apply_url';

  // Location fields
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';

  // Numeric/stats fields
  static const String rating = 'rating';
  static const String ratingCount = 'rating_count';
  static const String likes = 'likes';
  static const String comments = 'comments_count';
  static const String views = 'views';
  static const String attendees = 'attendees';
  static const String capacity = 'capacity';
  static const String price = 'price';
  static const String salary = 'salary';

  // Boolean fields
  static const String isOpen = 'is_open';
  static const String isFree = 'is_free';
  static const String isRemote = 'is_remote';
  static const String isPublished = 'is_published';
  static const String isRead = 'is_read';

  // Date fields
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String deadline = 'deadline';
  static const String publishedAt = 'published_at';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // Misc
  static const String type = 'type';
  static const String skills = 'skills';
  static const String company = 'company';
  static const String hours = 'hours';
  static const String payload = 'payload';
}
