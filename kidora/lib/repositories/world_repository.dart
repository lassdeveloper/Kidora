import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/world.dart';

class WorldRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertWorld(World world) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'worlds',
      world.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<World>> getWorldsBySubject(String subjectId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'worlds',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
    return List.generate(maps.length, (i) => World.fromMap(maps[i]));
  }
}
