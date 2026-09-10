import 'dart:convert';

class Exercise {
  final String id;
  final String lessonId;
  final String type; // 'qcm', 'true_false', 'input', 'shapes', 'association'
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int xpValue;
  final String category;
  final int difficulty;
  final int ageMin;
  final int ageMax;
  final String? visualData;

  Exercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.xpValue = 10,
    required this.category,
    required this.difficulty,
    required this.ageMin,
    required this.ageMax,
    this.visualData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'type': type,
      'question': question,
      'options': jsonEncode(options),
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'xp_value': xpValue,
      'category': category,
      'difficulty': difficulty,
      'age_min': ageMin,
      'age_max': ageMax,
      'visual_data': visualData,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    List<String> optionsList = [];
    if (map['options'] != null) {
      try {
        final decoded = jsonDecode(map['options'] as String);
        if (decoded is List) {
          optionsList = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        optionsList = (map['options'] as String).split(',');
      }
    }
    return Exercise(
      id: map['id'] as String,
      lessonId: map['lesson_id'] as String,
      type: map['type'] as String,
      question: map['question'] as String,
      options: optionsList,
      correctAnswer: map['correct_answer'] as String,
      explanation: map['explanation'] as String?,
      xpValue: map['xp_value'] as int? ?? 10,
      category: map['category'] as String? ?? '',
      difficulty: map['difficulty'] as int? ?? 1,
      ageMin: map['age_min'] as int? ?? 4,
      ageMax: map['age_max'] as int? ?? 12,
      visualData: map['visual_data'] as String?,
    );
  }
}
