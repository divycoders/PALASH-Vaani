import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/services/connectivity_service.dart';
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
  final IConnectivityService? connectivityService;

  const PalashVaaniApp({
    super.key,
    this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PALASH-Vaani (पलाश-वाणी)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: MainShellScreen(connectivityService: connectivityService),
    );
  }
}

/// Main application shell holding the responsive scaffold and indexed screens
class MainShellScreen extends StatefulWidget {
  final IConnectivityService? connectivityService;

  const MainShellScreen({
    super.key,
    this.connectivityService,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  late final IConnectivityService _connectivityService;
  bool _ownsConnectivityService = false;

  @override
  void initState() {
    super.initState();
    if (widget.connectivityService != null) {
      _connectivityService = widget.connectivityService!;
    } else {
      _connectivityService = ConnectivityService();
      _ownsConnectivityService = true;
    }
  }

  @override
  void dispose() {
    if (_ownsConnectivityService) {
      _connectivityService.dispose();
    }
    super.dispose();
  }

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
      DiagnosticsScreen(connectivityService: _connectivityService),
    ];

    return ResponsiveScaffold(
      selectedIndex: _currentIndex,
      onIndexChanged: _onIndexChanged,
      connectivityService: _connectivityService,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
