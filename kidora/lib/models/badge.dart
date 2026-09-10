class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpBonus;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.xpBonus = 25,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'xp_bonus': xpBonus,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      xpBonus: map['xp_bonus'] as int? ?? 25,
    );
  }
}
