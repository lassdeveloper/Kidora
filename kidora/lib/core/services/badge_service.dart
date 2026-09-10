import '../../models/child.dart';
import '../../models/child_badge.dart';
import '../../models/exercise_answer.dart';
import '../../repositories/badge_repository.dart';

class BadgeService {
  final BadgeRepository _badgeRepository;

  BadgeService(this._badgeRepository);

  /// Vérifie et débloque les badges appropriés pour un enfant donné.
  /// Renvoie la liste des identifiants de badges nouvellement débloqués durant cette exécution.
  Future<List<String>> checkAndUnlockBadges({
    required Child child,
    required List<ExerciseAnswer> answers,
    required List<ChildBadge> currentlyUnlocked,
  }) async {
    final List<String> newlyUnlockedIds = [];
    final unlockedSet = currentlyUnlocked.map((b) => b.badgeId).toSet();

    // 1. Badge "Premier Pas" (badge_first_step) : Toujours vrai s'il a un profil
    if (!unlockedSet.contains('badge_first_step')) {
      await _unlock('badge_first_step', child.id!, newlyUnlockedIds);
    }

    // 2. Badge "Cerveau Agile" (badge_10_correct) : Répondre à au moins 10 exercices correctement
    final correctCount = answers.where((a) => a.isCorrect).length;
    if (correctCount >= 10 && !unlockedSet.contains('badge_10_correct')) {
      await _unlock('badge_10_correct', child.id!, newlyUnlockedIds);
    }

    // 3. Badges par matière
    // "Mathématicien" (badge_math)
    final mathAnswers = answers.where((a) => a.exerciseId.startsWith('math_') && a.isCorrect);
    if (mathAnswers.isNotEmpty && !unlockedSet.contains('badge_math')) {
      await _unlock('badge_math', child.id!, newlyUnlockedIds);
    }

    // "Jeune Lecteur" (badge_french)
    final frenchAnswers = answers.where((a) => a.exerciseId.startsWith('french_') && a.isCorrect);
    if (frenchAnswers.isNotEmpty && !unlockedSet.contains('badge_french')) {
      await _unlock('badge_french', child.id!, newlyUnlockedIds);
    }

    // "Explorateur" (badge_science)
    final scienceAnswers = answers.where((a) => a.exerciseId.startsWith('science_') && a.isCorrect);
    if (scienceAnswers.isNotEmpty && !unlockedSet.contains('badge_science')) {
      await _unlock('badge_science', child.id!, newlyUnlockedIds);
    }

    // "Maître de Logique" (badge_logic)
    final logicAnswers = answers.where((a) => a.exerciseId.startsWith('logic_') && a.isCorrect);
    if (logicAnswers.isNotEmpty && !unlockedSet.contains('badge_logic')) {
      await _unlock('badge_logic', child.id!, newlyUnlockedIds);
    }

    return newlyUnlockedIds;
  }

  Future<void> _unlock(String badgeId, int childId, List<String> newlyUnlockedList) async {
    final cb = ChildBadge(
      childId: childId,
      badgeId: badgeId,
      unlockedAt: DateTime.now(),
    );
    await _badgeRepository.unlockBadge(cb);
    newlyUnlockedList.add(badgeId);
  }
}
