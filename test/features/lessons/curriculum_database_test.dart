import 'package:flutter_test/flutter_test.dart';
import '../../mocks/mock_curriculum_repository.dart';

void main() {
  group('Curriculum Database & Repository Tests', () {
    late MockCurriculumRepository repository;

    setUp(() {
      repository = MockCurriculumRepository();
    });

    test('Retrieves Grade 1 Mathematics lessons', () async {
      final lessons = await repository.getLessons(
        grade: 'Grade 1',
        subject: 'Mathematics',
      );

      expect(lessons, isNotEmpty);
      final lesson = lessons.first;
      expect(lesson.id, 'g1_math_01');
      expect(lesson.topic, 'Counting 1–10');
      expect(lesson.titleHi, 'गिनती १ से १०');
      expect(lesson.titleSat, 'ᱞᱮᱠᱷᱟ ᱑-᱑᱐');
      expect(lesson.verificationStatus, 'Prototype / Pending Native Verification');
    });

    test('Retrieves learning outcomes for Counting 1-10', () async {
      final outcomes = await repository.getLearningOutcomes('g1_math_01');
      expect(outcomes, isNotEmpty);
      expect(outcomes.first.code, 'LO-M1.1');
      expect(outcomes.first.descriptionHi, contains('पहचान'));
      expect(outcomes.first.verificationStatus, 'Prototype / Pending Native Verification');
    });

    test('Toggles lesson completion state locally', () async {
      expect((await repository.getLessonById('g1_math_01'))?.isCompleted, isFalse);

      await repository.toggleLessonCompletion('g1_math_01', true);
      expect((await repository.getLessonById('g1_math_01'))?.isCompleted, isTrue);

      await repository.toggleLessonCompletion('g1_math_01', false);
      expect((await repository.getLessonById('g1_math_01'))?.isCompleted, isFalse);
    });
  });
}
