import 'package:palash_vaani/features/lessons/data/models/classroom_phrase_model.dart';
import 'package:palash_vaani/features/lessons/data/models/flashcard_model.dart';
import 'package:palash_vaani/features/lessons/data/models/learning_outcome_model.dart';
import 'package:palash_vaani/features/lessons/data/models/lesson_model.dart';
import 'package:palash_vaani/features/lessons/data/models/vocabulary_model.dart';
import 'package:palash_vaani/features/lessons/data/repositories/curriculum_repository.dart';

class MockCurriculumRepository implements ICurriculumRepository {
  List<LessonModel> lessons = [
    const LessonModel(
      id: 'g1_math_01',
      grade: 'Grade 1',
      subject: 'Mathematics',
      topic: 'Counting 1–10',
      titleHi: 'गिनती १ से १०',
      titleSat: 'ᱞᱮᱠᱷᱟ ᱑-᱑᱐',
      titleEn: 'Counting 1 to 10',
      objectiveHi: 'विद्यार्थी १ से १० तक संख्याओं को पहचानना, गिनना, बोलना और लिखना सीखेंगे।',
      objectiveSat: 'ᱜᱤᱫᱽᱨᱟᱹ ᱑ ᱠᱷᱚᱱ ᱑᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱞᱮᱠᱷᱟ ᱪᱤᱱᱦᱟᱹᱣ, ᱞᱮᱠᱷᱟ, ᱨᱚᱲ ᱟᱨ ᱚᱞ ᱠᱚ ᱪᱮᱫᱚᱜᱼᱟ᱾',
      contentHi: 'संख्या परिचय: १ (एक), २ (दो), ३ (तीन), ४ (चार), ५ (पाँच), ६ (छह), ७ (सात), ८ (आठ), ९ (नौ), १० (दस)।',
      contentSat: 'ᱮᱞ ᱩᱯᱨᱩᱢ: ᱑: ᱢᱤᱫ (Mid), ᱒: ᱵᱟᱨ (Bar), ᱓: ᱯᱮ (Pe), ᱔: ᱯᱩᱱ (Pun), ᱕: ᱢᱚᱬᱮ (Mone)᱾',
      activityHi: 'कक्षा गतिविधि: कंकड़ या उंगलियों को गिनें और संख्या का उच्चारण करें।',
      activitySat: 'ᱠᱟᱹᱢᱤᱦᱚᱨᱟ: ᱜᱤᱫᱽᱨᱟᱹ ᱫᱷᱤᱨᱤ ᱥᱮ ᱠᱟᱹᱴᱩᱵ ᱛᱩᱞ ᱠᱟᱛᱮ ᱞᱮᱠᱷᱟᱭᱟ᱾',
      assessmentHi: 'मूल्यांकन: ३ आम देखकर सही संख्या पहचानें।',
      assessmentSat: 'ᱵᱤᱰᱟᱹᱣ: ᱓ ᱩᱞ ᱧᱮᱞ ᱠᱟᱛᱮ ᱴᱷᱤᱠ ᱮᱞ ᱵᱟᱪᱷᱟᱣ ᱢᱮ᱾',
      verificationStatus: 'Prototype / Pending Native Verification',
      isCompleted: false,
      createdAt: '2026-09-28T00:00:00Z',
    ),
  ];

  List<LearningOutcomeModel> outcomes = [
    const LearningOutcomeModel(
      id: 'lo_g1_math_01_1',
      lessonId: 'g1_math_01',
      code: 'LO-M1.1',
      descriptionHi: '१ से १० तक संख्याओं की पहचान और मौखिक उच्चारण।',
      descriptionSat: '᱑ ᱠᱷᱚᱱ ᱑᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱮᱞ ᱪᱤᱱᱦᱟᱹᱣ ᱟᱨ ᱢᱚᱪᱟ ᱛᱮ ᱨᱚᱲ᱾',
      descriptionEn: 'Number recognition and verbal pronunciation from 1 to 10.',
      verificationStatus: 'Prototype / Pending Native Verification',
    ),
  ];

  @override
  Future<List<LessonModel>> getLessons({String? grade, String? subject}) async {
    return lessons.where((l) {
      if (grade != null && l.grade != grade) return false;
      if (subject != null && l.subject != subject) return false;
      return true;
    }).toList();
  }

  @override
  Future<LessonModel?> getLessonById(String id) async {
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LearningOutcomeModel>> getLearningOutcomes(String lessonId) async {
    return outcomes.where((lo) => lo.lessonId == lessonId).toList();
  }

  @override
  Future<List<ClassroomPhraseModel>> getClassroomPhrases() async {
    return [];
  }

  @override
  Future<List<VocabularyModel>> getVocabulary({String? lessonId}) async {
    return [];
  }

  @override
  Future<List<FlashcardModel>> getFlashcards({String? category}) async {
    return [];
  }

  @override
  Future<void> toggleLessonCompletion(String lessonId, bool isCompleted) async {
    final idx = lessons.indexWhere((l) => l.id == lessonId);
    if (idx != -1) {
      final old = lessons[idx];
      lessons[idx] = LessonModel(
        id: old.id,
        grade: old.grade,
        subject: old.subject,
        topic: old.topic,
        titleHi: old.titleHi,
        titleSat: old.titleSat,
        titleEn: old.titleEn,
        objectiveHi: old.objectiveHi,
        objectiveSat: old.objectiveSat,
        contentHi: old.contentHi,
        contentSat: old.contentSat,
        activityHi: old.activityHi,
        activitySat: old.activitySat,
        assessmentHi: old.assessmentHi,
        assessmentSat: old.assessmentSat,
        verificationStatus: old.verificationStatus,
        isCompleted: isCompleted,
        createdAt: old.createdAt,
      );
    }
  }
}
