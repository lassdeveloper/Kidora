import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/progress.dart';

class ProgressRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> saveProgress(Progress progress) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Progress?> getProgressByChildAndSubject(int childId, String subjectId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress',
      where: 'child_id = ? AND subject_id = ?',
      whereArgs: [childId, subjectId],
    );
    if (maps.isNotEmpty) {
      return Progress.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Progress>> getProgressByChild(int childId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress',
      where: 'child_id = ?',
      whereArgs: [childId],
    );
    return List.generate(maps.length, (i) => Progress.fromMap(maps[i]));
  }
}
