import '../core/database/database_helper.dart';
import '../models/daily_limit.dart';

class DailyLimitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> saveDailyLimit(DailyLimit limit) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'daily_limits',
      limit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyLimit?> getDailyLimit(int childId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_limits',
      where: 'child_id = ?',
      whereArgs: [childId],
    );
    if (maps.isNotEmpty) {
      return DailyLimit.fromMap(maps.first);
    }
    return null;
  }
}
