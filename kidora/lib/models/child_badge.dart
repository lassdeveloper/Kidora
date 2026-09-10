class ChildBadge {
  final int childId;
  final String badgeId;
  final DateTime unlockedAt;

  ChildBadge({
    required this.childId,
    required this.badgeId,
    required this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'child_id': childId,
      'badge_id': badgeId,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }

  factory ChildBadge.fromMap(Map<String, dynamic> map) {
    return ChildBadge(
      childId: map['child_id'] as int,
      badgeId: map['badge_id'] as String,
      unlockedAt: DateTime.parse(map['unlocked_at'] as String),
    );
  }
}
