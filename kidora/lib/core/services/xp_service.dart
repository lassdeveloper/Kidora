class XpService {
  // Constantes de points XP d'apprentissage
  static const int xpCorrectAnswer = 10;
  static const int xpStreakBonus5 = 25;
  static const int xpStreakBonus10 = 50;
  static const int xpLessonCompletedBonus = 50;
  static const int xpPerfectScoreBonus = 30;

  /// Calcule les points gagnés pour un ensemble de réponses à une leçon.
  /// [answers] contient la liste des booléens indiquant si chaque question est correcte.
  static int calculateLessonXp({
    required List<bool> answers,
    required int baseQuestionValue,
  }) {
    if (answers.isEmpty) return 0;

    int totalXp = 0;
    int correctCount = 0;
    int currentStreak = 0;
    int maxStreak = 0;

    for (bool isCorrect in answers) {
      if (isCorrect) {
        totalXp += baseQuestionValue;
        correctCount++;
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    // Bonus de leçon complétée
    totalXp += xpLessonCompletedBonus;

    // Bonus de score parfait
    if (correctCount == answers.length) {
      totalXp += xpPerfectScoreBonus;
    }

    // Bonus de série de réussites d'affilée
    if (maxStreak >= 10) {
      totalXp += xpStreakBonus10;
    } else if (maxStreak >= 5) {
      totalXp += xpStreakBonus5;
    }

    return totalXp;
  }
}
