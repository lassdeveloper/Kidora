import '../core/database/database_helper.dart';
import '../models/child.dart';

class ChildRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createChild(Child child) async {
    final db = await _dbHelper.database;
    return await db.insert('children', child.toMap());
  }

  Future<Child?> getChild(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Child.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Child>> getAllChildren() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('children');
    return List.generate(maps.length, (i) => Child.fromMap(maps[i]));
  }

  Future<int> updateChild(Child child) async {
    final db = await _dbHelper.database;
    return await db.update(
      'children',
      child.toMap(),
      where: 'id = ?',
      whereArgs: [child.id],
    );
  }

  Future<int> deleteChild(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
