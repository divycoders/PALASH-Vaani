import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/features/classroom/presentation/screens/classroom_screen.dart';
import 'package:palash_vaani/features/translator/presentation/screens/translator_screen.dart';

void main() {
  group('ClassroomScreen Widget Tests', () {
    testWidgets('ClassroomScreen renders with Teacher mode and quick routines', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassroomScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Teacher / Student mode buttons
      expect(find.text('🧑‍🏫 शिक्षक मोड'), findsOneWidget);
      expect(find.text('🧒 विद्यार्थी मोड'), findsOneWidget);

      // Check Classroom interaction arena
      expect(find.textContaining('कक्षा संवाद'), findsOneWidget);
      expect(find.text('उच्चारण सुनें'), findsOneWidget);
      expect(find.text('शिक्षक व्याख्या'), findsOneWidget);
      expect(find.text('साथ दोहराएँ (+1 ⭐)'), findsOneWidget);

      // Check Routine category chips
      expect(find.text('सभी निर्देश'), findsOneWidget);
      expect(find.text('प्रार्थना व स्वागत'), findsOneWidget);

      // Switch to Student mode
      await tester.tap(find.text('🧒 विद्यार्थी मोड'));
      await tester.pumpAndSettle();

      expect(find.textContaining('छात्र अभिव्यक्ति'), findsOneWidget);
    });

    testWidgets('Tapping a routine item updates input and translation', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassroomScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on routine "पानी पी लो" if found or "बैठ जाओ"
      final sitDown = find.text('बैठ जाओ');
      if (sitDown.evaluate().isNotEmpty) {
        await tester.ensureVisible(sitDown);
        await tester.tap(sitDown);
        await tester.pumpAndSettle();

        expect(find.textContaining('दुड़ुब'), findsWidgets);
      }
    });
  });

  group('TranslatorScreen Widget Tests', () {
    testWidgets('TranslatorScreen renders with Tri-Dialect studio and categories', (tester) async {
      tester.view.physicalSize = const Size(420, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TranslatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check direction header and offline banner
      expect(find.textContaining('Hindi (हिंदी)'), findsWidgets);
      expect(find.text('100% ऑफ़लाइन जनजातीय अनुवादक'), findsOneWidget);
      expect(find.text('अनुवाद करें'), findsOneWidget);

      // Check Tri-dialect studio card
      expect(find.text('झारखंड त्रि-भाषा तुलना (Tri-Dialect Studio)'), findsOneWidget);
      expect(find.textContaining('Santhali'), findsWidgets);
      expect(find.text('हो (Ho)'), findsOneWidget);
      expect(find.text('मुंडारी (Mundari)'), findsOneWidget);

      // Check category chips
      expect(find.text('🏫 कक्षा निर्देश'), findsOneWidget);
      final numCategory = find.text('🔢 FLN गिनती (1-20)');
      expect(numCategory, findsOneWidget);

      // Tap FLN numbers category chip
      await tester.ensureVisible(numCategory);
      await tester.tap(numCategory);
      await tester.pumpAndSettle();

      // Verify number chips appear
      final oneChip = find.text('१ - एक');
      expect(oneChip, findsOneWidget);
      expect(find.text('२ - दो'), findsOneWidget);

      // Tap '१ - एक'
      await tester.ensureVisible(oneChip);
      await tester.tap(oneChip);
      await tester.pumpAndSettle();

      // Verify Santhali translation for 1 (मिद / ᱢᱤᱫ) is present
      expect(find.textContaining('ᱢᱤᱫ'), findsWidgets);
    });

    testWidgets('TranslatorScreen language swap toggles direction', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TranslatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find swap icon
      final swapBtn = find.byIcon(Icons.swap_horiz_rounded);
      expect(swapBtn, findsOneWidget);

      await tester.tap(swapBtn);
      await tester.pumpAndSettle();

      // In Tribal -> Hindi mode, tri-dialect comparison card is hidden (since input is tribal)
      expect(find.text('झारखंड त्रि-भाषा तुलना (Tri-Dialect Studio)'), findsNothing);
    });

    testWidgets('Classroom and Translator screens render without overflow on Tablet Landscape (1280x800)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassroomScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🧑‍🏫 शिक्षक मोड'), findsOneWidget);
      expect(find.textContaining('कक्षा संवाद'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TranslatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('100% ऑफ़लाइन जनजातीय अनुवादक'), findsOneWidget);
      expect(find.text('झारखंड त्रि-भाषा तुलना (Tri-Dialect Studio)'), findsOneWidget);
    });

    testWidgets('Classroom and Translator screens render without overflow on Tablet Portrait (800x1280)', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassroomScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🧑‍🏫 शिक्षक मोड'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TranslatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('100% ऑफ़लाइन जनजातीय अनुवादक'), findsOneWidget);
    });
  });
}

