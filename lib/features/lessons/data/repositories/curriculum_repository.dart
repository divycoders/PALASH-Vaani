import '../../../../core/database/database_helper.dart';
import '../models/classroom_phrase_model.dart';
import '../models/flashcard_model.dart';
import '../models/learning_outcome_model.dart';
import '../models/lesson_model.dart';
import '../models/vocabulary_model.dart';

abstract class ICurriculumRepository {
  Future<List<LessonModel>> getLessons({String? grade, String? subject});
  Future<LessonModel?> getLessonById(String id);
  Future<List<LearningOutcomeModel>> getLearningOutcomes(String lessonId);
  Future<List<ClassroomPhraseModel>> getClassroomPhrases();
  Future<List<VocabularyModel>> getVocabulary({String? lessonId});
  Future<List<FlashcardModel>> getFlashcards({String? category});
  Future<void> toggleLessonCompletion(String lessonId, bool isCompleted);
}

class CurriculumRepository implements ICurriculumRepository {
  final DatabaseHelper _dbHelper;

  CurriculumRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<LessonModel>> getLessons({String? grade, String? subject}) async {
    final db = await _dbHelper.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (grade != null && subject != null) {
      whereClause = 'grade = ? AND subject = ?';
      whereArgs = [grade, subject];
    } else if (grade != null) {
      whereClause = 'grade = ?';
      whereArgs = [grade];
    } else if (subject != null) {
      whereClause = 'subject = ?';
      whereArgs = [subject];
    }

    final maps = await db.query(
      'lessons',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at ASC',
    );

    return maps.map((m) => LessonModel.fromMap(m)).toList();
  }

  @override
  Future<LessonModel?> getLessonById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LessonModel.fromMap(maps.first);
  }

  @override
  Future<List<LearningOutcomeModel>> getLearningOutcomes(String lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'learning_outcomes',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'code ASC',
    );

    return maps.map((m) => LearningOutcomeModel.fromMap(m)).toList();
  }

  @override
  Future<List<ClassroomPhraseModel>> getClassroomPhrases() async {
    final db = await _dbHelper.database;
    final maps = await db.query('classroom_phrases');
    return maps.map((m) => ClassroomPhraseModel.fromMap(m)).toList();
  }

  @override
  Future<List<VocabularyModel>> getVocabulary({String? lessonId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'vocabulary',
      where: lessonId != null ? 'lesson_id = ?' : null,
      whereArgs: lessonId != null ? [lessonId] : null,
    );

    return maps.map((m) => VocabularyModel.fromMap(m)).toList();
  }

  @override
  Future<List<FlashcardModel>> getFlashcards({String? category}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'flashcards',
      where: category != null ? 'category = ?' : null,
      whereArgs: category != null ? [category] : null,
      orderBy: 'item_index ASC',
    );

    return maps.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  @override
  Future<void> toggleLessonCompletion(String lessonId, bool isCompleted) async {
    final db = await _dbHelper.database;
    await db.update(
      'lessons',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [lessonId],
    );
  }
}
