class Child {
  final int? id;
  final String name;
  final int age;
  final String schoolLevel;
  final String avatar;
  final int xp;
  final int level;
  final DateTime createdAt;

  Child({
    this.id,
    required this.name,
    required this.age,
    required this.schoolLevel,
    required this.avatar,
    this.xp = 0,
    this.level = 1,
    required this.createdAt,
  });

  Child copyWith({
    int? id,
    String? name,
    int? age,
    String? schoolLevel,
    String? avatar,
    int? xp,
    int? level,
    DateTime? createdAt,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      avatar: avatar ?? this.avatar,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'age': age,
      'school_level': schoolLevel,
      'avatar': avatar,
      'xp': xp,
      'level': level,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      schoolLevel: map['school_level'] as String,
      avatar: map['avatar'] as String,
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
