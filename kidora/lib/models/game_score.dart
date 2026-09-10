class GameScore {
  final int? id;
  final int childId;
  final String gameId;
  final int score;
  final DateTime playedAt;

  GameScore({
    this.id,
    required this.childId,
    required this.gameId,
    required this.score,
    required this.playedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'game_id': gameId,
      'score': score,
      'played_at': playedAt.toIso8601String(),
    };
  }

  factory GameScore.fromMap(Map<String, dynamic> map) {
    return GameScore(
      id: map['id'] as int?,
      childId: map['child_id'] as int,
      gameId: map['game_id'] as String,
      score: map['score'] as int,
      playedAt: DateTime.parse(map['played_at'] as String),
    );
  }
}
