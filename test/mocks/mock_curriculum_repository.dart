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
    const LessonModel(
      id: 'g1_math_02',
      grade: 'Grade 1',
      subject: 'Mathematics',
      topic: 'Basic Shapes',
      titleHi: 'आकृतियाँ और स्थानीय समझ',
      titleSat: 'ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱯᱩᱱ ᱠᱳᱬ',
      titleEn: 'Basic Shapes & Spatial Understanding',
      objectiveHi: 'गोल (वृत्त), चौकोर (वर्ग) और तिकोनी (त्रिकोण) आकृतियों को दैनिक जीवन की वस्तुओं से पहचानना।',
      objectiveSat: 'ᱜᱩᱞᱟᱹᱭ (Circle), ᱯᱩᱱ ᱠᱳᱬ (Square) ᱟᱨ ᱯᱮ ᱠᱳᱬ (Triangle) ᱨᱩᱯ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      contentHi: 'रोटी गोल है (ᱜᱩᱞᱟᱹᱭ), स्लेट चौकोर है (ᱯᱩᱱ ᱠᱳᱬ)।',
      contentSat: 'ᱨᱩᱴᱤ ᱫᱚ ᱜᱩᱞᱟᱹᱭ ᱜᱮᱭᱟ, ᱥᱞᱮᱴ ᱫᱚ ᱯᱩᱱ ᱠᱳᱬ ᱜᱮᱭᱟ᱾',
      activityHi: 'आसपास की गोल और चौकोर वस्तुओं को छाँटकर अलग-अलग रखना।',
      activitySat: 'ᱟᱥᱯᱟᱥ ᱨᱮᱭᱟᱜ ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱯᱩᱱ ᱠᱳᱬ ᱡᱤᱱᱤᱥ ᱵᱷᱮᱜᱟᱨ ᱠᱟᱛᱮ ᱫᱚᱦᱚᱭ᱾',
      assessmentHi: 'सिक्का और किताब दिखाकर उनकी आकृति पूछना।',
      assessmentSat: 'ᱯᱩᱭᱥᱟᱹ ᱟᱨ ᱯᱩᱛᱷᱤ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱚᱱᱟ ᱨᱮᱭᱟᱜ ᱨᱩᱯ ᱠᱩᱞᱤ᱾',
      verificationStatus: 'Prototype / Pending Native Verification',
      isCompleted: false,
      createdAt: '2026-09-28T00:00:00Z',
    ),
    const LessonModel(
      id: 'g1_lang_01',
      grade: 'Grade 1',
      subject: 'Language',
      topic: 'Varnamala & Phonics',
      titleHi: 'वर्णमाला एवं ध्वनि बोध',
      titleSat: 'ᱚᱞ ᱪᱤᱠᱤ ᱟᱠᱷᱚᱨ ᱩᱯᱨᱩᱢ',
      titleEn: 'Alphabet & Phonological Awareness',
      objectiveHi: 'विद्यार्थी प्राथमिक ध्वनियों और अक्षरों को पहचानना और उच्चारित करना सीखेंगे।',
      objectiveSat: 'ᱜᱤᱫᱽᱨᱟᱹ ᱯᱩᱭᱞᱩ ᱥᱟᱰᱮ ᱟᱨ ᱟᱠᱷᱚᱨ ᱪᱤᱱᱦᱟᱹᱣ ᱟᱨ ᱨᱚᱲ ᱠᱚ ᱪᱮᱫᱚᱜᱼᱟ᱾',
      contentHi: 'ध्वनि परिचय: अ, ल (ᱚ, ᱞ), क, त (ᱠ, ᱛ), म, स (ᱢ, ᱥ)।',
      contentSat: 'ᱥᱟᱰᱮ ᱩᱯᱨᱩᱢ: ᱚ, ᱛ, ᱜ, ᱝ, ᱞ, ᱟ, ᱠ, ᱡ, ᱢ, ᱣ᱾',
      activityHi: 'चित्र देखकर पहला अक्षर बोलना।',
      activitySat: 'ᱪᱤᱛᱟᱹᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱯᱩᱭᱞᱩ ᱟᱠᱷᱚᱨ ᱞᱟᱹᱭ᱾',
      assessmentHi: 'शिक्षक चित्र दिखाएंगे और छात्र प्रथम ध्वनि का उच्चारण करेंगे।',
      assessmentSat: 'ᱢᱟᱪᱮᱛ ᱪᱤᱛᱟᱹᱨ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱠᱩᱞᱤᱭᱟ᱾',
      verificationStatus: 'Prototype / Pending Native Verification',
      isCompleted: false,
      createdAt: '2026-09-28T00:00:00Z',
    ),
    const LessonModel(
      id: 'g1_evs_01',
      grade: 'Grade 1',
      subject: 'Environmental',
      topic: 'My Family & Home',
      titleHi: 'मेरा परिवार और घर',
      titleSat: 'ᱤᱧᱟᱜ ᱜᱷᱟᱨᱚᱸᱡᱽ ᱟᱨ ᱚᱲᱟᱜ',
      titleEn: 'My Family & Home',
      objectiveHi: 'परिवार के सदस्यों के नाम और रिश्तों को मातृभाषा में पहचानना।',
      objectiveSat: 'ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱤᱱ ᱦᱚᱲ ᱟᱨ ᱥᱟᱹᱜᱟᱹᱭ ᱟᱭᱳ ᱟᱲᱟᱝ ᱛᱮ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      contentHi: 'माँ (ᱟᱭᱳ), पिताजी (ᱵᱟᱵᱟ), घर (ᱚᱲᱟᱜ)।',
      contentSat: 'ᱟᱭᱳ, ᱵᱟᱵᱟ, ᱚᱲᱟᱜ᱾',
      activityHi: 'परिवार के सदस्यों की संख्या बताना।',
      activitySat: 'ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱤᱱ ᱦᱚᱲ ᱞᱮᱠᱷᱟ ᱞᱟᱹᱭ᱾',
      assessmentHi: 'परिवार के चित्र में पहचानना।',
      assessmentSat: 'ᱜᱷᱟᱨᱚᱸᱡᱽ ᱪᱤᱛᱟᱹᱨ ᱨᱮ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      verificationStatus: 'Prototype / Pending Native Verification',
      isCompleted: false,
      createdAt: '2026-09-28T00:00:00Z',
    ),
    const LessonModel(
      id: 'g2_math_01',
      grade: 'Grade 2',
      subject: 'Mathematics',
      topic: 'Concrete Addition',
      titleHi: 'वस्तुओं के साथ जोड़',
      titleSat: 'ᱡᱤᱱᱤᱥ ᱥᱟᱶ ᱡᱚᱲᱟᱣ',
      titleEn: 'Concrete Addition up to 20',
      objectiveHi: 'विद्यार्थी दो समूहों की वस्तुओं को मिलाकर कुल संख्या बताना सीखेंगे।',
      objectiveSat: 'ᱜᱤᱫᱽᱨᱟᱹ ᱵᱟᱨ ᱜᱩᱴ ᱡᱤᱱᱤᱥ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱞᱮᱠᱷᱟ ᱞᱟᱹᱭ ᱠᱚ ᱪᱮᱫᱚᱜᱼᱟ᱾',
      contentHi: '३ पत्ते और २ पत्ते मिलकर ५ पत्ते बनते हैं (३ + २ = ५)।',
      contentSat: '᱓ ᱥᱟᱠᱟᱢ ᱟᱨ ᱒ ᱥᱟᱠᱟᱢ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱕ ᱥᱟᱠᱟᱢ ᱦᱩᱭᱩᱜᱼᱟ᱾',
      activityHi: 'कंकड़ों के दो समूह बनाकर जोड़ का खेल खेलना।',
      activitySat: 'ᱫᱷᱤᱨᱤ ᱨᱮᱭᱟᱜ ᱵᱟᱨ ᱜᱩᱴ ᱵᱮᱱᱟᱣ ᱠᱟᱛᱮ ᱡᱚᱲᱟᱣ ᱮᱱᱮᱡ᱾',
      assessmentHi: '४ + ३ का मौखिक अभ्यास।',
      assessmentSat: '᱔ + ᱓ ᱨᱮᱭᱟᱜ ᱢᱚᱪᱟ ᱛᱮ ᱠᱟᱹᱢᱤ᱾',
      verificationStatus: 'Prototype / Pending Native Verification',
      isCompleted: false,
      createdAt: '2026-09-28T00:00:00Z',
    ),
    const LessonModel(
      id: 'g2_lang_01',
      grade: 'Grade 2',
      subject: 'Language',
      topic: 'Picture Storytelling',
      titleHi: 'चित्र पठन एवं कहानी कथन',
      titleSat: 'ᱪᱤᱛᱟᱹᱨ ᱯᱟᱲᱦᱟᱣ ᱟᱨ ᱠᱟᱹᱦᱱᱤ',
      titleEn: 'Picture Storytelling & Expression',
      objectiveHi: 'चित्रों के क्रम को देखकर कहानी समझना।',
      objectiveSat: 'ᱪᱤᱛᱟᱹᱨ ᱛᱷᱟᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱠᱟᱹᱦᱱᱤ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      contentHi: 'चालाक लोमड़ी और खट्टे अंगूर की सचित्र कहानी।',
      contentSat: 'ᱪᱟᱞᱟᱠ ᱛᱩᱭᱩ ᱟᱨ ᱠᱷᱟᱴᱟ ᱟᱝᱜᱩᱨ ᱨᱮᱭᱟᱜ ᱠᱟᱹᱦᱱᱤ᱾',
      activityHi: 'चित्र देखकर कहानी सुनाना।',
      activitySat: 'ᱪᱤᱛᱟᱹᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱠᱟᱹᱦᱱᱤ ᱞᱟᱹᱭ᱾',
      assessmentHi: 'कौवे की कहानी पर प्रश्न।',
      assessmentSat: 'ᱠᱟᱣᱟ ᱠᱟᱹᱦᱱᱤ ᱨᱮ ᱠᱩᱠᱞᱤ᱾',
      verificationStatus: 'Prototype / Pending Native Verification',
      isCompleted: false,
      createdAt: '2026-09-28T00:00:00Z',
    ),
    const LessonModel(
      id: 'g3_math_01',
      grade: 'Grade 3',
      subject: 'Mathematics',
      topic: 'Multiplication',
      titleHi: 'बार-बार जोड़ से गुणा',
      titleSat: 'ᱜᱩᱬᱟᱹᱣ ᱟᱨ ᱫᱚᱦᱲᱟ ᱡᱚᱲᱟᱣ',
      titleEn: 'Multiplication through Repeated Addition',
      objectiveHi: 'समान समूहों को बार-बार जोड़कर गुणा समझना।',
      objectiveSat: 'ᱢᱤᱫ ᱞᱮᱠᱟᱱ ᱜᱩᱴ ᱫᱚᱦᱲᱟ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱜᱩᱬᱟᱹᱣ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      contentHi: '३ बार २ = ६ (३ × २ = ६)।',
      contentSat: '᱓ ᱫᱷᱟᱣ ᱒ = ᱖ (᱓ × ᱒ = ᱖)᱾',
      activityHi: 'बीजों के समूह गिनना।',
      activitySat: 'ᱡᱟᱝ ᱜᱩᱴ ᱞᱮᱠᱷᱟᱭ᱾',
      assessmentHi: '५ × ३ का अभ्यास।',
      assessmentSat: '᱕ × ᱓ ᱨᱮᱭᱟᱜ ᱠᱟᱹᱢᱤ᱾',
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
    const LearningOutcomeModel(
      id: 'lo_g1_math_01_2',
      lessonId: 'g1_math_01',
      code: 'LO-M1.2',
      descriptionHi: 'मूर्त वस्तुओं (कंकड़, बीज) को गिनकर संख्या बताना।',
      descriptionSat: 'ᱫᱷᱤᱨᱤ, ᱡᱟᱝ ᱮᱢᱟᱱ ᱡᱤᱱᱤᱥ ᱞᱮᱠᱷᱟ ᱠᱟᱛᱮ ᱮᱞ ᱞᱟᱹᱭ᱾',
      descriptionEn: 'One-to-one correspondence counting of concrete physical objects.',
      verificationStatus: 'Prototype / Pending Native Verification',
    ),
    const LearningOutcomeModel(
      id: 'lo_g1_math_02_1',
      lessonId: 'g1_math_02',
      code: 'LO-M1.3',
      descriptionHi: 'दैनिक जीवन की 2D आकृतियों की पहचान।',
      descriptionSat: 'ᱫᱤᱱᱟᱹᱢ ᱡᱤᱭᱚᱱ ᱨᱩᱯ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      descriptionEn: 'Identify basic 2D shapes.',
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
