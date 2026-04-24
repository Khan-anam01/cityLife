import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';

class CommunityRepository {
  CommunityRepository._();
  static final CommunityRepository instance = CommunityRepository._();

  bool _seeded = false;

  // ── POSTS ──────────────────────────────────────────────
  Future<List<PostModel>> getPosts({
    String? county,
    String? constituency,
    String? groupId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    String where = '1=1';
    List<dynamic> args = [];

    if (county != null && county != 'All') {
      where += ' AND county = ?';
      args.add(county);
    }
    if (constituency != null && constituency.isNotEmpty) {
      where += ' AND constituency = ?';
      args.add(constituency);
    }
    if (groupId != null) {
      where += ' AND group_id = ?';
      args.add(groupId);
    } else {
      where += ' AND group_id IS NULL';
    }

    final results = await db.query(
      'posts',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
    );
    return results.map((m) => PostModel.fromMap(m)).toList();
  }

  /// Posts from users the [currentUserId] follows.
  Future<List<PostModel>> getFollowingPosts(String currentUserId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT p.* FROM posts p
      INNER JOIN follows f ON f.following_id = p.user_id
      WHERE f.follower_id = ?
        AND p.group_id IS NULL
      ORDER BY p.created_at DESC
      ''',
      [currentUserId],
    );
    return results.map((m) => PostModel.fromMap(m)).toList();
  }

  Future<void> createPost(PostModel post) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('posts', post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    final db = await DatabaseHelper.instance.database;
    final post =
        await db.query('posts', where: 'id = ?', whereArgs: [postId], limit: 1);
    if (post.isEmpty) return;
    final current = post.first['likes'] as int? ?? 0;
    await db.update(
      'posts',
      {
        'likes': isLiked ? current + 1 : (current - 1).clamp(0, 999999),
        'is_liked': isLiked ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<void> deletePost(String postId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('posts', where: 'id = ?', whereArgs: [postId]);
  }

  // ── COMMENTS ───────────────────────────────────────────
  Future<List<CommentModel>> getComments(String postId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'comments',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at ASC',
    );
    return results.map((m) => CommentModel.fromMap(m)).toList();
  }

  Future<void> addComment(CommentModel comment) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('comments', comment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.rawUpdate(
      'UPDATE posts SET comments_count = comments_count + 1 WHERE id = ?',
      [comment.postId],
    );
  }

  // ── FOLLOWS ────────────────────────────────────────────

  /// Follow [targetUserId] as [currentUserId].
  Future<void> follow(String currentUserId, String targetUserId) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'follows',
      {
        'follower_id': currentUserId,
        'following_id': targetUserId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Unfollow [targetUserId] as [currentUserId].
  Future<void> unfollow(String currentUserId, String targetUserId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'follows',
      where: 'follower_id = ? AND following_id = ?',
      whereArgs: [currentUserId, targetUserId],
    );
  }

  /// Returns the IDs of users that [userId] is following.
  Future<List<String>> getFollowingIds(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'follows',
      columns: ['following_id'],
      where: 'follower_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['following_id'] as String).toList();
  }

  /// Returns the IDs of users that follow [userId].
  Future<List<String>> getFollowerIds(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'follows',
      columns: ['follower_id'],
      where: 'following_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['follower_id'] as String).toList();
  }

  /// Returns true if [currentUserId] follows [targetUserId].
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'follows',
      where: 'follower_id = ? AND following_id = ?',
      whereArgs: [currentUserId, targetUserId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  // ── GROUPS ─────────────────────────────────────────────
  Future<List<GroupModel>> getGroups({String? county}) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> results;
    if (county != null && county != 'All') {
      results = await db.query(
        'community_groups',
        where: 'county = ?',
        whereArgs: [county],
        orderBy: 'member_count DESC',
      );
    } else {
      results = await db.query(
        'community_groups',
        orderBy: 'member_count DESC',
      );
    }
    return results.map((m) => GroupModel.fromMap(m)).toList();
  }

  Future<void> createGroup(GroupModel group) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('community_groups', group.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── MESSAGES ───────────────────────────────────────────
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
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── TABLES ─────────────────────────────────────────────
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

    // ── NEW: follows table ─────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS follows (
        follower_id TEXT NOT NULL,
        following_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (follower_id, following_id)
      )
    ''');

    // Add extra columns to posts if missing
    try {
      await db.execute('ALTER TABLE posts ADD COLUMN user_name TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE posts ADD COLUMN user_initials TEXT');
    } catch (_) {}
    try {
      await db
          .execute('ALTER TABLE posts ADD COLUMN reposts INTEGER DEFAULT 0');
    } catch (_) {}
    try {
      await db
          .execute('ALTER TABLE posts ADD COLUMN is_liked INTEGER DEFAULT 0');
    } catch (_) {}
    try {
      await db.execute(
          'ALTER TABLE posts ADD COLUMN is_reposted INTEGER DEFAULT 0');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE posts ADD COLUMN county TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE posts ADD COLUMN constituency TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE posts ADD COLUMN group_id TEXT');
    } catch (_) {}

    // Add extra columns to comments if missing
    try {
      await db.execute('ALTER TABLE comments ADD COLUMN user_name TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE comments ADD COLUMN user_initials TEXT');
    } catch (_) {}
    try {
      await db.execute(
          'ALTER TABLE comments ADD COLUMN is_liked INTEGER DEFAULT 0');
    } catch (_) {}
  }

