import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/amenity_model.dart';

class AmenitiesRepository {
  AmenitiesRepository._();
  static final AmenitiesRepository instance = AmenitiesRepository._();

  static const String _table = 'amenities';

  // ── Get all amenities ──────────────────────────────────
  Future<List<AmenityModel>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      orderBy: 'name ASC',
    );
    return results.map((m) => AmenityModel.fromMap(m)).toList();
  }

  // ── Get by category ────────────────────────────────────
  Future<List<AmenityModel>> getByCategory(String category) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'rating DESC',
    );
    return results.map((m) => AmenityModel.fromMap(m)).toList();
  }

  // ── Search by name ─────────────────────────────────────
  Future<List<AmenityModel>> search(String query) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'name LIKE ? OR address LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'rating DESC',
    );
    return results.map((m) => AmenityModel.fromMap(m)).toList();
  }

  // ── Get single amenity ─────────────────────────────────
  Future<AmenityModel?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return AmenityModel.fromMap(results.first);
  }

  // ── Insert ─────────────────────────────────────────────
  Future<void> insert(AmenityModel amenity) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _table,
      amenity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Seed rich data for all categories ─────────────────
  Future<void> seedRichData() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    final amenities = [
      // Hospitals
      {
        'id': 'h1',
        'name': 'Kenyatta National Hospital',
        'category': 'hospital',
        'address': 'Hospital Rd, Nairobi',
        'latitude': -1.3017,
        'longitude': 36.8072,
        'phone': '+254720000001',
        'rating': 4.1,
        'rating_count': 312,
        'is_open': 1,
        'hours': '24 hours',
        'description': 'Kenya\'s largest referral hospital.',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'h2',
        'name': 'Nairobi Hospital',
        'category': 'hospital',
        'address': 'Argwings Kodhek Rd',
        'latitude': -1.2990,
        'longitude': 36.7916,
        'phone': '+254720000002',
        'rating': 4.5,
        'rating_count': 540,
        'is_open': 1,
        'hours': '24 hours',
        'description': 'Premier private hospital in Nairobi.',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'h3',
        'name': 'Aga Khan Hospital',
        'category': 'hospital',
        'address': '3rd Parklands Ave',
        'latitude': -1.2636,
        'longitude': 36.8163,
        'phone': '+254720000003',
        'rating': 4.7,
        'rating_count': 820,
        'is_open': 1,
        'hours': '24 hours',
        'created_at': now,
        'updated_at': now
      },
      // Schools
      {
        'id': 's1',
        'name': 'University of Nairobi',
        'category': 'school',
        'address': 'University Way',
        'latitude': -1.2793,
        'longitude': 36.8174,
        'phone': '+254720000004',
        'rating': 4.3,
        'rating_count': 1200,
        'is_open': 1,
        'hours': 'Mon-Fri 8am-5pm',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 's2',
        'name': 'Strathmore University',
        'category': 'school',
        'address': 'Ole Sangale Rd, Madaraka',
        'latitude': -1.3108,
        'longitude': 36.8121,
        'phone': '+254720000005',
        'rating': 4.6,
        'rating_count': 950,
        'is_open': 1,
        'hours': 'Mon-Fri 8am-5pm',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 's3',
        'name': 'Nairobi Primary School',
        'category': 'school',
        'address': 'Ngong Rd',
        'latitude': -1.2950,
        'longitude': 36.7800,
        'phone': '+254720000006',
        'rating': 4.0,
        'rating_count': 180,
        'is_open': 1,
        'hours': 'Mon-Fri 7am-4pm',
        'created_at': now,
        'updated_at': now
      },
      // Restaurants
      {
        'id': 'r1',
        'name': 'Carnivore Restaurant',
        'category': 'restaurant',
        'address': 'Langata Rd',
        'latitude': -1.3360,
        'longitude': 36.7745,
        'phone': '+254720000007',
        'rating': 4.4,
        'rating_count': 2100,
        'is_open': 1,
        'hours': '12pm-10pm daily',
        'description': 'Famous nyama choma and grills.',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'r2',
        'name': 'Java House',
        'category': 'restaurant',
        'address': 'Mama Ngina St',
        'latitude': -1.2864,
        'longitude': 36.8222,
        'phone': '+254720000008',
        'rating': 4.2,
        'rating_count': 1560,
        'is_open': 1,
        'hours': '7am-10pm daily',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'r3',
        'name': 'Artcaffe',
        'category': 'restaurant',
        'address': 'Village Market, Gigiri',
        'latitude': -1.2283,
        'longitude': 36.8086,
        'phone': '+254720000009',
        'rating': 4.3,
        'rating_count': 890,
        'is_open': 1,
        'hours': '8am-9pm daily',
        'created_at': now,
        'updated_at': now
      },
      // Police
      {
        'id': 'p1',
        'name': 'Central Police Station',
        'category': 'police',
        'address': 'University Way',
        'latitude': -1.2836,
        'longitude': 36.8221,
        'phone': '999',
        'rating': 3.5,
        'rating_count': 210,
        'is_open': 1,
        'hours': '24 hours',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'p2',
        'name': 'Parklands Police Station',
        'category': 'police',
        'address': '1st Parklands Ave',
        'latitude': -1.2611,
        'longitude': 36.8195,
        'phone': '999',
        'rating': 3.8,
        'rating_count': 145,
        'is_open': 1,
        'hours': '24 hours',
        'created_at': now,
        'updated_at': now
      },
      // Banks
      {
        'id': 'b1',
        'name': 'KCB Bank - Moi Ave',
        'category': 'bank',
        'address': 'Moi Avenue',
        'latitude': -1.2814961,
        'longitude': 36.8208872,
        'phone': '+254720000010',
        'rating': 4.0,
        'rating_count': 430,
        'is_open': 1,
        'hours': 'Mon-Fri 8am-4pm',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'b2',
        'name': 'Equity Bank HQ',
        'category': 'bank',
        'address': 'Hospital Rd',
        'latitude': -1.2880,
        'longitude': 36.8112,
        'phone': '+254720000011',
        'rating': 4.1,
        'rating_count': 380,
        'is_open': 1,
        'hours': 'Mon-Fri 8am-4pm',
        'created_at': now,
        'updated_at': now
      },
      // Pharmacies
      {
        'id': 'ph1',
        'name': 'Goodlife Pharmacy',
        'category': 'pharmacy',
        'address': 'Tom Mboya St',
        'latitude': -1.2868,
        'longitude': 36.8238,
        'phone': '+254720000012',
        'rating': 4.3,
        'rating_count': 290,
        'is_open': 1,
        'hours': '8am-9pm daily',
        'created_at': now,
        'updated_at': now
      },
      // Parks
      {
        'id': 'pk1',
        'name': 'Uhuru Park',
        'category': 'park',
        'address': 'Uhuru Highway',
        'latitude': -1.2901,
        'longitude': 36.8157,
        'phone': '',
        'rating': 4.5,
        'rating_count': 1800,
        'is_open': 1,
        'hours': '6am-6pm daily',
        'description': 'Iconic public park in the CBD.',
        'created_at': now,
        'updated_at': now
      },
      {
        'id': 'pk2',
        'name': 'Karura Forest',
        'category': 'park',
        'address': 'Limuru Rd, Gigiri',
        'latitude': -1.2375,
        'longitude': 36.8208,
        'phone': '+254720000013',
        'rating': 4.8,
        'rating_count': 3200,
        'is_open': 1,
        'hours': '6am-6pm daily',
        'description': 'Urban forest great for hiking and cycling.',
        'created_at': now,
        'updated_at': now
      },
    ];

    for (final a in amenities) {
      await db.insert(
        _table,
        a,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
