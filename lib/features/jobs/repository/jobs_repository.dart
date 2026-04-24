import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/job_model.dart';

class JobsRepository {
  JobsRepository._();
  static final JobsRepository instance = JobsRepository._();
  bool _seeded = false;

  Future<List<JobModel>> getAll({String? category, String? type}) async {
    final db = await DatabaseHelper.instance.database;
    String where = '1=1';
    List<dynamic> args = [];
    if (category != null && category != 'All') {
      where += ' AND category = ?';
      args.add(category);
    }
    if (type != null && type != 'All') {
      where += ' AND type = ?';
      args.add(type);
    }
    final results = await db.query(
      'jobs',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
    );
    return results.map((m) => JobModel.fromMap(m)).toList();
  }

  Future<List<JobModel>> search(String query) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'jobs',
      where:
          'title LIKE ? OR company LIKE ? OR skills LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => JobModel.fromMap(m)).toList();
  }

  Future<JobModel?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final results =
        await db.query('jobs', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isEmpty) return null;
    return JobModel.fromMap(results.first);
  }

  Future<void> seedJobs() async {
    if (_seeded) return;
    _seeded = true;
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final deadline = now.add(const Duration(days: 14));
    final deadline2 = now.add(const Duration(days: 7));
    final deadline3 = now.add(const Duration(days: 21));

    final jobs = [
      {
        'id': 'j1',
        'title': 'Flutter Developer',
        'company': 'Safaricom PLC',
        'description':
            'We are looking for an experienced Flutter developer to join our digital products team. You will build and maintain mobile applications used by millions of Kenyans.\n\nResponsibilities:\n• Design and build advanced mobile applications\n• Collaborate with cross-functional teams\n• Ensure performance and quality\n• Identify and fix bottlenecks and bugs',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 150,000 - 250,000/mo',
        'type': 'full-time',
        'category': 'Technology',
        'skills': 'Flutter, Dart, Firebase, REST APIs, Git',
        'deadline': deadline.toIso8601String(),
        'is_remote': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j2',
        'title': 'Digital Marketing Manager',
        'company': 'Jumia Kenya',
        'description':
            'Drive Jumia Kenya\'s digital marketing strategy across all online channels. Manage campaigns, analyze performance metrics, and grow our customer base.\n\nKey Requirements:\n• 3+ years digital marketing experience\n• Proficiency in Google Ads, Meta Ads\n• Strong analytical skills\n• Experience with e-commerce platforms',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 120,000 - 180,000/mo',
        'type': 'full-time',
        'category': 'Marketing',
        'skills': 'SEO, SEM, Google Analytics, Facebook Ads, Content Marketing',
        'deadline': deadline2.toIso8601String(),
        'is_remote': 1,
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j3',
        'title': 'Civil Engineer',
        'company': 'Kenya National Highways Authority',
        'description':
            'Join KeNHA in designing and supervising road construction projects across Kenya. This is a great opportunity to contribute to Kenya\'s infrastructure development.\n\nRequirements:\n• BSc Civil Engineering\n• 2+ years experience\n• AutoCAD proficiency\n• Valid engineering board registration',
        'location': 'Nairobi / Field',
        'salary': 'KES 90,000 - 140,000/mo',
        'type': 'full-time',
        'category': 'Engineering',
        'skills':
            'AutoCAD, Structural Analysis, Project Management, Road Design',
        'deadline': deadline3.toIso8601String(),
        'is_remote': 0,
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j4',
        'title': 'Data Analyst Intern',
        'company': 'M-Pesa Africa',
        'description':
            'Exciting internship opportunity at M-Pesa Africa\'s data team. Work with real financial data to generate insights that drive business decisions.\n\nWhat you\'ll do:\n• Analyze large datasets\n• Create dashboards and reports\n• Support the analytics team\n• Present findings to stakeholders',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 40,000 - 60,000/mo',
        'type': 'internship',
        'category': 'Technology',
        'skills': 'Python, SQL, Power BI, Excel, Statistics',
        'deadline': deadline2.toIso8601String(),
        'is_remote': 0,
        'created_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j5',
        'title': 'Registered Nurse',
        'company': 'Aga Khan Hospital',
        'description':
            'Aga Khan Hospital is seeking dedicated nurses to join our team. You will provide high-quality patient care in a supportive, well-equipped environment.\n\nRequirements:\n• Kenya Registered Nurse certificate\n• Valid nursing council license\n• 1+ year experience preferred\n• Strong patient care skills',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 70,000 - 100,000/mo',
        'type': 'full-time',
        'category': 'Healthcare',
        'skills': 'Patient Care, IV Therapy, Wound Care, EMR Systems',
        'deadline': deadline.toIso8601String(),
        'is_remote': 0,
        'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j6',
        'title': 'UI/UX Designer',
        'company': 'Equity Bank',
        'description':
            'Design intuitive digital banking experiences for millions of Equity Bank customers. Work closely with product and engineering teams.\n\nYour role:\n• Create wireframes and prototypes\n• Conduct user research\n• Design responsive interfaces\n• Maintain design systems',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 100,000 - 160,000/mo',
        'type': 'full-time',
        'category': 'Design',
        'skills': 'Figma, Adobe XD, User Research, Prototyping, Design Systems',
        'deadline': deadline3.toIso8601String(),
        'is_remote': 1,
        'created_at': now.subtract(const Duration(hours: 18)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j7',
        'title': 'Secondary School Teacher (Math)',
        'company': 'Alliance High School',
        'description':
            'Teach mathematics to Form 1-4 students at one of Kenya\'s most prestigious schools. Opportunity to shape the next generation of leaders.\n\nRequirements:\n• BEd Mathematics or BSc + PGDE\n• TSC registration\n• 2+ years teaching experience\n• Passion for student development',
        'location': 'Kikuyu, Kiambu',
        'salary': 'KES 60,000 - 90,000/mo',
        'type': 'full-time',
        'category': 'Education',
        'skills':
            'Mathematics, Curriculum Development, Student Assessment, KCSE Prep',
        'deadline': deadline.toIso8601String(),
        'is_remote': 0,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j8',
        'title': 'Freelance Content Writer',
        'company': 'NairobiWire Media',
        'description':
            'Write compelling articles, blog posts, and social content for a leading Kenyan digital media platform. Flexible hours, work from anywhere.\n\nTopics: News, Tech, Business, Lifestyle, Sports\n\nPay: Per article basis\nMinimum: 3 articles/week',
        'location': 'Remote',
        'salary': 'KES 2,000 - 5,000/article',
        'type': 'freelance',
        'category': 'Media',
        'skills': 'Writing, Research, SEO Writing, Journalism, Social Media',
        'deadline': deadline3.toIso8601String(),
        'is_remote': 1,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    ];

    for (final j in jobs) {
      await db.insert('jobs', j, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
