import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_scaffold.dart';
import 'features/classroom/presentation/screens/classroom_screen.dart';
import 'features/diagnostics/presentation/screens/diagnostics_screen.dart';
import 'features/flashcards/presentation/screens/flashcards_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/lessons/presentation/screens/lessons_screen.dart';
import 'features/translator/presentation/screens/translator_screen.dart';
import 'features/worksheets/presentation/screens/worksheets_screen.dart';

class PalashVaaniApp extends StatelessWidget {
  const PalashVaaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PALASH-Vaani (पलाश-वाणी)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const MainShellScreen(),
    );
  }
}

/// Main application shell holding the responsive scaffold and indexed screens
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _onIndexChanged),
      const LessonsScreen(),
      const ClassroomScreen(),
      const TranslatorScreen(),
      const WorksheetsScreen(),
      const FlashcardsScreen(),
      const DiagnosticsScreen(),
    ];

    return ResponsiveScaffold(
      selectedIndex: _currentIndex,
      onIndexChanged: _onIndexChanged,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
