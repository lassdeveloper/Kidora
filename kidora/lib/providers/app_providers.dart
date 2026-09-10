import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child.dart';
import '../models/subject.dart';
import '../models/world.dart';
import '../models/lesson.dart';
import '../models/exercise.dart';
import '../models/progress.dart';
import '../models/badge.dart';
import '../models/child_badge.dart';
import '../models/game.dart';
import '../models/app_settings.dart';
import '../models/daily_limit.dart';
import '../repositories/child_repository.dart';
import '../repositories/subject_repository.dart';
import '../repositories/world_repository.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/progress_repository.dart';
import '../repositories/badge_repository.dart';
import '../repositories/game_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/daily_limit_repository.dart';
import '../core/services/badge_service.dart';

// --- 1. PROVIDERS DES REPOSITORIES ---
final childRepositoryProvider = Provider((ref) => ChildRepository());
final subjectRepositoryProvider = Provider((ref) => SubjectRepository());
final worldRepositoryProvider = Provider((ref) => WorldRepository());
final lessonRepositoryProvider = Provider((ref) => LessonRepository());
final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());
final progressRepositoryProvider = Provider((ref) => ProgressRepository());
final badgeRepositoryProvider = Provider((ref) => BadgeRepository());
final gameRepositoryProvider = Provider((ref) => GameRepository());
final settingsRepositoryProvider = Provider((ref) => SettingsRepository());
final dailyLimitRepositoryProvider = Provider((ref) => DailyLimitRepository());
final badgeServiceProvider = Provider((ref) => BadgeService(ref.watch(badgeRepositoryProvider)));

// --- 2. LISTE DES ENFANTS ---
class ChildrenNotifier extends StateNotifier<AsyncValue<List<Child>>> {
  final ChildRepository _repository;

  ChildrenNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadChildren();
  }

  Future<void> loadChildren() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.getAllChildren();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Child> addChild(String name, int age, String schoolLevel, String avatar) async {
    final child = Child(
      name: name,
      age: age,
      schoolLevel: schoolLevel,
      avatar: avatar,
      createdAt: DateTime.now(),
    );
    final id = await _repository.createChild(child);
    final newChild = child.copyWith(id: id);
    
    // Mettre à jour l'état local
    state.whenData((list) {
      state = AsyncValue.data([...list, newChild]);
    });
    return newChild;
  }

  Future<void> updateChildProfile(Child child) async {
    await _repository.updateChild(child);
    loadChildren();
  }

  Future<void> deleteChildProfile(int id) async {
    await _repository.deleteChild(id);
    loadChildren();
  }
}

final childrenProvider = StateNotifierProvider<ChildrenNotifier, AsyncValue<List<Child>>>((ref) {
  return ChildrenNotifier(ref.watch(childRepositoryProvider));
});

// --- 3. PROFIL ACTIF SÉLECTIONNÉ (PERSISTANT) ---
class ActiveChildNotifier extends StateNotifier<Child?> {
  final Ref _ref;

  ActiveChildNotifier(this._ref) : super(null) {
    _loadActiveChildFromPreferences();
  }

  Future<void> _loadActiveChildFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getInt('active_child_id');
    if (activeId != null) {
      final repo = _ref.read(childRepositoryProvider);
      final child = await repo.getChild(activeId);
      if (child != null) {
        state = child;
        // Charger ses paramètres et limites associées
        _ref.read(settingsProvider.notifier).loadSettings(activeId);
        _ref.read(dailyLimitProvider.notifier).loadDailyLimit(activeId);
      }
    }
  }

  Future<void> setActiveChild(Child child) async {
    state = child;
    final prefs = await SharedPreferences.getInstance();
    if (child.id != null) {
      await prefs.setInt('active_child_id', child.id!);
      // Charger ses configurations d'exécution
      _ref.read(settingsProvider.notifier).loadSettings(child.id!);
      _ref.read(dailyLimitProvider.notifier).loadDailyLimit(child.id!);
    }
  }

  Future<void> clearActiveChild() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_child_id');
  }

  Future<void> earnXp(int xpAmount) async {
    if (state == null) return;
    final currentXp = state!.xp + xpAmount;
    
    // Formule simple de niveau : 100 XP par niveau
    final currentLevel = (currentXp / 100).floor() + 1;
    
    final updatedChild = state!.copyWith(
      xp: currentXp,
      level: currentLevel,
    );
    
    state = updatedChild;
    await _ref.read(childRepositoryProvider).updateChild(updatedChild);
    _ref.read(childrenProvider.notifier).loadChildren();
  }
}

final activeChildProvider = StateNotifierProvider<ActiveChildNotifier, Child?>((ref) {
  return ActiveChildNotifier(ref);
});

// --- 4. SUJETS ET MONDES ---
final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return ref.watch(subjectRepositoryProvider).getAllSubjects();
});

final worldsProvider = FutureProvider<List<World>>((ref) async {
  final subjects = await ref.watch(subjectsProvider.future);
  final List<World> worlds = [];
  final repo = ref.watch(worldRepositoryProvider);
  for (var s in subjects) {
    final subjectWorlds = await repo.getWorldsBySubject(s.id);
    worlds.addAll(subjectWorlds);
  }
  return worlds;
});

