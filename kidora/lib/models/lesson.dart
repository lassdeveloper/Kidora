class Lesson {
  final String id;
  final String worldId;
  final String title;
  final String? description;
  final int difficulty;

  Lesson({
    required this.id,
    required this.worldId,
    required this.title,
    this.description,
    this.difficulty = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'world_id': worldId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      worldId: map['world_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      difficulty: map['difficulty'] as int? ?? 1,
    );
  }
}
