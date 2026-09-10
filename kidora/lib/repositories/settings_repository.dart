import '../core/database/database_helper.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> saveSettings(AppSettings settings) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AppSettings?> getSettings(int childId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'child_id = ?',
      whereArgs: [childId],
    );
    if (maps.isNotEmpty) {
      return AppSettings.fromMap(maps.first);
    }
    return null;
  }
}
