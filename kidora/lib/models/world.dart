class World {
  final String id;
  final String subjectId;
  final String name;
  final int requiredLevel;

  World({
    required this.id,
    required this.subjectId,
    required this.name,
    this.requiredLevel = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'required_level': requiredLevel,
    };
  }

  factory World.fromMap(Map<String, dynamic> map) {
    return World(
      id: map['id'] as String,
      subjectId: map['subject_id'] as String,
      name: map['name'] as String,
      requiredLevel: map['required_level'] as int? ?? 1,
    );
  }
}
