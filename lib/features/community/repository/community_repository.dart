import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../../../core/database/database_helper.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';

/// Posts and comments live in Firebase Realtime Database.
/// Groups, messages, and follows remain in local SQLite.
///
/// Realtime DB structure:
///   posts/
///     {postId}/          ← PostModel fields
///       comments/
///         {commentId}/   ← CommentModel fields
class CommunityRepository {
  CommunityRepository._();
  static final CommunityRepository instance = CommunityRepository._();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  DatabaseReference get _postsRef => _db.child('posts');
  DatabaseReference _commentsRef(String postId) =>
      _db.child('posts/$postId/comments');

  // ── POSTS: Realtime DB ─────────────────────────────────

  /// Stream of all posts, optionally filtered by county/constituency/group.
  Stream<List<PostModel>> postsStream({
    String? county,
    String? constituency,
    String? groupId,
  }) {
    // Order by created_at descending (Realtime DB only supports ascending,
    // so we reverse client-side after limiting to 100).
    final query = _postsRef.orderByChild('created_at').limitToLast(100);

    return query.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final map = Map<dynamic, dynamic>.from(data as Map);
      final posts = map.entries
          .where((e) => e.value is Map)
          .map((e) => PostModel.fromRealtimeDb(
                Map<dynamic, dynamic>.from(e.value as Map),
                e.key as String,
              ))
          .where((post) {
        // Client-side filter (Realtime DB has limited compound queries)
        if (county != null && county != 'All' && post.county != county) {
          return false;
        }
        if (constituency != null &&
            constituency.isNotEmpty &&
            post.constituency != constituency) {
          return false;
        }
        if (groupId != null) {
          return post.groupId == groupId;
        } else {
          return post.groupId == null;
        }
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return posts;
    });
  }

  /// One-time fetch of posts by a specific user (for profile pages).
  Future<List<PostModel>> getPostsByUser(String userId) async {
    final snapshot =
        await _postsRef.orderByChild('user_id').equalTo(userId).get();

    if (!snapshot.exists || snapshot.value == null) return [];

    final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final posts = map.entries
        .where((e) => e.value is Map)
        .map((e) => PostModel.fromRealtimeDb(
              Map<dynamic, dynamic>.from(e.value as Map),
              e.key as String,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return posts;
  }

  /// Creates a new post in Realtime DB.
  /// [user] fields should be populated from the current AuthState before calling.
  Future<void> createPost(PostModel post) async {
    await _postsRef.child(post.id).set(post.toRealtimeDb());
  }

  /// Increments/decrements the like count on a post.
  Future<void> toggleLike(String postId, bool isLiked) async {
    final ref = _postsRef.child('$postId/likes');
    await ref.runTransaction((current) {
      final count = (current as int?) ?? 0;
      return Transaction.success(
          isLiked ? count + 1 : (count - 1).clamp(0, 999999));
    });
  }

  /// Deletes a post and all its comments.
  Future<void> deletePost(String postId) async {
    await _postsRef.child(postId).remove();
  }

  // ── COMMENTS: Realtime DB ──────────────────────────────

  /// Stream of comments for a given post, ordered oldest first.
  Stream<List<CommentModel>> commentsStream(String postId) {
    return _commentsRef(postId).orderByChild('created_at').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final map = Map<dynamic, dynamic>.from(data as Map);
      return map.entries
          .where((e) => e.value is Map)
          .map((e) => CommentModel.fromRealtimeDb(
                Map<dynamic, dynamic>.from(e.value as Map),
                e.key as String,
              ))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  /// Adds a comment and atomically increments the post's comment count.
  Future<void> addComment(CommentModel comment) async {
    // Write the comment
    await _commentsRef(comment.postId)
        .child(comment.id)
        .set(comment.toRealtimeDb());

    // Increment comments_count on the parent post
    final countRef = _postsRef.child('${comment.postId}/comments_count');
    await countRef.runTransaction((current) {
      return Transaction.success(((current as int?) ?? 0) + 1);
    });
  }

  /// Deletes a comment and decrements the post's comment count.
  Future<void> deleteComment(String postId, String commentId) async {
    await _commentsRef(postId).child(commentId).remove();
    final countRef = _postsRef.child('$postId/comments_count');
    await countRef.runTransaction((current) {
      final count = (current as int?) ?? 0;
      return Transaction.success((count - 1).clamp(0, 999999));
    });
  }

  // ── GROUPS: SQLite (unchanged) ─────────────────────────

  Future<List<GroupModel>> getGroups({String? county}) async {
    final db = await DatabaseHelper.instance.database;
    if (county != null && county != 'All') {
      final results = await db.query('community_groups',
          where: 'county = ?',
          whereArgs: [county],
          orderBy: 'member_count DESC');
      return results.map((m) => GroupModel.fromMap(m)).toList();
    }
    final results =
        await db.query('community_groups', orderBy: 'member_count DESC');
    return results.map((m) => GroupModel.fromMap(m)).toList();
  }

  Future<void> createGroup(GroupModel group) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('community_groups', group.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  // ── MESSAGES: SQLite (unchanged) ──────────────────────

  Future<List<MessageModel>> getMessages(String userId, String otherId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'messages',
      where:
          '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
      whereArgs: [userId, otherId, otherId, userId],
      orderBy: 'created_at ASC',
    );
    return results.map((m) => MessageModel.fromMap(m)).toList();
  }

  Future<void> sendMessage(MessageModel message) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('messages', message.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  // ── FOLLOWS: SQLite (unchanged) ───────────────────────

  Future<void> follow(String followerId, String followingId) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'follows',
      {
        'follower_id': followerId,
        'following_id': followingId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: sqflite.ConflictAlgorithm.ignore,
    );
  }

  Future<void> unfollow(String followerId, String followingId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'follows',
      where: 'follower_id = ? AND following_id = ?',
      whereArgs: [followerId, followingId],
    );
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'follows',
      where: 'follower_id = ? AND following_id = ?',
      whereArgs: [followerId, followingId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getFollowingIds(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'follows',
      columns: ['following_id'],
      where: 'follower_id = ?',
      whereArgs: [userId],
    );
    return results.map((r) => r['following_id'] as String).toList();
  }

  Future<List<String>> getFollowerIds(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'follows',
      columns: ['follower_id'],
      where: 'following_id = ?',
      whereArgs: [userId],
    );
    return results.map((r) => r['follower_id'] as String).toList();
  }

  Future<int> getFollowerCount(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM follows WHERE following_id = ?',
      [userId],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getFollowingCount(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM follows WHERE follower_id = ?',
      [userId],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ── SQLite TABLE SETUP (groups, messages, follows only) ─
  Future<void> createTables() async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS community_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        creator_id TEXT NOT NULL,
        member_count INTEGER DEFAULT 0,
        is_private INTEGER DEFAULT 0,
        county TEXT,
        constituency TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        sender_name TEXT,
        sender_initials TEXT,
        content TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS follows (
        follower_id TEXT NOT NULL,
        following_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (follower_id, following_id)
      )
    ''');
  }
}
