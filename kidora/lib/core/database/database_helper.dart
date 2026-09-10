import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'initial_exercises_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kidora_mvp.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, filePath);

    return await openDatabase(
      pathString,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Table Children (Profils Enfants)
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        school_level TEXT NOT NULL,
        avatar TEXT NOT NULL,
        xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Table Subjects (Matières)
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // 3. Table Worlds (Mondes)
    await db.execute('''
      CREATE TABLE worlds (
        id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        name TEXT NOT NULL,
        required_level INTEGER DEFAULT 1,
        FOREIGN KEY (subject_id) REFERENCES subjects (id)
      )
    ''');

    // 4. Table Lessons (Leçons)
    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        world_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        difficulty INTEGER DEFAULT 1,
        FOREIGN KEY (world_id) REFERENCES worlds (id)
      )
    ''');

    // 5. Table Exercises (Exercices)
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        type TEXT NOT NULL,
        question TEXT NOT NULL,
        options TEXT, -- JSON string d'options
        correct_answer TEXT NOT NULL,
        explanation TEXT,
        xp_value INTEGER DEFAULT 10,
        category TEXT,
        difficulty INTEGER DEFAULT 1,
        age_min INTEGER DEFAULT 4,
        age_max INTEGER DEFAULT 12,
        visual_data TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id)
      )
    ''');

    // 6. Table Exercise Answers (Historique des réponses)
    await db.execute('''
      CREATE TABLE exercise_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        exercise_id TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        answered_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children (id)
      )
    ''');

    // 7. Table Progress (Suivi général de progression)
    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        subject_id TEXT NOT NULL,
        completed_lessons_count INTEGER DEFAULT 0,
        success_rate REAL DEFAULT 0.0,
        study_time_seconds INTEGER DEFAULT 0,
        last_active TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children (id)
      )
    ''');

    // 8. Table Badges (Définition des trophées)
    await db.execute('''
      CREATE TABLE badges (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        xp_bonus INTEGER DEFAULT 25
      )
    ''');

    // 9. Table Child Badges (Badges obtenus par l'enfant)
    await db.execute('''
      CREATE TABLE child_badges (
        child_id INTEGER NOT NULL,
        badge_id TEXT NOT NULL,
        unlocked_at TEXT NOT NULL,
        PRIMARY KEY (child_id, badge_id),
        FOREIGN KEY (child_id) REFERENCES children (id),
        FOREIGN KEY (badge_id) REFERENCES badges (id)
      )
    ''');

    // 10. Table Games (Définition des Mini-jeux)
    await db.execute('''
      CREATE TABLE games (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // 11. Table Game Scores (Scores aux mini-jeux)
    await db.execute('''
      CREATE TABLE game_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        game_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        played_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children (id),
        FOREIGN KEY (game_id) REFERENCES games (id)
      )
    ''');

    // 12. Table Settings (Paramètres de l'application)
    await db.execute('''
      CREATE TABLE settings (
        child_id INTEGER PRIMARY KEY,
        language TEXT DEFAULT 'FR',
        sound_enabled INTEGER DEFAULT 1,
        music_enabled INTEGER DEFAULT 1,
        theme_dark INTEGER DEFAULT 0,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // 13. Table Daily Limits (Contrôle parental du temps d'écran)
    await db.execute('''
      CREATE TABLE daily_limits (
        child_id INTEGER PRIMARY KEY,
        max_minutes_per_day INTEGER DEFAULT 30, -- 15, 30, 45, 60 ou 0 (sans limite)
        minutes_used_today INTEGER DEFAULT 0,
        last_reset_date TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Création des Index pour optimiser les performances sur appareils modestes
    await db.execute('CREATE INDEX idx_exercises_lesson ON exercises(lesson_id)');
    await db.execute('CREATE INDEX idx_answers_child ON exercise_answers(child_id)');
    await db.execute('CREATE INDEX idx_progress_child ON progress(child_id)');
    await db.execute('CREATE INDEX idx_child_badges ON child_badges(child_id)');
    await db.execute('CREATE INDEX idx_game_scores_child ON game_scores(child_id)');

    // Pré-remplir les Badges et les Mini-Jeux initiaux
    await _insertInitialData(db);
  }

  Future _insertInitialData(Database db) async {
    // 1. Badges
    final initialBadges = [
      {'id': 'badge_first_step', 'title': 'Premier Pas', 'description': 'Crée ton premier profil enfant', 'icon': '🏆', 'xp_bonus': 25},
      {'id': 'badge_10_correct', 'title': 'Cerveau Agile', 'description': 'Réponds correctement à 10 exercices', 'icon': '⭐', 'xp_bonus': 25},
      {'id': 'badge_math', 'title': 'Mathématicien', 'description': 'Termine ta première leçon de Maths', 'icon': '🔢', 'xp_bonus': 50},
      {'id': 'badge_french', 'title': 'Jeune Lecteur', 'description': 'Termine ta première leçon de Français', 'icon': '📚', 'xp_bonus': 50},
      {'id': 'badge_science', 'title': 'Explorateur', 'description': 'Termine ta première leçon de Sciences', 'icon': '🔬', 'xp_bonus': 50},
      {'id': 'badge_logic', 'title': 'Maître de Logique', 'description': 'Termine ta première leçon de Logique', 'icon': '🧠', 'xp_bonus': 50},
    ];

    for (var b in initialBadges) {
      await db.insert('badges', b, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2. Mini-Jeux
    final initialGames = [
      {'id': 'game_memory', 'title': 'Mémoire', 'description': 'Trouve les paires d\'images cachées !'},
      {'id': 'game_catch_number', 'title': 'Attrape le nombre', 'description': 'Sélectionne le bon nombre volant !'},
      {'id': 'game_mystery_word', 'title': 'Mot Mystère', 'description': 'Reconstitue le mot à l\'aide des lettres mélangées.'},
      {'id': 'game_shapes', 'title': 'Formes', 'description': 'Identifie et place la bonne forme géométrique.'},
    ];

    for (var g in initialGames) {
      await db.insert('games', g, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 3. Matériaux Éducatifs (Sujets, Mondes, Leçons, Exercices)
    for (var subject in InitialExercisesData.getSubjects()) {
      await db.insert('subjects', subject.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (var world in InitialExercisesData.getWorlds()) {
      await db.insert('worlds', world.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (var lesson in InitialExercisesData.getLessons()) {
      await db.insert('lessons', lesson.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (var exercise in InitialExercisesData.getExercises()) {
      await db.insert('exercises', exercise.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
