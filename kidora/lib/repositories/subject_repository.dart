import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/subject.dart';

class SubjectRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertSubject(Subject subject) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'subjects',
      subject.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('subjects');
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }
}
