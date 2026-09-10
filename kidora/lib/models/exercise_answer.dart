class ExerciseAnswer {
  final int? id;
  final int childId;
  final String exerciseId;
  final bool isCorrect;
  final DateTime answeredAt;

  ExerciseAnswer({
    this.id,
    required this.childId,
    required this.exerciseId,
    required this.isCorrect,
    required this.answeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'exercise_id': exerciseId,
      'is_correct': isCorrect ? 1 : 0,
      'answered_at': answeredAt.toIso8601String(),
    };
  }

  factory ExerciseAnswer.fromMap(Map<String, dynamic> map) {
    return ExerciseAnswer(
      id: map['id'] as int?,
      childId: map['child_id'] as int,
      exerciseId: map['exercise_id'] as String,
      isCorrect: (map['is_correct'] as int) == 1,
      answeredAt: DateTime.parse(map['answered_at'] as String),
    );
  }
}
