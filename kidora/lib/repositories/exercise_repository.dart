import '../core/database/database_helper.dart';
import '../models/exercise.dart';
import '../models/exercise_answer.dart';

class ExerciseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertExercise(Exercise exercise) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercise>> getExercisesByLesson(String lessonId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<int> insertAnswer(ExerciseAnswer answer) async {
    final db = await _dbHelper.database;
    return await db.insert('exercise_answers', answer.toMap());
  }

  Future<List<ExerciseAnswer>> getAnswersByChild(int childId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_answers',
      where: 'child_id = ?',
      whereArgs: [childId],
    );
    return List.generate(maps.length, (i) => ExerciseAnswer.fromMap(maps[i]));
  }
}
