class DailyLimit {
  final int childId;
  final int maxMinutesPerDay;
  final int minutesUsedToday;
  final DateTime lastResetDate;

  DailyLimit({
    required this.childId,
    this.maxMinutesPerDay = 30,
    this.minutesUsedToday = 0,
    required this.lastResetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'child_id': childId,
      'max_minutes_per_day': maxMinutesPerDay,
      'minutes_used_today': minutesUsedToday,
      'last_reset_date': lastResetDate.toIso8601String().split('T')[0], // format YYYY-MM-DD
    };
  }

  factory DailyLimit.fromMap(Map<String, dynamic> map) {
    return DailyLimit(
      childId: map['child_id'] as int,
      maxMinutesPerDay: map['max_minutes_per_day'] as int? ?? 30,
      minutesUsedToday: map['minutes_used_today'] as int? ?? 0,
      lastResetDate: DateTime.parse(map['last_reset_date'] as String),
    );
  }
}
