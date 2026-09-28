import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/app.dart';
import 'package:palash_vaani/core/services/connectivity_service.dart';
import 'mocks/mock_curriculum_repository.dart';

void main() {
  testWidgets('PALASH-Vaani launches offline and displays Offline indicator', (WidgetTester tester) async {
    final mockConnectivity = MockConnectivityService(initialStatus: AppNetworkStatus.offline);
    final mockCurriculum = MockCurriculumRepository();

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      mockConnectivity.dispose();
    });

    await tester.pumpWidget(PalashVaaniApp(
      connectivityService: mockConnectivity,
      curriculumRepository: mockCurriculum,
    ));
    await tester.pumpAndSettle();

    // Verify app title and welcome banner
    expect(find.text('पलाश-वाणी | PALASH-Vaani'), findsOneWidget);
    expect(find.textContaining('Counting 1–10'), findsOneWidget);
    // Verify live Offline badge in AppBar
    expect(find.text('Offline'), findsOneWidget);
  });

  testWidgets('Tapping Offline indicator opens local-first architecture dialog', (WidgetTester tester) async {
    final mockConnectivity = MockConnectivityService(initialStatus: AppNetworkStatus.offline);
    final mockCurriculum = MockCurriculumRepository();

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      mockConnectivity.dispose();
    });

    await tester.pumpWidget(PalashVaaniApp(
      connectivityService: mockConnectivity,
      curriculumRepository: mockCurriculum,
    ));
    await tester.pumpAndSettle();

    // Tap Offline badge
    await tester.tap(find.text('Offline'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Offline-First Architecture'), findsOneWidget);
    expect(find.textContaining('Zero data is transmitted to cloud APIs'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Understood'));
    await tester.pumpAndSettle();
    expect(find.text('Offline-First Architecture'), findsNothing);
  });

  testWidgets('Indicator dynamically updates when network changes to Online', (WidgetTester tester) async {
    final mockConnectivity = MockConnectivityService(initialStatus: AppNetworkStatus.offline);
    final mockCurriculum = MockCurriculumRepository();

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      mockConnectivity.dispose();
    });

    await tester.pumpWidget(PalashVaaniApp(
      connectivityService: mockConnectivity,
      curriculumRepository: mockCurriculum,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Online'), findsNothing);

    // Change to online
    mockConnectivity.setStatus(AppNetworkStatus.online);
    await tester.pumpAndSettle();

    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Offline'), findsNothing);
  });

  testWidgets('Bottom navigation switches tabs cleanly in offline mode', (WidgetTester tester) async {
    final mockConnectivity = MockConnectivityService(initialStatus: AppNetworkStatus.offline);
    final mockCurriculum = MockCurriculumRepository();

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      mockConnectivity.dispose();
    });

    await tester.pumpWidget(PalashVaaniApp(
      connectivityService: mockConnectivity,
      curriculumRepository: mockCurriculum,
    ));
    await tester.pumpAndSettle();

    // Tap Lessons tab
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Grade (कक्षा)'), findsOneWidget);
    expect(find.text('Subject (विषय)'), findsOneWidget);

    // Tap Classroom tab
    await tester.tap(find.byIcon(Icons.record_voice_over_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Live Classroom Voice Pipeline'), findsOneWidget);
    expect(find.text('अपनी किताब खोलो'), findsOneWidget);

    // Tap Translator tab
    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Translate'), findsOneWidget);
    expect(find.textContaining('DEMO TRANSLATION'), findsOneWidget);
  });

  testWidgets('Selecting a lesson opens LessonDetailDialog with SQLite data and prototype warning', (WidgetTester tester) async {
    final mockConnectivity = MockConnectivityService(initialStatus: AppNetworkStatus.offline);
    final mockCurriculum = MockCurriculumRepository();

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      mockConnectivity.dispose();
    });

    await tester.pumpWidget(PalashVaaniApp(
      connectivityService: mockConnectivity,
      curriculumRepository: mockCurriculum,
    ));
    await tester.pumpAndSettle();

    // Tap Lessons tab
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    // Verify lesson card from repository is displayed
    expect(find.textContaining('गिनती १ से १०'), findsOneWidget);
    expect(find.text('Available Lessons (Local SQLite)'), findsOneWidget);

    // Tap Lesson Overview
    await tester.tap(find.text('Lesson Overview'));
    await tester.pumpAndSettle();

    // Verify LessonDetailDialog content
    expect(find.text('Learning Objective / शिक्षण उद्देश्य'), findsOneWidget);
    expect(find.text('LO-M1.1'), findsOneWidget);
    expect(find.text('Prototype / Pending Native Verification'), findsWidgets);

    // Toggle complete
    await tester.tap(find.text('Mark Complete'));
    await tester.pumpAndSettle();

    // Verify state updated to Completed
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('NavigationRail is used on tablet-sized displays', (WidgetTester tester) async {
    final mockConnectivity = MockConnectivityService(initialStatus: AppNetworkStatus.offline);
    final mockCurriculum = MockCurriculumRepository();

    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      mockConnectivity.dispose();
    });

    await tester.pumpWidget(PalashVaaniApp(
      connectivityService: mockConnectivity,
      curriculumRepository: mockCurriculum,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
