class Subject {
  final String id;
  final String name;
  final String color;
  final String icon;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as String,
      icon: map['icon'] as String,
    );
  }
}
