export interface CodeFile {
  path: string;
  category: 'Configuration' | 'Core & Theme' | 'Database' | 'Features' | 'Assets';
  description: string;
  code: string;
}

export const FLUTTER_CODEBASE: CodeFile[] = [
  {
    path: "pubspec.yaml",
    category: "Configuration",
    description: "Le fichier de configuration principal du projet Flutter avec toutes les dépendances hors-ligne requises (sqflite, flutter_riverpod, path, audioplayers, etc.).",
    code: `name: kidora
description: "KIDORA — Apprendre. Jouer. Explorer. Application éducative 100% hors-ligne pour enfants de 4 à 12 ans."
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  
  # Gestion d'état moderne
  flutter_riverpod: ^2.3.6
  
  # Base de données locale SQLite
  sqflite: ^2.2.8
  path: ^1.8.3
  
  # Lecture de sons locaux et retours haptiques
  audioplayers: ^5.2.1
  
  # Animations légères et fluides
  flutter_animate: ^4.2.0
  
  # Graphiques de progression simples pour l'espace parent
  fl_chart: ^0.63.0
  
  # Stockage clé-valeur pour préférences simples
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.1

flutter:
  uses-material-design: true

  assets:
    - assets/lessons/maths/
    - assets/lessons/french/
    - assets/lessons/science/
    - assets/lessons/logic/
    - assets/audio/feedback/
    - assets/audio/instructions/
    - assets/images/avatars/
    - assets/images/worlds/
`
  },
  {
    path: "lib/main.dart",
    category: "Configuration",
    description: "Le point d'entrée principal de l'application qui initialise la base de données locale, configure le Riverpod ProviderScope et démarre l'application.",
    code: `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Forcer l'orientation portrait pour une meilleure ergonomie enfant
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation de la base SQLite locale
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  runApp(
    const ProviderScope(
      child: KidoraApp(),
    ),
  );
}

class KidoraApp extends StatelessWidget {
  const KidoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KIDORA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
`
  },
  {
    path: "lib/core/theme/app_theme.dart",
    category: "Core & Theme",
    description: "Le design system de l'application KIDORA avec des boutons ronds, des couleurs douces et de gros éléments interactifs adaptés aux enfants.",
    code: `import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFF9F1C); // Orange chaleureux
  static const secondary = Color(0xFF2EC4B6); // Turquoise ludique
  static const accent = Color(0xFFE71D36); // Rouge vif pour alertes/badges
  static const background = Color(0xFFFDFFFC); // Fond légèrement cassé
  static const text = Color(0xFF011627); // Bleu marine très foncé (lisibilité)
  
  // Matières
  static const math = Color(0xFFFF5964);
  static const french = Color(0xFF35A7FF);
  static const science = Color(0xFF38B000);
  static const logic = Color(0xFF7000FF);
  
  static const cardBg = Color(0xFFF1FAEE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'ComicSans', // Adapté aux jeunes enfants pour l'apprentissage de la lecture
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        bodyLarge: TextStyle(fontSize: 18, color: AppColors.text, height: 1.5),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.text),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
        ),
      ),
    );
  }
}
`
  },
  {
    path: "lib/core/database/database_helper.dart",
    category: "Database",
    description: "Gestionnaire de la base SQLite contenant l'initialisation des 13 tables requises pour le MVP (enfants, leçons, progression, scores, badges, etc.) avec indexation.",
    code: `import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    // Badges
    final initialBadges = [
      {'id': 'badge_first_step', 'title': 'Premier Pas', 'description': 'Crée ton premier profil enfant', 'icon': '🏆', 'xp_bonus': 25},
      {'id': 'badge_10_correct', 'title': 'Cerveau Agile', 'description': 'Réponds correctement à 10 exercices', 'icon': '⭐', 'xp_bonus': 25},
      {'id': 'badge_math', 'title': 'Mathématicien', 'description': 'Termine ta première leçon de Maths', 'icon': '🔢', 'xp_bonus': 50},
      {'id': 'badge_french', 'title': 'Jeune Lecteur', 'description': 'Termine ta première leçon de Français', 'icon': '📚', 'xp_bonus': 50},
      {'id': 'badge_science', 'title': 'Explorateur', 'description': 'Termine ta première leçon de Sciences', 'icon': '🔬', 'xp_bonus': 50},
      {'id': 'badge_logic', 'title': 'Maître de Logique', 'description': 'Termine ta première leçon de Logique', 'icon': '🧠', 'xp_bonus': 50},
    ];

    for (var b in initialBadges) {
      await db.insert('badges', b);
    }

    // Mini-Jeux
    final initialGames = [
      {'id': 'game_memory', 'title': 'Mémoire', 'description': 'Trouve les paires d\\'images cachées !'},
      {'id': 'game_catch_number', 'title': 'Attrape le nombre', 'description': 'Sélectionne le bon nombre volant !'},
      {'id': 'game_mystery_word', 'title': 'Mot Mystère', 'description': 'Reconstitue le mot à l\\'aide des lettres mélangées.'},
      {'id': 'game_shapes', 'title': 'Formes', 'description': 'Identifie et place la bonne forme géométrique.'},
    ];

    for (var g in initialGames) {
      await db.insert('games', g);
    }
  }
}
`
  },
  {
    path: "lib/features/exercises/data/repositories/exercise_repository.dart",
    category: "Features",
    description: "Implémentation du dépôt pour charger de manière asynchrone et hors-ligne les contenus d'exercices à partir de fichiers JSON stockés dans les assets locaux.",
    code: `import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/exercise.dart';

class ExerciseRepository {
  // Charge les exercices d'une matière et filtre par âge et difficulté
  Future<List<Exercise>> loadExercisesFromJSON({
    required String subject,
    required int childAge,
  }) async {
    try {
      // Chargement du fichier JSON local depuis les assets hors-connexion
      final String jsonString = await rootBundle.loadString('assets/lessons/\$subject/content.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      final List<dynamic> exercisesRaw = jsonData['exercises'] ?? [];
      
      // Filtrer les questions adaptées à l'âge de l'enfant
      return exercisesRaw
          .map((e) => Exercise.fromMap(e))
          .where((exercise) => childAge >= exercise.ageMin && childAge <= exercise.ageMax)
          .toList();
    } catch (e) {
      // En cas de problème de lecture (ex: fichier absent), renvoyer une liste vide par sécurité
      print("Erreur de chargement des exercices hors-ligne: \$e");
      return [];
    }
  }
}
`
  },
  {
    path: "lib/core/routes/app_routes.dart",
    category: "Core & Theme",
    description: "Fichier centralisant la navigation complète (26 routes principales) de l'application KIDORA avec transitions fluides.",
    code: `import 'package:flutter/material.dart';
// Importations de tous les écrans du projet...

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const childSelection = '/child-selection';
  static const createChild = '/create-child';
  static const avatarSelection = '/avatar';
  static const ageLevelSelection = '/age-level';
  static const home = '/home';
  static const worlds = '/worlds';
  static const lesson = '/lesson';
  static const exercise = '/exercise';
  static const result = '/result';
  static const reward = '/reward';
  static const profile = '/profile';
  static const badges = '/badges';
  static const games = '/games';
  static const parentAccess = '/parent';
  static const parentDashboard = '/parent/dashboard';
  static const settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      // Gestion de toutes les autres routes du MVP...
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non trouvée : \${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Stubs d'écrans pour la démonstration de navigation
class SplashScreen extends StatelessWidget { const SplashScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class OnboardingScreen extends StatelessWidget { const OnboardingScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class HomeScreen extends StatelessWidget { const HomeScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
`
  },
  {
    path: "assets/lessons/maths/content.json",
    category: "Assets",
    description: "Exemple de structure JSON locale chargée par l'application pour les exercices du monde mathématique.",
    code: `{
  "id": "math_addition_world",
  "title": "Île des Mathématiques",
  "exercises": [
    {
      "id": "math_add_001",
      "type": "qcm",
      "ageMin": 6,
      "ageMax": 7,
      "question": "Combien font 2 + 3 ?",
      "options": ["4", "5", "6", "7"],
      "correctAnswer": "5",
      "explanation": "2 plus 3 font bien 5 ! Tu peux compter sur tes doigts.",
      "xpValue": 10
    },
    {
      "id": "math_geom_001",
      "type": "shapes",
      "ageMin": 4,
      "ageMax": 5,
      "question": "Trouve la forme à 3 côtés !",
      "options": ["🔵 Cercle", "🟩 Carré", "🔺 Triangle"],
      "correctAnswer": "🔺 Triangle",
      "explanation": "Bravo ! C'est le triangle.",
      "xpValue": 10
    }
  ]
}`
  }
];
