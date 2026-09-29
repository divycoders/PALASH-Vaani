import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/features/quiz/data/quiz_question_generator.dart';
import 'package:palash_vaani/features/quiz/presentation/screens/quiz_screen.dart';

void main() {
  group('QuizQuestionGenerator Unit Tests', () {
    final generator = QuizQuestionGenerator.instance;

    test('Generates fresh batch of 5 questions with valid structure', () {
      final quiz = generator.generateQuiz(count: 5, category: 'all');
      expect(quiz.length, equals(5));

      for (final q in quiz) {
        expect(q.id.isNotEmpty, isTrue);
        expect(q.titleHi.isNotEmpty, isTrue);
        expect(q.spokenAudioPrompt.isNotEmpty, isTrue);
        expect(q.visualSymbol.isNotEmpty, isTrue);
        expect(q.options.length, equals(4));

        // Exactly 1 option must be correct
        final correctCount = q.options.where((o) => o.isCorrect).length;
        expect(correctCount, equals(1));
      }
    });

    test('Generates mathematics questions with addition, subtraction, and Ol Chiki', () {
      final mathQuiz = generator.generateQuiz(count: 4, category: 'maths');
      expect(mathQuiz.length, equals(4));

      for (final q in mathQuiz) {
        expect(q.category, equals('maths'));
        expect(q.options.length, equals(4));
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });

    test('Generates language and vocabulary questions with Santhali words', () {
      final langQuiz = generator.generateQuiz(count: 3, category: 'language');
      expect(langQuiz.length, equals(3));

      for (final q in langQuiz) {
        expect(q.category, equals('language'));
        expect(q.options.any((o) => o.isCorrect), isTrue);
      }
    });

    test('Generates environmental studies (EVS) questions', () {
      final evsQuiz = generator.generateQuiz(count: 3, category: 'evs');
      expect(evsQuiz.length, equals(3));

      for (final q in evsQuiz) {
        expect(q.category, equals('evs'));
        expect(q.options.length, equals(4));
      }
    });

    test('Consecutive quiz generations produce unique dynamic batches', () {
      final batch1 = generator.generateQuiz(count: 3, category: 'maths');
      final batch2 = generator.generateQuiz(count: 3, category: 'maths');

      // IDs contain timestamp and random components, so they will be distinct
      final ids1 = batch1.map((q) => q.id).toSet();
      final ids2 = batch2.map((q) => q.id).toSet();

      expect(ids1.intersection(ids2).length, equals(0));
    });
  });

  group('QuizScreen Widget Tests', () {
    testWidgets('Renders QuizScreen layout with category chips, Stars, and question card', (tester) async {
      tester.view.physicalSize = const Size(420, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Category chips
      expect(find.textContaining('सभी विषय'), findsOneWidget);
      expect(find.textContaining('FLN गणित'), findsOneWidget);
      expect(find.textContaining('संथाली भाषा'), findsOneWidget);

      // Star score and question count
      expect(find.textContaining('Stars'), findsOneWidget);
      expect(find.textContaining('प्रश्न 1/5'), findsOneWidget);

      // Teacher narration button
      expect(find.textContaining('प्रश्न सुनें'), findsOneWidget);

      // 4 Options A, B, C, D
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      // Action buttons
      expect(find.textContaining('नया सेट'), findsOneWidget);
    });

    testWidgets('Tapping an option reveals explanation and allows moving to next question', (tester) async {
      tester.view.physicalSize = const Size(420, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap option A
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Explanation should now be visible
      expect(find.textContaining('शिक्षक व्याख्या'), findsOneWidget);

      // Tap Next Question
      final nextBtn = find.textContaining('अगला प्रश्न');
      expect(nextBtn, findsOneWidget);
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Now on Question 2
      expect(find.textContaining('प्रश्न 2/5'), findsOneWidget);
    });

    testWidgets('QuizScreen renders without overflow on Tablet Landscape (1280x800)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('सभी विषय'), findsOneWidget);
      expect(find.textContaining('प्रश्न 1/5'), findsOneWidget);
    });
  });
}
