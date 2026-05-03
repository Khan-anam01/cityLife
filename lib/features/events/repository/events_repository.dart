import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/event_model.dart';

class EventsRepository {
  EventsRepository._();
  static final EventsRepository instance = EventsRepository._();

  static const String _table = 'events';

  Future<List<EventModel>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      orderBy: 'start_date ASC',
    );
    return results.map((m) => EventModel.fromMap(m)).toList();
  }

  Future<List<EventModel>> getUpcoming() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'start_date >= ?',
      whereArgs: [DateTime.now().toIso8601String()],
      orderBy: 'start_date ASC',
    );
    return results.map((m) => EventModel.fromMap(m)).toList();
  }

  Future<List<EventModel>> getByCategory(String category) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'start_date ASC',
    );
    return results.map((m) => EventModel.fromMap(m)).toList();
  }

  Future<List<EventModel>> search(String query) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'title LIKE ? OR venue LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'start_date ASC',
    );
    return results.map((m) => EventModel.fromMap(m)).toList();
  }

  Future<EventModel?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return EventModel.fromMap(results.first);
  }

  Future<List<EventModel>> getByOrganizerId(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'organizer_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return results.map((m) => EventModel.fromMap(m)).toList();
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insert(EventModel event) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _table,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> seedEvents() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    final events = [
      {
        'id': 'ev1',
        'title': 'Nairobi Music Festival',
        'description':
            'The biggest music festival in East Africa featuring top artists from across the continent. Enjoy live performances, food stalls, and cultural experiences.',
        'venue': 'Uhuru Gardens, Nairobi',
        'latitude': -1.3030,
        'longitude': 36.8157,
        'start_date':
            DateTime(now.year, now.month, now.day + 5, 14, 0).toIso8601String(),
        'end_date':
            DateTime(now.year, now.month, now.day + 5, 23, 0).toIso8601String(),
        'category': 'Music',
        'organizer': 'Nairobi Events Co.',
        'capacity': 5000,
        'price': 0.0,
        'is_free': 1,
        'attendees': 1240,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'ev2',
        'title': 'East Africa Tech Summit 2026',
        'description':
            'Connect with 500+ tech leaders, startups, and investors. Talks on AI, fintech, and the future of African tech.',
        'venue': 'KICC, Nairobi CBD',
        'latitude': -1.2882,
        'longitude': 36.8215,
        'start_date':
            DateTime(now.year, now.month, now.day + 10, 8, 0).toIso8601String(),
        'end_date': DateTime(now.year, now.month, now.day + 11, 17, 0)
            .toIso8601String(),
        'category': 'Technology',
        'organizer': 'TechHub Africa',
        'capacity': 500,
        'price': 2500.0,
        'is_free': 0,
        'attendees': 380,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'ev3',
        'title': 'Nairobi City Marathon',
        'description':
            'Annual 42km marathon through the streets of Nairobi. Categories for full marathon, half marathon, and 10km fun run.',
        'venue': 'Nyayo National Stadium',
        'latitude': -1.3060,
        'longitude': 36.8200,
        'start_date':
            DateTime(now.year, now.month, now.day + 14, 6, 0).toIso8601String(),
        'category': 'Sports',
        'organizer': 'Athletics Kenya',
        'capacity': 8000,
        'price': 1000.0,
        'is_free': 0,
        'attendees': 5600,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'ev4',
        'title': 'Food & Culture Festival',
        'description':
            'Celebrate Kenyan cuisine and culture with over 50 food vendors, cooking demos, and live traditional performances.',
        'venue': 'Village Market, Gigiri',
        'latitude': -1.2283,
        'longitude': 36.8086,
        'start_date':
            DateTime(now.year, now.month, now.day + 3, 10, 0).toIso8601String(),
        'end_date':
            DateTime(now.year, now.month, now.day + 4, 20, 0).toIso8601String(),
        'category': 'Food',
        'organizer': 'Kenya Tourism Board',
        'capacity': 2000,
        'price': 0.0,
        'is_free': 1,
        'attendees': 890,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'ev5',
        'title': 'Startup Pitch Night',
        'description':
            'Watch 10 promising startups pitch to a panel of top investors. Network with founders, VCs and the tech community.',
        'venue': 'iHub, Ngong Road',
        'latitude': -1.2990,
        'longitude': 36.7850,
        'start_date':
            DateTime(now.year, now.month, now.day + 7, 18, 0).toIso8601String(),
        'end_date':
            DateTime(now.year, now.month, now.day + 7, 21, 0).toIso8601String(),
        'category': 'Business',
        'organizer': 'iHub Nairobi',
        'capacity': 150,
        'price': 500.0,
        'is_free': 0,
        'attendees': 98,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'ev6',
        'title': 'Art Exhibition: African Futures',
        'description':
            'A contemporary art exhibition showcasing works from 30 East African artists exploring themes of identity and urbanization.',
        'venue': 'National Museum of Kenya',
        'latitude': -1.2716,
        'longitude': 36.8120,
        'start_date':
            DateTime(now.year, now.month, now.day + 1, 9, 0).toIso8601String(),
        'end_date': DateTime(now.year, now.month, now.day + 21, 17, 0)
            .toIso8601String(),
        'category': 'Arts',
        'organizer': 'National Museums of Kenya',
        'capacity': 300,
        'price': 200.0,
        'is_free': 0,
        'attendees': 145,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'ev7',
        'title': 'Community Clean-Up Drive',
        'description':
            'Join hands with fellow residents to clean up Karura Forest and surrounding areas. Equipment provided.',
        'venue': 'Karura Forest, Gigiri',
        'latitude': -1.2317,
        'longitude': 36.8117,
        'start_date':
            DateTime(now.year, now.month, now.day + 2, 7, 0).toIso8601String(),
        'end_date':
            DateTime(now.year, now.month, now.day + 2, 12, 0).toIso8601String(),
        'category': 'Community',
        'organizer': 'Nairobi City Council',
        'capacity': 500,
        'price': 0.0,
        'is_free': 1,
        'attendees': 210,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'ev8',
        'title': 'Women in Leadership Forum',
        'description':
            'Empowering women with tools, networks, and inspiration to lead across industries. Keynotes, panels and workshops.',
        'venue': 'Sarova Stanley, Nairobi',
        'latitude': -1.2842,
        'longitude': 36.8220,
        'start_date':
            DateTime(now.year, now.month, now.day + 18, 8, 0).toIso8601String(),
        'category': 'Education',
        'organizer': 'She Leads Africa',
        'capacity': 400,
        'price': 1500.0,
        'is_free': 0,
        'attendees': 320,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    ];

    for (final e in events) {
      await db.insert(
        _table,
        e,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