  // ── SEED DATA ──────────────────────────────────────────
  Future<void> seedCommunity() async {
    if (_seeded) return;
    _seeded = true;
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    final users = [
      {
        'id': 'u1',
        'email': 'james@citylife.app',
        'display_name': 'James Mwangi',
        'role': 'user',
        'is_verified': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'u2',
        'email': 'amina@citylife.app',
        'display_name': 'Amina Hassan',
        'role': 'user',
        'is_verified': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'u3',
        'email': 'peter@citylife.app',
        'display_name': 'Peter Otieno',
        'role': 'user',
        'is_verified': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'u4',
        'email': 'grace@citylife.app',
        'display_name': 'Grace Wanjiru',
        'role': 'user',
        'is_verified': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'u5',
        'email': 'hassan@citylife.app',
        'display_name': 'Hassan Ali',
        'role': 'user',
        'is_verified': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'u6',
        'email': 'faith@citylife.app',
        'display_name': 'Faith Achieng',
        'role': 'user',
        'is_verified': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String()
      },
    ];
    for (final u in users) {
      await db.insert('users', u, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final groups = [
      {
        'id': 'g1',
        'name': 'Nairobi Residents Forum',
        'description':
            'A space for all Nairobi residents to discuss city matters.',
        'creator_id': 'system',
        'member_count': 1240,
        'is_private': 0,
        'county': 'Nairobi',
        'created_at': now.toIso8601String()
      },
      {
        'id': 'g2',
        'name': 'Westlands Community',
        'description': 'Everything happening in Westlands constituency.',
        'creator_id': 'system',
        'member_count': 450,
        'is_private': 0,
        'county': 'Nairobi',
        'constituency': 'Westlands',
        'created_at': now.toIso8601String()
      },
      {
        'id': 'g3',
        'name': 'Nairobi Tech Hub',
        'description': 'Tech professionals and startups in Nairobi.',
        'creator_id': 'system',
        'member_count': 890,
        'is_private': 0,
        'county': 'Nairobi',
        'created_at': now.toIso8601String()
      },
      {
        'id': 'g4',
        'name': 'Mombasa Pwani Network',
        'description': 'Coast region community discussions.',
        'creator_id': 'system',
        'member_count': 620,
        'is_private': 0,
        'county': 'Mombasa',
        'created_at': now.toIso8601String()
      },
      {
        'id': 'g5',
        'name': 'Kisumu Business Network',
        'description': 'Business owners and entrepreneurs in Kisumu.',
        'creator_id': 'system',
        'member_count': 380,
        'is_private': 0,
        'county': 'Kisumu',
        'created_at': now.toIso8601String()
      },
    ];
    for (final g in groups) {
      await db.insert('community_groups', g,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final posts = [
      {
        'id': 'p1',
        'user_id': 'u1',
        'user_name': 'James Mwangi',
        'user_initials': 'JM',
        'content':
            'The new BRT lanes on Thika Road have significantly reduced my commute time from Roysambu. What do others think? 🚌',
        'likes': 42,
        'comments_count': 8,
        'reposts': 5,
        'is_liked': 0,
        'county': 'Nairobi',
        'constituency': 'Roysambu',
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'p2',
        'user_id': 'u2',
        'user_name': 'Amina Hassan',
        'user_initials': 'AH',
        'content':
            'Kenyatta National Hospital just opened a new emergency wing. This is a huge win for public health in Nairobi! The capacity has tripled. 🏥',
        'likes': 128,
        'comments_count': 23,
        'reposts': 34,
        'is_liked': 0,
        'county': 'Nairobi',
        'created_at': now.subtract(const Duration(hours: 4)).toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'p3',
        'user_id': 'u3',
        'user_name': 'Peter Otieno',
        'user_initials': 'PO',
        'content':
            'Street lights in Westlands have been off for 3 weeks now. I\'ve filed a report on the app. Who else is experiencing this? Let\'s escalate. 💡',
        'likes': 67,
        'comments_count': 15,
        'reposts': 12,
        'is_liked': 0,
        'county': 'Nairobi',
        'constituency': 'Westlands',
        'created_at': now.subtract(const Duration(hours: 6)).toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'p4',
        'user_id': 'u4',
        'user_name': 'Grace Wanjiru',
        'user_initials': 'GW',
        'content':
            'Just attended the Tech Summit at KICC. The innovations coming from Kenyan startups are absolutely 🔥. Proud to be part of this ecosystem!',
        'likes': 95,
        'comments_count': 11,
        'reposts': 20,
        'is_liked': 0,
        'county': 'Nairobi',
        'created_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'p5',
        'user_id': 'u5',
        'user_name': 'Hassan Ali',
        'user_initials': 'HA',
        'content':
            'Mombasa port expansion is bringing thousands of jobs. If you\'re in logistics or maritime, now is the time to apply. Links in comments 👇',
        'likes': 203,
        'comments_count': 45,
        'reposts': 89,
        'is_liked': 0,
        'county': 'Mombasa',
        'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'p6',
        'user_id': 'u6',
        'user_name': 'Faith Achieng',
        'user_initials': 'FA',
        'content':
            'Kisumu lakeside cleanup was a success! Over 500 volunteers showed up. The lake is looking cleaner already 🌊. Same time next month?',
        'likes': 156,
        'comments_count': 28,
        'reposts': 42,
        'is_liked': 0,
        'county': 'Kisumu',
        'created_at': now.subtract(const Duration(hours: 18)).toIso8601String(),
        'updated_at': now.toIso8601String()
      },
    ];
    for (final p in posts) {
      await db.insert('posts', p, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final comments = [
      {
        'id': 'c1',
        'post_id': 'p1',
        'user_id': 'u2',
        'user_name': 'Amina Hassan',
        'user_initials': 'AH',
        'content':
            'Totally agree! My commute from Ruiru dropped from 90 mins to 45 mins 🙌',
        'likes': 12,
        'is_liked': 0,
        'created_at': now.subtract(const Duration(hours: 1)).toIso8601String()
      },
      {
        'id': 'c2',
        'post_id': 'p1',
        'user_id': 'u3',
        'user_name': 'Peter Otieno',
        'user_initials': 'PO',
        'content':
            'The BRT on Ngong Road needs to come next. The traffic there is unbearable.',
        'likes': 8,
        'is_liked': 0,
        'created_at':
            now.subtract(const Duration(minutes: 45)).toIso8601String()
      },
      {
        'id': 'c3',
        'post_id': 'p2',
        'user_id': 'u1',
        'user_name': 'James Mwangi',
        'user_initials': 'JM',
        'content': 'This is excellent news. The old ER was always overwhelmed.',
        'likes': 18,
        'is_liked': 0,
        'created_at': now.subtract(const Duration(hours: 3)).toIso8601String()
      },
    ];
    for (final c in comments) {
      await db.insert('comments', c,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
