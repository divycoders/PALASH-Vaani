import 'package:flutter/material.dart';
import '../../app.dart';
import '../../features/lessons/presentation/screens/lessons_screen.dart';
import '../../features/classroom/presentation/screens/classroom_screen.dart';
import '../../features/translator/presentation/screens/translator_screen.dart';
import '../../features/worksheets/presentation/screens/worksheets_screen.dart';
import '../../features/flashcards/presentation/screens/flashcards_screen.dart';
import '../../features/diagnostics/presentation/screens/diagnostics_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String lessons = '/lessons';
  static const String classroom = '/classroom';
  static const String translator = '/translator';
  static const String quiz = '/quiz';
  static const String worksheets = '/worksheets';
  static const String flashcards = '/flashcards';
  static const String diagnostics = '/diagnostics';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case quiz:
        return MaterialPageRoute(
          builder: (_) => const QuizScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(),
          settings: settings,
        );
      case lessons:
        return MaterialPageRoute(
          builder: (_) => const LessonsScreen(),
          settings: settings,
        );
      case classroom:
        return MaterialPageRoute(
          builder: (_) => const ClassroomScreen(),
          settings: settings,
        );
      case translator:
        return MaterialPageRoute(
          builder: (_) => const TranslatorScreen(),
          settings: settings,
        );
      case worksheets:
        return MaterialPageRoute(
          builder: (_) => const WorksheetsScreen(),
          settings: settings,
        );
      case flashcards:
        return MaterialPageRoute(
          builder: (_) => const FlashcardsScreen(),
          settings: settings,
        );
      case diagnostics:
        return MaterialPageRoute(
          builder: (_) => const DiagnosticsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
