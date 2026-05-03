import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/firestore_service.dart';
import '../../../shared/models/user_model.dart';
import '../models/job_model.dart';

class JobsRepository {
  JobsRepository._();
  static final JobsRepository instance = JobsRepository._();
  bool _seeded = false;

  // ── READ ───────────────────────────────────────────────

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

  /// Returns all jobs posted by a specific company user.
  Future<List<JobModel>> getByPoster(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'jobs',
      where: 'posted_by_id = ?',
      whereArgs: [userId],
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

  // ── WRITE (company accounts only) ─────────────────────

  /// Posts a new job listing. Throws if [poster] is not a company account.
  Future<void> postJob(JobModel job, {required UserModel poster}) async {
    if (poster.role != UserRole.company) {
      throw Exception(
        'Only company accounts can post job listings. '
        'Please upgrade your account to a Business account.',
      );
    }
    // ── 1. Local cache (SQLite) ────────────────────────
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'jobs',
      job.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // ── 2. Remote (Firestore) ──────────────────────────
    await FirestoreService().addJob(job);
  }

  /// Updates an existing job. Only the original poster (company) may do this.
  Future<void> updateJob(JobModel job, {required UserModel poster}) async {
    if (poster.role != UserRole.company) {
      throw Exception('Only company accounts can update job listings.');
    }
    if (job.postedById != poster.id) {
      throw Exception('You can only edit your own job listings.');
    }
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'jobs',
      job.toMap(),
      where: 'id = ? AND posted_by_id = ?',
      whereArgs: [job.id, poster.id],
    );
    await FirestoreService().updateJob(job);
  }

  /// Deletes a job. Only the original poster (company) may do this.
  Future<void> deleteJob(String jobId, {required UserModel poster}) async {
    if (poster.role != UserRole.company) {
      throw Exception('Only company accounts can delete job listings.');
    }
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'jobs',
      where: 'id = ? AND posted_by_id = ?',
      whereArgs: [jobId, poster.id],
    );
    await FirestoreService().deleteJob(jobId);
  }

  // ── SEED ───────────────────────────────────────────────

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
            'We are looking for an experienced Flutter developer to join our digital products team.',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 150,000 - 250,000/mo',
        'type': 'full-time',
        'category': 'Technology',
        'skills': 'Flutter, Dart, Firebase, REST APIs, Git',
        'deadline': deadline.toIso8601String(),
        'is_remote': 0,
        'posted_by_role': 'company',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j2',
        'title': 'Digital Marketing Manager',
        'company': 'Jumia Kenya',
        'description':
            'Drive Jumia Kenya\'s digital marketing strategy across all online channels.',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 120,000 - 180,000/mo',
        'type': 'full-time',
        'category': 'Marketing',
        'skills': 'SEO, SEM, Google Analytics, Facebook Ads, Content Marketing',
        'deadline': deadline2.toIso8601String(),
        'is_remote': 1,
        'posted_by_role': 'company',
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j3',
        'title': 'Civil Engineer',
        'company': 'Kenya National Highways Authority',
        'description':
            'Join KeNHA in designing and supervising road construction projects.',
        'location': 'Nairobi / Field',
        'salary': 'KES 90,000 - 140,000/mo',
        'type': 'full-time',
        'category': 'Engineering',
        'skills':
            'AutoCAD, Structural Analysis, Project Management, Road Design',
        'deadline': deadline3.toIso8601String(),
        'is_remote': 0,
        'posted_by_role': 'company',
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j4',
        'title': 'Data Analyst Intern',
        'company': 'M-Pesa Africa',
        'description':
            'Exciting internship opportunity at M-Pesa Africa\'s data team.',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 40,000 - 60,000/mo',
        'type': 'internship',
        'category': 'Technology',
        'skills': 'Python, SQL, Power BI, Excel, Statistics',
        'deadline': deadline2.toIso8601String(),
        'is_remote': 0,
        'posted_by_role': 'company',
        'created_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j5',
        'title': 'Registered Nurse',
        'company': 'Aga Khan Hospital',
        'description':
            'Aga Khan Hospital is seeking dedicated nurses to join our team.',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 70,000 - 100,000/mo',
        'type': 'full-time',
        'category': 'Healthcare',
        'skills': 'Patient Care, IV Therapy, Wound Care, EMR Systems',
        'deadline': deadline.toIso8601String(),
        'is_remote': 0,
        'posted_by_role': 'company',
        'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'j6',
        'title': 'UI/UX Designer',
        'company': 'Equity Bank',
        'description':
            'Design intuitive digital banking experiences for millions of customers.',
        'location': 'Nairobi, Kenya',
        'salary': 'KES 100,000 - 160,000/mo',
        'type': 'full-time',
        'category': 'Design',
        'skills': 'Figma, Adobe XD, User Research, Prototyping, Design Systems',
        'deadline': deadline3.toIso8601String(),
        'is_remote': 1,
        'posted_by_role': 'company',
        'created_at': now.subtract(const Duration(hours: 18)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    ];

    for (final j in jobs) {
      await db.insert('jobs', j, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
