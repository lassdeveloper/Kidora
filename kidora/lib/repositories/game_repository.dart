import '../core/database/database_helper.dart';
import '../models/game.dart';
import '../models/game_score.dart';

class GameRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Game>> getAllGames() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('games');
    return List.generate(maps.length, (i) => Game.fromMap(maps[i]));
  }

  Future<int> insertScore(GameScore score) async {
    final db = await _dbHelper.database;
    return await db.insert('game_scores', score.toMap());
  }

  Future<List<GameScore>> getScoresByChildAndGame(int childId, String gameId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_scores',
      where: 'child_id = ? AND game_id = ?',
      whereArgs: [childId, gameId],
      orderBy: 'score DESC',
    );
    return List.generate(maps.length, (i) => GameScore.fromMap(maps[i]));
  }
}
