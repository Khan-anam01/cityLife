import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/report_model.dart';

class ReportsRepository {
  ReportsRepository._();
  static final ReportsRepository instance = ReportsRepository._();

  Future<List<ReportModel>> getUserReports(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'reports',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => ReportModel.fromMap(m)).toList();
  }

  Future<List<ReportModel>> getAllReports() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'reports',
      orderBy: 'created_at DESC',
    );
    return results.map((m) => ReportModel.fromMap(m)).toList();
  }

  Future<void> createReport(ReportModel report) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStatus(String id, ReportStatus status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'reports',
      {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteReport(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }
}
