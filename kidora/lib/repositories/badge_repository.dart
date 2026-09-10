import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/badge.dart';
import '../models/child_badge.dart';

class BadgeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Badge>> getAllBadges() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('badges');
    return List.generate(maps.length, (i) => Badge.fromMap(maps[i]));
  }

  Future<int> unlockBadge(ChildBadge childBadge) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'child_badges',
      childBadge.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<ChildBadge>> getUnlockedBadges(int childId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'child_badges',
      where: 'child_id = ?',
      whereArgs: [childId],
    );
    return List.generate(maps.length, (i) => ChildBadge.fromMap(maps[i]));
  }
}