// --- 5. LEÇONS ET EXERCICES ---
final lessonsByWorldProvider = FutureProvider.family<List<Lesson>, String>((ref, worldId) async {
  return ref.watch(lessonRepositoryProvider).getLessonsByWorld(worldId);
});

final exercisesByLessonProvider = FutureProvider.family<List<Exercise>, String>((ref, lessonId) async {
  return ref.watch(exerciseRepositoryProvider).getExercisesByLesson(lessonId);
});

// --- 6. SUIVI DE LA PROGRESSION ---
class ProgressNotifier extends StateNotifier<List<Progress>> {
  final ProgressRepository _repository;

  ProgressNotifier(this._repository) : super([]);

  Future<void> loadProgress(int childId) async {
    final list = await _repository.getProgressByChild(childId);
    state = list;
  }

  Future<void> updateSubjectProgress(int childId, String subjectId, int completedCount, double success) async {
    final progress = Progress(
      childId: childId,
      subjectId: subjectId,
      completedLessonsCount: completedCount,
      successRate: success,
      lastActive: DateTime.now(),
    );
    await _repository.saveProgress(progress);
    loadProgress(childId);
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, List<Progress>>((ref) {
  return ProgressNotifier(ref.watch(progressRepositoryProvider));
});

// --- 7. BADGES ---
class BadgesNotifier extends StateNotifier<List<ChildBadge>> {
  final BadgeRepository _repository;

  BadgesNotifier(this._repository) : super([]);

  Future<void> loadUnlockedBadges(int childId) async {
    final list = await _repository.getUnlockedBadges(childId);
    state = list;
  }

  Future<void> unlockNewBadge(int childId, String badgeId) async {
    final cb = ChildBadge(
      childId: childId,
      badgeId: badgeId,
      unlockedAt: DateTime.now(),
    );
    await _repository.unlockBadge(cb);
    loadUnlockedBadges(childId);
  }
}

final badgesProvider = StateNotifierProvider<BadgesNotifier, List<ChildBadge>>((ref) {
  return BadgesNotifier(ref.watch(badgeRepositoryProvider));
});

final allBadgesProvider = FutureProvider<List<Badge>>((ref) async {
  return ref.watch(badgeRepositoryProvider).getAllBadges();
});

// --- 8. MINI-JEUX ---
final gamesProvider = FutureProvider<List<Game>>((ref) async {
  return ref.watch(gameRepositoryProvider).getAllGames();
});

// --- 9. CONFIGURATION DE L'APPLICATION ---
class SettingsNotifier extends StateNotifier<AppSettings?> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(null);

  Future<void> loadSettings(int childId) async {
    final settings = await _repository.getSettings(childId);
    if (settings != null) {
      state = settings;
    } else {
      // Créer par défaut
      final defaultSettings = AppSettings(childId: childId);
      await _repository.saveSettings(defaultSettings);
      state = defaultSettings;
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _repository.saveSettings(settings);
    state = settings;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings?>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

// --- 10. LIMITE QUOTIDIENNE (CONTRÔLE PARENTAL) ---
class DailyLimitNotifier extends StateNotifier<DailyLimit?> {
  final DailyLimitRepository _repository;

  DailyLimitNotifier(this._repository) : super(null);

  Future<void> loadDailyLimit(int childId) async {
    final limit = await _repository.getDailyLimit(childId);
    if (limit != null) {
      // Vérifier la réinitialisation de la date d'aujourd'hui
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final lastResetStr = limit.lastResetDate.toIso8601String().split('T')[0];
      
      if (todayStr != lastResetStr) {
        // Nouvelle journée ! Réinitialiser le compteur d'utilisation à 0 minutes
        final newDayLimit = DailyLimit(
          childId: childId,
          maxMinutesPerDay: limit.maxMinutesPerDay,
          minutesUsedToday: 0,
          lastResetDate: DateTime.now(),
        );
        await _repository.saveDailyLimit(newDayLimit);
        state = newDayLimit;
      } else {
        state = limit;
      }
    } else {
      // Créer par défaut
      final defaultLimit = DailyLimit(
        childId: childId,
        maxMinutesPerDay: 30,
        minutesUsedToday: 0,
        lastResetDate: DateTime.now(),
      );
      await _repository.saveDailyLimit(defaultLimit);
      state = defaultLimit;
    }
  }

  Future<void> useMinutes(int minutes) async {
    if (state == null) return;
    final updated = DailyLimit(
      childId: state!.childId,
      maxMinutesPerDay: state!.maxMinutesPerDay,
      minutesUsedToday: state!.minutesUsedToday + minutes,
      lastResetDate: state!.lastResetDate,
    );
    await _repository.saveDailyLimit(updated);
    state = updated;
  }

  Future<void> setMaxMinutes(int maxMinutes) async {
    if (state == null) return;
    final updated = DailyLimit(
      childId: state!.childId,
      maxMinutesPerDay: maxMinutes,
      minutesUsedToday: state!.minutesUsedToday,
      lastResetDate: state!.lastResetDate,
    );
    await _repository.saveDailyLimit(updated);
    state = updated;
  }
}

final dailyLimitProvider = StateNotifierProvider<DailyLimitNotifier, DailyLimit?>((ref) {
  return DailyLimitNotifier(ref.watch(dailyLimitRepositoryProvider));
});
