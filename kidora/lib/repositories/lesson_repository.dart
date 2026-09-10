import '../core/database/database_helper.dart';
import '../models/lesson.dart';

class LessonRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertLesson(Lesson lesson) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'lessons',
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Lesson>> getLessonsByWorld(String worldId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'world_id = ?',
      whereArgs: [worldId],
    );
    return List.generate(maps.length, (i) => Lesson.fromMap(maps[i]));
  }
}
