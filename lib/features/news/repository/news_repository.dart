import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/news_model.dart';

class NewsRepository {
  NewsRepository._();
  static final NewsRepository instance = NewsRepository._();
  bool _seeded = false;

  Future<List<NewsModel>> getAll({String? category}) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> results;
    if (category != null && category != 'All') {
      results = await db.query(
        'news',
        where: 'category = ? AND is_published = 1',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
    } else {
      results = await db.query(
        'news',
        where: 'is_published = 1',
        orderBy: 'created_at DESC',
      );
    }
    return results.map((m) => NewsModel.fromMap(m)).toList();
  }

  Future<List<NewsModel>> search(String query) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'news',
      where:
          '(title LIKE ? OR summary LIKE ? OR category LIKE ?) AND is_published = 1',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => NewsModel.fromMap(m)).toList();
  }

  Future<NewsModel?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final results =
        await db.query('news', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isEmpty) return null;
    // increment views
    await db.rawUpdate('UPDATE news SET views = views + 1 WHERE id = ?', [id]);
    return NewsModel.fromMap(results.first);
  }

  Future<void> seedNews() async {
    if (_seeded) return;
    _seeded = true;
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    final articles = [
      {
        'id': 'n1',
        'title': 'New BRT Corridors to Launch on 5 Major Routes',
        'body':
            'The Nairobi Metropolitan Services has announced the launch of five new Bus Rapid Transit corridors set to begin operations next month. The routes will cover Thika Road, Ngong Road, Mombasa Road, Waiyaki Way, and Jogoo Road.\n\nThe BRT system is expected to reduce commute times by up to 40% for residents in affected areas. Each corridor will feature dedicated bus lanes, modern bus stops with real-time arrival information, and integrated payment systems compatible with M-Pesa and transit cards.\n\n"This is a game-changer for public transport in Nairobi," said the Transport Cabinet Secretary. "We expect over 200,000 commuters to benefit daily from this system."\n\nConstruction of supporting infrastructure including bus stops, park-and-ride facilities, and pedestrian bridges is already underway and expected to be complete by the end of the month.',
        'summary':
            'Five new BRT corridors launching next month on Nairobi\'s busiest routes, reducing commute times by up to 40%.',
        'author': 'City Desk Reporter',
        'category': 'Transport',
        'tags': 'BRT, Transport, Nairobi, Infrastructure',
        'views': 1240,
        'likes': 89,
        'is_published': 1,
        'published_at':
            now.subtract(const Duration(hours: 2)).toIso8601String(),
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'n2',
        'title':
            'Kenyatta National Hospital Opens State-of-the-Art Emergency Wing',
        'body':
            'Kenyatta National Hospital (KNH) officially opened its newly constructed emergency wing today, tripling the facility\'s emergency care capacity. The KES 2.3 billion facility was funded through a public-private partnership and features 120 emergency beds, three trauma theatres, and advanced diagnostic equipment.\n\nThe new wing includes a dedicated pediatric emergency section, a burns unit, and a trauma center equipped to handle the most critical cases. The facility also incorporates telemedicine capabilities, allowing specialists to provide remote consultation to patients across the country.\n\n"This facility sets a new standard for emergency healthcare in East Africa," said the Health Cabinet Secretary during the opening ceremony. "No Kenyan should die due to lack of emergency care."\n\nThe hospital has also recruited 200 additional healthcare workers including emergency physicians, nurses, and paramedics to staff the new wing.',
        'summary':
            'KNH\'s new emergency wing triples capacity with 120 beds, trauma theatres and state-of-the-art equipment.',
        'author': 'Health Correspondent',
        'category': 'Health',
        'tags': 'Health, Hospital, Nairobi, Healthcare',
        'views': 2100,
        'likes': 156,
        'is_published': 1,
        'published_at':
            now.subtract(const Duration(hours: 5)).toIso8601String(),
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'n3',
        'title': 'City Council Launches Free Wi-Fi in 50 Public Spaces',
        'body':
            'Nairobi City County has announced the installation of free public Wi-Fi hotspots in 50 locations across the city, including parks, bus terminuses, markets, and public squares. The initiative is part of the county\'s Smart City 2030 strategy.\n\nThe hotspots will provide speeds of up to 10 Mbps per user and will be available 24 hours a day. Users will need to register with their phone number to access the service, with each session limited to 2 hours before reconnection is required.\n\nThe initiative is expected to benefit students, small business owners, and commuters. "Digital access is no longer a luxury — it is a basic necessity," said the County Governor. "We are committed to ensuring every Nairobian has access to the digital economy."',
        'summary':
            'Free Wi-Fi coming to 50 public spaces across Nairobi as part of the Smart City 2030 initiative.',
        'author': 'Tech Reporter',
        'category': 'Technology',
        'tags': 'Wi-Fi, Technology, Smart City, Nairobi',
        'views': 3400,
        'likes': 287,
        'is_published': 1,
        'published_at':
            now.subtract(const Duration(hours: 8)).toIso8601String(),
        'created_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'n4',
        'title': 'New School Construction to Add 10,000 Learning Spaces',
        'body':
            'The Ministry of Education has announced a KES 5 billion initiative to construct and renovate schools across 10 counties, adding over 10,000 new learning spaces. The program targets counties with the highest classroom deficits.\n\nThe construction program will prioritize arid and semi-arid regions where access to quality education remains a challenge. In Nairobi, 15 public schools in informal settlements are earmarked for major renovation, including new classrooms, libraries, and computer labs.\n\n"Every child deserves a safe, modern learning environment," the Education CS said. "This investment will ensure that physical infrastructure is no longer a barrier to quality education in Kenya."',
        'summary':
            '10,000 new learning spaces to be created across 10 counties in a KES 5B education infrastructure initiative.',
        'author': 'Education Desk',
        'category': 'Education',
        'tags': 'Education, Schools, Infrastructure, Kenya',
        'views': 890,
        'likes': 67,
        'is_published': 1,
        'published_at':
            now.subtract(const Duration(hours: 12)).toIso8601String(),
        'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'n5',
        'title': 'Karura Forest Expands with 50-Acre Addition',
        'body':
            'The Kenya Forest Service has announced the formal gazettal of a 50-acre land parcel adjacent to Karura Forest, expanding the urban forest to its largest size in three decades. The land was acquired through a conservation agreement with a private developer.\n\nThe expansion will add new hiking trails, a wetland conservation area, and additional cycling paths. An outdoor amphitheatre and environmental education center are also planned for the new section, expected to be open to the public within 18 months.\n\n"Karura Forest is one of Nairobi\'s greatest assets," said the Environment CS. "This expansion ensures future generations will enjoy this green lung of the city."',
        'summary':
            'Karura Forest grows by 50 acres with new trails, wetland area and planned education centre.',
        'author': 'Environment Correspondent',
        'category': 'Environment',
        'tags': 'Environment, Karura, Nairobi, Conservation',
        'views': 1560,
        'likes': 203,
        'is_published': 1,
        'published_at':
            now.subtract(const Duration(hours: 18)).toIso8601String(),
        'created_at': now.subtract(const Duration(hours: 18)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'n6',
        'title': 'Nairobi Ranked Top African City for Startups',
        'body':
            'A new report by the African Business Council has ranked Nairobi as the top city for startups on the continent for the third consecutive year. The Silicon Savannah continues to attract record venture capital investment, with over \$600 million raised by Kenyan startups in the past year.\n\nThe report cites Nairobi\'s strong mobile money infrastructure, young tech-savvy population, supportive regulatory environment, and growing co-working space ecosystem as key factors. Fintech, agritech, and healthtech were identified as the fastest-growing sectors.\n\nNotable investments include a \$40M Series B for a Nairobi-based health insurance platform and a \$25M round for an agritech company connecting smallholder farmers to markets.',
        'summary':
            'Nairobi named Africa\'s top startup city for the third year running with \$600M+ in VC investment.',
        'author': 'Business Correspondent',
        'category': 'Business',
        'tags': 'Startups, Business, Nairobi, Technology',
        'views': 4200,
        'likes': 341,
        'is_published': 1,
        'published_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    ];

    for (final a in articles) {
      await db.insert('news', a, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
