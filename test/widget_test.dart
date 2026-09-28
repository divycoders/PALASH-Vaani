import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/app.dart';

void main() {
  testWidgets('PALASH-Vaani launches and displays home screen banner', (WidgetTester tester) async {
    // Provide phone screen size
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PalashVaaniApp());
    await tester.pumpAndSettle();

    // Verify app title and welcome banner
    expect(find.text('पलाश-वाणी | PALASH-Vaani'), findsOneWidget);
    expect(find.textContaining('Counting 1–10'), findsOneWidget);
    expect(find.text('Offline Ready'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches tabs on phone view', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PalashVaaniApp());
    await tester.pumpAndSettle();

    // Tap Lessons tab
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    // Verify Lessons screen elements
    expect(find.text('Grade (कक्षा)'), findsOneWidget);
    expect(find.text('Subject (विषय)'), findsOneWidget);

    // Tap Classroom tab
    await tester.tap(find.byIcon(Icons.record_voice_over_outlined));
    await tester.pumpAndSettle();

    // Verify Classroom screen elements
    expect(find.text('Live Classroom Voice Pipeline'), findsOneWidget);
    expect(find.text('अपनी किताब खोलो'), findsOneWidget);

    // Tap Translator tab
    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();

    // Verify Translator screen elements
    expect(find.text('Translate'), findsOneWidget);
    expect(find.textContaining('DEMO TRANSLATION'), findsOneWidget);
  });

  testWidgets('NavigationRail is used on tablet-sized displays', (WidgetTester tester) async {
    // Provide tablet resolution (800 x 1280)
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PalashVaaniApp());
    await tester.pumpAndSettle();

    // In tablet mode, NavigationRail should be present, not NavigationBar
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
