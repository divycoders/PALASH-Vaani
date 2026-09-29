import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/features/flashcards/data/flashcard_repository.dart';
import 'package:palash_vaani/features/flashcards/models/flashcard_item.dart';
import 'package:palash_vaani/features/flashcards/presentation/screens/flashcards_screen.dart';
import 'package:palash_vaani/features/flashcards/presentation/widgets/flashcard_flip_card.dart';

void main() {
  group('FlashcardRepository Tests', () {
    test('contains all 46 authentic primary curriculum flashcards', () {
      final allCards = FlashcardRepository.allCards;
      expect(allCards.length, 46);
      expect(allCards.isNotEmpty, true);
    });

    test('supports 9 core FLN categories', () {
      expect(FlashcardRepository.categories.length, 9);
      final categoryIds = FlashcardRepository.categories.map((c) => c.id).toList();
      expect(categoryIds, contains('Numbers'));
      expect(categoryIds, contains('Animals'));
      expect(categoryIds, contains('Nature'));
      expect(categoryIds, contains('Classroom'));
      expect(categoryIds, contains('Colors'));
      expect(categoryIds, contains('Shapes'));
      expect(categoryIds, contains('Food'));
      expect(categoryIds, contains('Body'));
      expect(categoryIds, contains('Family'));
    });

    test('filters cards by category accurately', () {
      final animals = FlashcardRepository.getCardsByCategory('Animals');
      expect(animals.length, 5);
      expect(animals.every((c) => c.category == 'Animals'), isTrue);

      final nature = FlashcardRepository.getCardsByCategory('Nature');
      expect(nature.length, 5);
      expect(nature.any((c) => c.hindi.contains('पलाश')), isTrue);
    });

    test('searches across scripts and dialects seamlessly', () {
      // Search in Hindi
      final searchHi = FlashcardRepository.searchCards('बाघ');
      expect(searchHi.any((c) => c.hindi.contains('बाघ')), isTrue);

      // Search in Santhali Devanagari
      final searchDev = FlashcardRepository.searchCards('मिद');
      expect(searchDev.any((c) => c.santhaliDev.contains('मिद')), isTrue);

      // Search in Romanized Latin
      final searchLatin = FlashcardRepository.searchCards('Hati');
      expect(searchLatin.any((c) => c.santhaliLatin == 'Hati'), isTrue);

      // Search in English
      final searchEn = FlashcardRepository.searchCards('Water');
      expect(searchEn.any((c) => c.englishMeaning == 'Water'), isTrue);
    });

    test('FlashcardItem serialization works symmetrically', () {
      final original = FlashcardRepository.allCards.first;
      final map = original.toMap();
      final revived = FlashcardItem.fromMap(map);

      expect(revived.id, original.id);
      expect(revived.hindi, original.hindi);
      expect(revived.santhaliDev, original.santhaliDev);
      expect(revived.santhaliLatin, original.santhaliLatin);
      expect(revived.flnCode, original.flnCode);
    });
  });

  group('FlashcardsScreen Widget Tests', () {
    testWidgets('renders FlashcardsScreen cleanly with initial Numbers card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlashcardsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and star tracker
      expect(find.textContaining('Stars ⭐'), findsOneWidget);
      expect(find.textContaining('बालवाटिका खोजकर्ता'), findsOneWidget);

      // Verify category chips
      expect(find.textContaining('संख्याएँ'), findsWidgets);
      expect(find.textContaining('जीव-जन्तु'), findsOneWidget);

      // Verify single card rendered
      expect(find.byType(FlashcardFlipCard), findsOneWidget);
      expect(find.text('मिद'), findsOneWidget);
      expect(find.text('उच्चारण सुनें'), findsOneWidget);
      expect(find.text('शिक्षक व्याख्या'), findsOneWidget);
      expect(find.text('साथ बोलें (+1 ⭐)'), findsOneWidget);
    });

    testWidgets('taps Next button to advance card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlashcardsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('मिद'), findsOneWidget);

      // Tap "अगला"
      await tester.tap(find.text('अगला'));
      await tester.pumpAndSettle();

      // Card 2 is "दो (२) / बार"
      expect(find.text('बार'), findsOneWidget);
    });

    testWidgets('switches to catalog grid view and back', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlashcardsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Grid View toggle icon
      await tester.tap(find.byTooltip('कैटलॉग ग्रिड'));
      await tester.pumpAndSettle();

      // Verify GridView is now displayed
      expect(find.byType(GridView), findsOneWidget);

      // Tap Card View toggle icon
      await tester.tap(find.byTooltip('कार्ड व्यू'));
      await tester.pumpAndSettle();

      expect(find.byType(FlashcardFlipCard), findsOneWidget);
    });
  });
}
