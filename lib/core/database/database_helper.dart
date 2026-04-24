import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static const int _version = 3; // ← bumped to 3 to trigger migration
  static const String _dbName = 'citylife.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add missing columns to posts table
      final postCols = [
        'ALTER TABLE posts ADD COLUMN user_name TEXT',
        'ALTER TABLE posts ADD COLUMN user_initials TEXT',
        'ALTER TABLE posts ADD COLUMN reposts INTEGER DEFAULT 0',
        'ALTER TABLE posts ADD COLUMN is_liked INTEGER DEFAULT 0',
        'ALTER TABLE posts ADD COLUMN is_reposted INTEGER DEFAULT 0',
        'ALTER TABLE posts ADD COLUMN county TEXT',
        'ALTER TABLE posts ADD COLUMN constituency TEXT',
        'ALTER TABLE posts ADD COLUMN group_id TEXT',
      ];
      for (final sql in postCols) {
        try {
          await db.execute(sql);
        } catch (_) {}
      }

      // Add missing columns to comments table
      final commentCols = [
        'ALTER TABLE comments ADD COLUMN user_name TEXT',
        'ALTER TABLE comments ADD COLUMN user_initials TEXT',
        'ALTER TABLE comments ADD COLUMN is_liked INTEGER DEFAULT 0',
      ];
      for (final sql in commentCols) {
        try {
          await db.execute(sql);
        } catch (_) {}
      }

      // Create community_groups table
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

      // Create messages table
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
    }

    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS follows (
        follower_id  TEXT NOT NULL,
        following_id TEXT NOT NULL,
        created_at   TEXT NOT NULL,
        PRIMARY KEY (follower_id, following_id)
      )
    ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id)',
      );
    }
  }

  Future<void> _createTables(Database db) async {
    // ── Users ────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.users} (
        id            TEXT PRIMARY KEY,
        email         TEXT NOT NULL UNIQUE,
        display_name  TEXT,
        photo_url     TEXT,
        role          TEXT NOT NULL DEFAULT 'user',
        phone         TEXT,
        bio           TEXT,
        is_verified   INTEGER NOT NULL DEFAULT 0,
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL
      )
    ''');

    // ── Amenities ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.amenities} (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        category      TEXT NOT NULL,
        address       TEXT,
        latitude      REAL,
        longitude     REAL,
        phone         TEXT,
        contact_email TEXT,
        website       TEXT,
        hours         TEXT,
        rating        REAL DEFAULT 0,
        rating_count  INTEGER DEFAULT 0,
        is_open       INTEGER DEFAULT 1,
        description   TEXT,
        image_url     TEXT,
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL
      )
    ''');

    // ── Events ───────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.events} (
        id              TEXT PRIMARY KEY,
        title           TEXT NOT NULL,
        description     TEXT,
        venue           TEXT NOT NULL,
        latitude        REAL,
        longitude       REAL,
        start_date      TEXT NOT NULL,
        end_date        TEXT,
        category        TEXT,
        image_url       TEXT,
        organizer       TEXT,
        capacity        INTEGER,
        price           REAL DEFAULT 0,
        is_free         INTEGER DEFAULT 1,
        attendees       INTEGER DEFAULT 0,
        created_at      TEXT NOT NULL,
        updated_at      TEXT NOT NULL
      )
    ''');

    // ── News ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.news} (
        id            TEXT PRIMARY KEY,
        title         TEXT NOT NULL,
        body          TEXT NOT NULL,
        summary       TEXT,
        image_url     TEXT,
        author        TEXT,
        category      TEXT,
        tags          TEXT,
        views         INTEGER DEFAULT 0,
        likes         INTEGER DEFAULT 0,
        is_published  INTEGER DEFAULT 1,
        published_at  TEXT,
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL
      )
    ''');

    // ── Posts (Social) — full schema with community cols ─
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.posts} (
        id              TEXT PRIMARY KEY,
        user_id         TEXT NOT NULL,
        user_name       TEXT,
        user_initials   TEXT,
        content         TEXT NOT NULL,
        image_url       TEXT,
        likes           INTEGER DEFAULT 0,
        comments_count  INTEGER DEFAULT 0,
        reposts         INTEGER DEFAULT 0,
        is_liked        INTEGER DEFAULT 0,
        is_reposted     INTEGER DEFAULT 0,
        county          TEXT,
        constituency    TEXT,
        group_id        TEXT,
        latitude        REAL,
        longitude       REAL,
        created_at      TEXT NOT NULL,
        updated_at      TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DBTables.users}(id)
      )
    ''');

    // ── Comments — full schema ────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.comments} (
        id              TEXT PRIMARY KEY,
        post_id         TEXT NOT NULL,
        user_id         TEXT NOT NULL,
        user_name       TEXT,
        user_initials   TEXT,
        content         TEXT NOT NULL,
        likes           INTEGER DEFAULT 0,
        is_liked        INTEGER DEFAULT 0,
        created_at      TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES ${DBTables.posts}(id),
        FOREIGN KEY (user_id) REFERENCES ${DBTables.users}(id)
      )
    ''');

    // ── Jobs ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.jobs} (
        id            TEXT PRIMARY KEY,
        title         TEXT NOT NULL,
        company       TEXT NOT NULL,
        description   TEXT NOT NULL,
        location      TEXT,
        salary        TEXT,
        type          TEXT,
        category      TEXT,
        skills        TEXT,
        deadline      TEXT,
        is_remote     INTEGER DEFAULT 0,
        logo_url      TEXT,
        apply_url     TEXT,
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL
      )
    ''');

    // ── City Reports ─────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.reports} (
        id            TEXT PRIMARY KEY,
        user_id       TEXT NOT NULL,
        title         TEXT NOT NULL,
        description   TEXT NOT NULL,
        category      TEXT NOT NULL,
        status        TEXT NOT NULL DEFAULT 'pending',
        latitude      REAL NOT NULL,
        longitude     REAL NOT NULL,
        address       TEXT,
        image_url     TEXT,
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DBTables.users}(id)
      )
    ''');

    // ── Notifications ────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.notifications} (
        id          TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL,
        title       TEXT NOT NULL,
        body        TEXT NOT NULL,
        type        TEXT,
        payload     TEXT,
        is_read     INTEGER DEFAULT 0,
        created_at  TEXT NOT NULL
      )
    ''');

    // ── Bookmarks ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBTables.bookmarks} (
        id          TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL,
        item_id     TEXT NOT NULL,
        item_type   TEXT NOT NULL,
        created_at  TEXT NOT NULL,
        UNIQUE(user_id, item_id, item_type)
      )
    ''');

    // ── Community Groups ─────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS community_groups (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        description   TEXT,
        image_url     TEXT,
        creator_id    TEXT NOT NULL,
        member_count  INTEGER DEFAULT 0,
        is_private    INTEGER DEFAULT 0,
        county        TEXT,
        constituency  TEXT,
        created_at    TEXT NOT NULL
      )
    ''');

    // ── Direct Messages ──────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id              TEXT PRIMARY KEY,
        sender_id       TEXT NOT NULL,
        receiver_id     TEXT NOT NULL,
        sender_name     TEXT,
        sender_initials TEXT,
        content         TEXT NOT NULL,
        is_read         INTEGER DEFAULT 0,
        created_at      TEXT NOT NULL
      )
    ''');

    // ── Follows ──────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS follows (
        follower_id  TEXT NOT NULL,
        following_id TEXT NOT NULL,
        created_at   TEXT NOT NULL,
        PRIMARY KEY (follower_id, following_id)
      )
    ''');

    // ── Indexes ──────────────────────────────────────────
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_posts_user ON ${DBTables.posts}(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_posts_county ON ${DBTables.posts}(county)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_amenities_cat ON ${DBTables.amenities}(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_events_date ON ${DBTables.events}(start_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_jobs_cat ON ${DBTables.jobs}(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_comments_post ON ${DBTables.comments}(post_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id)',
    );
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    final amenities = [
      {
        'id': 'a1',
        'name': 'City General Hospital',
        'category': 'hospital',
        'address': '123 Health Ave',
        'latitude': -1.2921,
        'longitude': 36.8219,
        'phone': '+254700000001',
        'rating': 4.2,
        'rating_count': 128,
        'is_open': 1,
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'a2',
        'name': 'Nairobi Central School',
        'category': 'school',
        'address': '45 Education Rd',
        'latitude': -1.2865,
        'longitude': 36.8123,
        'phone': '+254700000002',
        'rating': 4.5,
        'rating_count': 89,
        'is_open': 1,
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'a3',
        'name': 'Central Police Station',
        'category': 'police',
        'address': '1 Justice Blvd',
        'latitude': -1.2890,
        'longitude': 36.8172,
        'phone': '+254700000003',
        'rating': 3.8,
        'rating_count': 45,
        'is_open': 1,
        'created_at': now,
        'updated_at': now
      },
    ];

    for (final a in amenities) {
      await db.insert(DBTables.amenities, a,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
