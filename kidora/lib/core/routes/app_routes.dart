import 'package:flutter/material.dart';
import '../../features/splash_screen.dart';
import '../../features/welcome_screen.dart';
import '../../features/onboarding_screens.dart';
import '../../features/home_screen.dart';
import '../../features/worlds_screens.dart';
import '../../features/lesson_detail_screen.dart';
import '../../features/exercise_screen.dart';
import '../../features/result_screen.dart';
import '../../features/profile_screens.dart';
import '../../features/games_screen.dart';
import '../../features/pause_screen.dart';
import '../../features/parent_access_screen.dart';
import '../../features/parent_dashboard_screens.dart';
import '../../models/lesson.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String createProfile = '/create-profile';
  static const String avatar = '/avatar';
  static const String ageLevel = '/age-level';
  static const String home = '/home';
  static const String worlds = '/worlds';
  static const String maths = '/maths';
  static const String french = '/french';
  static const String science = '/science';
  static const String logic = '/logic';
  static const String lessons = '/lessons';
  static const String lesson = '/lesson';
  static const String exercise = '/exercise';
  static const String result = '/result';
  static const String reward = '/reward';
  static const String profile = '/profile';
  static const String badges = '/badges';
  static const String games = '/games';
  static const String pause = '/pause';
  static const String parentAccess = '/parent-access';
  static const String parentDashboard = '/parent-dashboard';
  static const String progress = '/progress';
  static const String timeManagement = '/time-management';
  static const String profileManagement = '/profile-management';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case createProfile:
        return MaterialPageRoute(builder: (_) => const CreateProfileScreen());
      case avatar:
        return MaterialPageRoute(builder: (_) => const AvatarSelectionScreen());
      case ageLevel:
        return MaterialPageRoute(builder: (_) => const AgeLevelSelectionScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case worlds:
        return MaterialPageRoute(builder: (_) => const WorldsMapScreen());
      
      // Routes des mondes matières
      case maths:
        return MaterialPageRoute(builder: (_) => const SubjectWorldScreen(subjectId: 'math', subjectName: 'Mathématiques'));
      case french:
        return MaterialPageRoute(builder: (_) => const SubjectWorldScreen(subjectId: 'french', subjectName: 'Français'));
      case science:
        return MaterialPageRoute(builder: (_) => const SubjectWorldScreen(subjectId: 'science', subjectName: 'Sciences'));
      case logic:
        return MaterialPageRoute(builder: (_) => const SubjectWorldScreen(subjectId: 'logic', subjectName: 'Logique'));

      case lesson:
        final args = settings.arguments as Lesson;
        return MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: args));
      
      case exercise:
        final args = settings.arguments as Lesson;
        return MaterialPageRoute(builder: (_) => ExerciseScreen(lesson: args));
      
      case result:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => ResultScreen(data: args));
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ChildProfileScreen());
      
      case badges:
        return MaterialPageRoute(builder: (_) => const BadgesGalleryScreen());
      
      case games:
        return MaterialPageRoute(builder: (_) => const GamesScreen());
      
      case pause:
        return MaterialPageRoute(builder: (_) => const PauseScreen());
      
      case parentAccess:
        return MaterialPageRoute(builder: (_) => const ParentAccessScreen());
      
      case parentDashboard:
      case progress:
      case timeManagement:
      case profileManagement:
      case settings:
        return MaterialPageRoute(builder: (_) => const ParentDashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non définie : ${settings.name}'),
            ),
          ),
        );
    }
  }
}
