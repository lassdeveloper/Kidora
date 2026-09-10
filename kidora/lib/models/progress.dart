class Progress {
  final int? id;
  final int childId;
  final String subjectId;
  final int completedLessonsCount;
  final double successRate;
  final int studyTimeSeconds;
  final DateTime lastActive;

  Progress({
    this.id,
    required this.childId,
    required this.subjectId,
    this.completedLessonsCount = 0,
    this.successRate = 0.0,
    this.studyTimeSeconds = 0,
    required this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'subject_id': subjectId,
      'completed_lessons_count': completedLessonsCount,
      'success_rate': successRate,
      'study_time_seconds': studyTimeSeconds,
      'last_active': lastActive.toIso8601String(),
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'] as int?,
      childId: map['child_id'] as int,
      subjectId: map['subject_id'] as String,
      completedLessonsCount: map['completed_lessons_count'] as int? ?? 0,
      successRate: (map['success_rate'] as num?)?.toDouble() ?? 0.0,
      studyTimeSeconds: map['study_time_seconds'] as int? ?? 0,
      lastActive: DateTime.parse(map['last_active'] as String),
    );
  }
}
