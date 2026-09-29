import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  DatabaseHelper.withDatabase(Database db) {
    _database = db;
  }

  Future<Database> get database async {
    if (_database != null) {
      await _seedDatabase(_database!);
      return _database!;
    }
    _database = await _initDB('palash_curriculum.db');
    await _seedDatabase(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _seedDatabase(db);
    }
  }

  Future<void> _insertOrUpdateLesson(Database db, Map<String, dynamic> lesson) async {
    final existing = await db.query(
      'lessons',
      columns: ['is_completed'],
      where: 'id = ?',
      whereArgs: [lesson['id']],
    );
    if (existing.isNotEmpty) {
      final isCompleted = existing.first['is_completed'] as int? ?? 0;
      lesson['is_completed'] = isCompleted;
    }
    await db.insert('lessons', lesson, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _insertOrUpdateOutcome(Database db, Map<String, dynamic> outcome) async {
    await db.insert('learning_outcomes', outcome, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Lessons Table
    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        grade TEXT NOT NULL,
        subject TEXT NOT NULL,
        topic TEXT NOT NULL,
        title_hi TEXT NOT NULL,
        title_sat TEXT NOT NULL,
        title_en TEXT NOT NULL,
        objective_hi TEXT NOT NULL,
        objective_sat TEXT NOT NULL,
        content_hi TEXT NOT NULL,
        content_sat TEXT NOT NULL,
        activity_hi TEXT NOT NULL,
        activity_sat TEXT NOT NULL,
        assessment_hi TEXT NOT NULL,
        assessment_sat TEXT NOT NULL,
        verification_status TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Learning Outcomes Table
    await db.execute('''
      CREATE TABLE learning_outcomes (
        id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        code TEXT NOT NULL,
        description_hi TEXT NOT NULL,
        description_sat TEXT NOT NULL,
        description_en TEXT NOT NULL,
        verification_status TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // 3. Classroom Phrases Table
    await db.execute('''
      CREATE TABLE classroom_phrases (
        id TEXT PRIMARY KEY,
        intent TEXT NOT NULL,
        hindi TEXT NOT NULL,
        santhali TEXT NOT NULL,
        ol_chiki TEXT NOT NULL,
        latin TEXT NOT NULL,
        audio_path TEXT,
        verification_status TEXT NOT NULL
      )
    ''');

    // 4. Vocabulary Table
    await db.execute('''
      CREATE TABLE vocabulary (
        id TEXT PRIMARY KEY,
        lesson_id TEXT,
        word_hi TEXT NOT NULL,
        word_sat TEXT NOT NULL,
        ol_chiki TEXT NOT NULL,
        latin TEXT NOT NULL,
        meaning_en TEXT NOT NULL,
        category TEXT NOT NULL,
        verification_status TEXT NOT NULL
      )
    ''');

    // 5. Flashcards Table
    await db.execute('''
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        item_index INTEGER NOT NULL,
        visual_symbol TEXT NOT NULL,
        word_hi TEXT NOT NULL,
        word_sat TEXT NOT NULL,
        latin TEXT NOT NULL,
        description TEXT NOT NULL,
        audio_path TEXT,
        verification_status TEXT NOT NULL
      )
    ''');

    // Seed Complete Primary Dataset
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    const verificationNotice = 'Prototype / Pending Native Verification';
    final nowIso = DateTime.now().toIso8601String();

    // ==========================================
    // GRADE 1 LESSONS
    // ==========================================

    // G1 - Math 1: Counting 1-10
    await _insertOrUpdateLesson(db, {
      'id': 'g1_math_01',
      'grade': 'Grade 1',
      'subject': 'Mathematics',
      'topic': 'Counting 1–10',
      'title_hi': 'गिनती १ से १०',
      'title_sat': 'ᱞᱮᱠᱷᱟ ᱑-᱑᱐',
      'title_en': 'Counting 1 to 10',
      'objective_hi': 'विद्यार्थी १ से १० तक संख्याओं को पहचानना, गिनना, बोलना और लिखना सीखेंगे।',
      'objective_sat': 'ᱜᱤᱫᱽᱨᱟᱹ ᱑ ᱠᱷᱚᱱ ᱑᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱞᱮᱠᱷᱟ ᱪᱤᱱᱦᱟᱹᱣ, ᱞᱮᱠᱷᱟ, ᱨᱚᱲ ᱟᱨ ᱚᱞ ᱠᱚ ᱪᱮᱫᱚᱜᱼᱟ᱾',
      'content_hi': 'संख्या परिचय: १ (एक), २ (दो), ३ (तीन), ४ (चार), ५ (पाँच), ६ (छह), ७ (सात), ८ (आठ), ९ (नौ), १० (दस)। स्थानीय वातावरण के पत्तों और बीजों से गिनना सीखें।',
      'content_sat': 'ᱮᱞ ᱩᱯᱨᱩᱢ: ᱑: ᱢᱤᱫ (Mid), ᱒: ᱵᱟᱨ (Bar), ᱓: ᱯᱮ (Pe), ᱔: ᱯᱩᱱ (Pun), ᱕: ᱢᱚᱬᱮ (Mone), ᱖: ᱛᱩᱨᱩᱭ (Turuy), ᱗: ᱮᱭᱟᱭ (Eyay), ᱘: ᱤᱨᱟᱹᱞ (Iral), ᱙: ᱟᱨᱮ (Are), ᱑᱐: ᱜᱮᱞ (Gel)᱾',
      'activity_hi': 'कक्षा गतिविधि: बच्चे कंकड़ या उंगलियों को उठाकर एक साथ गिनेंगे और संख्या को दोनों भाषाओं में दोहराएंगे।',
      'activity_sat': 'ᱠᱟᱹᱢᱤᱦᱚᱨᱟ: ᱜᱤᱫᱽᱨᱟᱹ ᱫᱷᱤᱨᱤ ᱥᱮ ᱠᱟᱹᱴᱩᱵ ᱛᱩᱞ ᱠᱟᱛᱮ ᱢᱤᱫ ᱥᱟᱶᱛᱮ ᱞᱮᱠᱷᱟᱭᱟ ᱟᱨ ᱵᱟᱱᱟᱨ ᱯᱟᱹᱨᱥᱤ ᱛᱮ ᱨᱚᱲ ᱠᱚ ᱫᱚᱦᱲᱟᱭᱟ᱾',
      'assessment_hi': 'मूल्यांकन: शिक्षक ३ उंगलियाँ दिखाएंगे और छात्र बोलेंगे: तीन (३) / ᱯᱮ (᱓)।',
      'assessment_sat': 'ᱵᱤᱰᱟᱹᱣ: ᱢᱟᱪᱮᱛ ᱓ ᱠᱟᱹᱴᱩᱵ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱠᱩᱞᱤᱭᱟ, ᱜᱤᱫᱽᱨᱟᱹ ᱨᱚᱲᱟ: ᱯᱮ (᱓) / तीन (३)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - Math 2: Basic Shapes
    await _insertOrUpdateLesson(db, {
      'id': 'g1_math_02',
      'grade': 'Grade 1',
      'subject': 'Mathematics',
      'topic': 'Basic Shapes',
      'title_hi': 'आकृतियाँ और स्थानीय समझ',
      'title_sat': 'ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱯᱩᱱ ᱠᱳᱬ',
      'title_en': 'Basic Shapes & Spatial Understanding',
      'objective_hi': 'गोल (वृत्त), चौकोर (वर्ग) और तिकोनी (त्रिकोण) आकृतियों को दैनिक जीवन की वस्तुओं से पहचानना।',
      'objective_sat': 'ᱜᱩᱞᱟᱹᱭ (Circle), ᱯᱩᱱ ᱠᱳᱬ (Square) ᱟᱨ ᱯᱮ ᱠᱳᱬ (Triangle) ᱨᱩᱯ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      'content_hi': 'रोटी गोल है (ᱜᱩᱞᱟᱹᱭ), स्लेट चौकोर है (ᱯᱩᱱ ᱠᱳᱬ), समोसा तिकोना है (ᱯᱮ ᱠᱳᱬ)।',
      'content_sat': 'ᱨᱩᱴᱤ ᱫᱚ ᱜᱩᱞᱟᱹᱭ ᱜᱮᱭᱟ, ᱥᱞᱮᱴ ᱫᱚ ᱯᱩᱱ ᱠᱳᱬ ᱜᱮᱭᱟ, ᱥᱤᱝᱜᱟᱲᱟ ᱫᱚ ᱯᱮ ᱠᱳᱬ ᱜᱮᱭᱟ᱾',
      'activity_hi': 'आसपास की गोल और चौकोर वस्तुओं को छाँटकर अलग-अलग रखना।',
      'activity_sat': 'ᱟᱥᱯᱟᱥ ᱨᱮᱭᱟᱜ ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱯᱩᱱ ᱠᱳᱬ ᱡᱤᱱᱤᱥ ᱵᱷᱮᱜᱟᱨ ᱠᱟᱛᱮ ᱫᱚᱦᱚᱭ᱾',
      'assessment_hi': 'सिक्का और किताब दिखाकर उनकी आकृति पूछना।',
      'assessment_sat': 'ᱯᱩᱭᱥᱟᱹ ᱟᱨ ᱯᱩᱛᱷᱤ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱚᱱᱟ ᱨᱮᱭᱟᱜ ᱨᱩᱯ ᱠᱩᱞᱤ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - Math 3: Comparison
    await _insertOrUpdateLesson(db, {
      'id': 'g1_math_03',
      'grade': 'Grade 1',
      'subject': 'Mathematics',
      'topic': 'Comparison',
      'title_hi': 'तुलना: बड़ा-छोटा, भारी-हल्का',
      'title_sat': 'ᱢᱟᱨᱟᱝ-ᱦᱩᱰᱤᱧ, ᱦᱟᱢᱟᱞ-ᱨᱟᱣᱟᱞ',
      'title_en': 'Comparison: Big-Small & Heavy-Light',
      'objective_hi': 'वस्तुओं के आकार (बड़ा/छोटा) और वजन (भारी/हल्का) की प्रत्यक्ष तुलना करना।',
      'objective_sat': 'ᱡᱤᱱᱤᱥ ᱨᱮᱭᱟᱜ ᱢᱟᱨᱟᱝ/ᱦᱩᱰᱤᱧ ᱟᱨ ᱦᱟᱢᱟᱞ/ᱨᱟᱣᱟᱞ ᱨᱮᱭᱟᱜ ᱛᱩᱞᱟᱹᱡᱚᱠᱷᱟ᱾',
      'content_hi': 'हाथी बड़ा है (ᱢᱟᱨᱟᱝ), चूहा छोटा है (ᱦᱩᱰᱤᱧ)। पत्थर भारी है (ᱦᱟᱢᱟᱞ), पत्ता हल्का है (ᱨᱟᱣᱟᱞ)।',
      'content_sat': 'ᱦᱟᱹᱛᱤ ᱫᱚ ᱢᱟᱨᱟᱝ ᱜᱮᱭᱟ, ᱜᱩᱰᱩ ᱫᱚ ᱦᱩᱰᱤᱧ ᱜᱮᱭᱟ᱾ ᱫᱷᱤᱨᱤ ᱫᱚ ᱦᱟᱢᱟᱞ ᱜᱮᱭᱟ, ᱥᱟᱠᱟᱢ ᱫᱚ ᱨᱟᱣᱟᱞ ᱜᱮᱭᱟ᱾',
      'activity_hi': 'एक हाथ में पत्थर और दूसरे में पत्ता उठाकर भारी-हल्के का प्रत्यक्ष अनुभव करना।',
      'activity_sat': 'ᱢᱤᱫ ᱛᱤ ᱨᱮ ᱫᱷᱤᱨᱤ ᱟᱨ ᱫᱚᱥᱟᱨ ᱛᱤ ᱨᱮ ᱥᱟᱠᱟᱢ ᱥᱟᱵ ᱠᱟᱛᱮ ᱦᱟᱢᱟᱞ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      'assessment_hi': 'कद्दू और नींबू दिखाकर पूछना: कौन बड़ा और भारी है?',
      'assessment_sat': 'ᱦᱳᱛᱚᱛ ᱟᱨ ᱞᱮᱢᱵᱳ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱠᱩᱞᱤ: ᱚᱠᱟᱴᱟᱜ ᱢᱟᱨᱟᱝ ᱟᱨ ᱦᱟᱢᱟᱞ ᱜᱮᱭᱟ?',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - Math 4: Numbers 11-20
    await _insertOrUpdateLesson(db, {
      'id': 'g1_math_04',
      'grade': 'Grade 1',
      'subject': 'Mathematics',
      'topic': 'Numbers 11–20',
      'title_hi': 'संख्याएं ११ से २० (दहाई और इकाई)',
      'title_sat': 'ᱞᱮᱠᱷᱟ ᱑᱑-᱒᱐ (ᱜᱮᱞ ᱟᱨ ᱢᱤᱫ)',
      'title_en': 'Numbers 11 to 20 (Tens & Units)',
      'objective_hi': '१० तीलियों का बंडल बनाकर ११ से २० तक की संख्याओं को समझना और गिनना।',
      'objective_sat': 'ᱜᱮᱞ ᱜᱚᱴᱟᱝ ᱨᱮᱭᱟᱜ ᱵᱤᱸᱰᱟᱹ ᱵᱮᱱᱟᱣ ᱠᱟᱛᱮ ᱑᱑ ᱠᱷᱚᱱ ᱒᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱞᱮᱠᱷᱟ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      'content_hi': '१० तीलियों का १ बंडल + १ तीली = ११ (ग्यारह / ᱜᱮᱞ ᱢᱤᱫ)। १० का बंडल + ५ तीलियाँ = १५ (पंद्रह / ᱜᱮᱞ ᱢᱚᱬᱮ)।',
      'content_sat': '᱑᱐ ᱡᱟᱹᱴᱤ ᱨᱮᱭᱟᱜ ᱢᱤᱫ ᱵᱤᱸᱰᱟᱹ + ᱑ ᱡᱟᱹᱴᱤ = ᱑᱑ (ᱜᱮᱞ ᱢᱤᱫ)᱾ ᱑᱐ ᱨᱮᱭᱟᱜ ᱵᱤᱸᱰᱟᱹ + ᱕ ᱡᱟᱹᱴᱤ = ᱑᱕ (ᱜᱮᱞ ᱢᱚᱬᱮ)᱾',
      'activity_hi': 'तीलियों से १०-१० के बंडल बनाने और खुली तीलियाँ जोड़ने की गतिविधि।',
      'activity_sat': 'ᱡᱟᱹᱴᱤ ᱠᱚ ᱛᱮ ᱑᱐-᱑᱐ ᱜᱚᱴᱟᱝ ᱨᱮᱭᱟᱜ ᱵᱤᱸᱰᱟᱹ ᱵᱮᱱᱟᱣ ᱠᱟᱹᱢᱤ᱾',
      'assessment_hi': '१ बंडल और ३ खुली तीलियाँ दिखाकर कुल संख्या पूछना (१३ / ᱜᱮᱞ ᱯᱮ)।',
      'assessment_sat': 'ᱢᱤᱫ ᱵᱤᱸᱰᱟᱹ ᱟᱨ ᱓ ᱡᱟᱹᱴᱤ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱞᱮᱠᱷᱟ ᱠᱩᱞᱤ (᱑᱓ / ᱜᱮᱞ ᱯᱮ)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - Language 1: Phonics & Ol Chiki
    await _insertOrUpdateLesson(db, {
      'id': 'g1_lang_01',
      'grade': 'Grade 1',
      'subject': 'Language',
      'topic': 'Varnamala & Phonics',
      'title_hi': 'वर्णमाला एवं ध्वनि बोध',
      'title_sat': 'ᱚᱞ ᱪᱤᱠᱤ ᱟᱠᱷᱚᱨ ᱩᱯᱨᱩᱢ',
      'title_en': 'Alphabet & Phonological Awareness',
      'objective_hi': 'विद्यार्थी प्राथमिक ध्वनियों और अक्षरों को पहचानना और उच्चारित करना सीखेंगे।',
      'objective_sat': 'ᱜᱤᱫᱽᱨᱟᱹ ᱯᱩᱭᱞᱩ ᱥᱟᱰᱮ ᱟᱨ ᱟᱠᱷᱚᱨ ᱪᱤᱱᱦᱟᱹᱣ ᱟᱨ ᱨᱚᱲ ᱠᱚ ᱪᱮᱫᱚᱜᱼᱟ᱾',
      'content_hi': 'ध्वनि परिचय: अ, ल (ᱚ, ᱞ), क, त (ᱠ, ᱛ), म, स (ᱢ, ᱥ)। स्थानीय शब्दों के प्रथम वर्ण की पहचान।',
      'content_sat': 'ᱥᱟᱰᱮ ᱩᱯᱨᱩᱢ: ᱚ, ᱛ, ᱜ, ᱝ, ᱞ, ᱟ, ᱠ, ᱡ, ᱢ, ᱣ᱾ ᱟᱹᱲᱟᱹ ᱨᱮᱭᱟᱜ ᱯᱩᱭᱞᱩ ᱟᱠᱷᱚᱨ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      'activity_hi': 'चित्र देखकर पहला अक्षर बोलना: दारे (पेड़) का "द", बाहा (फूल) का "ब"।',
      'activity_sat': 'ᱪᱤᱛᱟᱹᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱯᱩᱭᱞᱩ ᱟᱠᱷᱚᱨ ᱞᱟᱹᱭ: ᱫᱟᱨᱮ ᱨᱮᱭᱟᱜ "ᱫ", ᱵᱟᱦᱟ ᱨᱮᱭᱟᱜ "ᱵ"᱾',
      'assessment_hi': 'शिक्षक चित्र दिखाएंगे और छात्र प्रथम ध्वनि का उच्चारण करेंगे।',
      'assessment_sat': 'ᱢᱟᱪᱮᱛ ᱪᱤᱛᱟᱹᱨ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱠᱩᱞᱤᱭᱟ ᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ ᱯᱩᱭᱞᱩ ᱥᱟᱰᱮ ᱠᱚ ᱞᱟᱹᱭᱟ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - Language 2: Two-Letter Words
    await _insertOrUpdateLesson(db, {
      'id': 'g1_lang_02',
      'grade': 'Grade 1',
      'subject': 'Language',
      'topic': 'Two-Letter Words',
      'title_hi': 'दो अक्षर वाले सरल शब्द',
      'title_sat': 'ᱵᱟᱨ ᱟᱠᱷᱚᱨ ᱨᱮᱭᱟᱜ ᱟᱹᱲᱟᱹ',
      'title_en': 'Two-Letter Simple Words & Blending',
      'objective_hi': 'दो अक्षरों को जोड़कर सरल सार्थक शब्द पढ़ना और बोलना।',
      'objective_sat': 'ᱵᱟᱨ ᱟᱠᱷᱚᱨ ᱡᱚᱲᱟᱣ ᱠᱟᱛᱮ ᱥᱟᱵᱟᱫ ᱯᱟᱲᱦᱟᱣ ᱟᱨ ᱨᱚᱲ ᱪᱮᱫᱚᱜ᱾',
      'content_hi': 'घर (ᱚᱲᱟᱜ), जल/पानी (ᱫᱟᱜ), फल (ᱡᱚ), वन/पेड़ (ᱫᱟᱨᱮ)।',
      'content_sat': 'ᱚᱲᱟᱜ (Olag - Ghar), ᱫᱟᱜ (Daag - Jal), ᱡᱚ (Jo - Phal), ᱫᱟᱨᱮ (Dare - Ped)᱾',
      'activity_hi': 'अक्षर कार्डों को पास लाकर शब्द बनाने का खेल (घ + र = घर, ᱚ + ᱲᱟ + ᱜ = ᱚᱲᱟᱜ)।',
      'activity_sat': 'ᱟᱠᱷᱚᱨ ᱠᱟᱨᱰ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱟᱹᱲᱟᱹ ᱵᱮᱱᱟᱣ ᱮᱱᱮᱡ᱾',
      'assessment_hi': '"जल" और "घर" का चित्र देखकर शब्द बोलना।',
      'assessment_sat': '"ᱫᱟᱜ" ᱟᱨ "ᱚᱲᱟᱜ" ᱨᱮᱭᱟᱜ ᱪᱤᱛᱟᱹᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱟᱹᱲᱟᱹ ᱨᱚᱲ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - Language 3: Action Rhymes
    await _insertOrUpdateLesson(db, {
      'id': 'g1_lang_03',
      'grade': 'Grade 1',
      'subject': 'Language',
      'topic': 'Rhymes & Choral Songs',
      'title_hi': 'बालगीत एवं हावभाव कविता',
      'title_sat': 'ᱜᱤᱫᱽᱨᱟᱹ ᱥᱮᱨᱮᱧ ᱟᱨ ᱮᱱᱮᱡ',
      'title_en': 'Action Rhymes & Choral Recitation',
      'objective_hi': 'लय और ताल के साथ बालगीत गाना एवं हाव-भाव प्रदर्शित करना।',
      'objective_sat': 'ᱨᱟᱦᱟ ᱟᱨ ᱛᱟᱲ ᱥᱟᱶ ᱜᱤᱫᱽᱨᱟᱹ ᱥᱮᱨᱮᱧ ᱨᱚᱲ ᱟᱨ ᱦᱤᱞᱟᱹᱣ᱾',
      'content_hi': '"चाँदा मामा दूर के, पुए पकाएं बूर के" / "ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱥᱮᱨᱢᱟ ᱨᱮ, ᱢᱟᱨᱥᱟᱞ ᱮᱢᱚᱜ ᱧᱤᱫᱟᱹ ᱨᱮ"।',
      'content_sat': 'ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱥᱮᱨᱢᱟ ᱨᱮ, ᱢᱟᱨᱥᱟᱞ ᱮᱢᱚᱜ ᱧᱤᱫᱟᱹ ᱨᱮ, ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ ᱦᱟᱸᱥᱟ ᱨᱮ᱾',
      'activity_hi': 'गोलाकार घेरे में खड़े होकर ताली बजाते हुए बालगीत गाना।',
      'activity_sat': 'ᱜᱩᱞᱟᱹᱭ ᱛᱮ ᱛᱤᱸᱜᱩ ᱠᱟᱛᱮ ᱛᱟᱞᱤ ᱵᱟᱡᱟᱣ ᱥᱟᱶᱛᱮ ᱥᱮᱨᱮᱧ᱾',
      'assessment_hi': 'शिक्षक के साथ तुकबंदी वाले शब्दों को दोहराना।',
      'assessment_sat': 'ᱢᱟᱪᱮᱛ ᱥᱟᱶ ᱥᱮᱨᱮᱧ ᱨᱮᱭᱟᱜ ᱢᱩᱪᱟᱹᱫ ᱟᱹᱲᱟᱹ ᱫᱚᱦᱲᱟᱭ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - EVS 1: Family & Home
    await _insertOrUpdateLesson(db, {
      'id': 'g1_evs_01',
      'grade': 'Grade 1',
      'subject': 'Environmental',
      'topic': 'My Family & Home',
      'title_hi': 'मेरा परिवार और घर',
      'title_sat': 'ᱤᱧᱟᱜ ᱜᱷᱟᱨᱚᱸᱡᱽ ᱟᱨ ᱚᱲᱟᱜ',
      'title_en': 'My Family & Home',
      'objective_hi': 'परिवार के सदस्यों के नाम और रिश्तों को मातृभाषा में पहचानना।',
      'objective_sat': 'ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱤᱱ ᱦᱚᱲ ᱟᱨ ᱥᱟᱹᱜᱟᱹᱭ ᱟᱭᱳ ᱟᱲᱟᱝ ᱛᱮ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      'content_hi': 'माँ (ᱟᱭᱳ - Ayo), पिताजी (ᱵᱟᱵᱟ - Baba), भाई (ᱵᱚᱭᱦᱟ - Boyha), बहन (ᱢᱤᱥᱤ - Misi), घर (ᱚᱲᱟᱜ - Olag)।',
      'content_sat': 'ᱟᱭᱳ (Maa), ᱵᱟᱵᱟ (Baba), ᱫᱟᱫᱟ/ᱵᱚᱭᱦᱟ (Bhai), ᱢᱤᱥᱤ (Bahan), ᱚᱲᱟᱜ (Home)᱾',
      'activity_hi': 'अपने परिवार के सदस्यों की संख्या उंगलियों पर गिनकर बताना।',
      'activity_sat': 'ᱟᱯᱱᱟᱨ ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱤᱱ ᱦᱚᱲ ᱠᱟᱹᱴᱩᱵ ᱛᱮ ᱞᱮᱠᱷᱟ ᱠᱟᱛᱮ ᱞᱟᱹᱭ᱾',
      'assessment_hi': 'परिवार के चित्र में माँ और पिताजी को पहचानना।',
      'assessment_sat': 'ᱜᱷᱟᱨᱚᱸᱡᱽ ᱪᱤᱛᱟᱹᱨ ᱨᱮ ᱟᱭᱳ ᱟᱨ ᱵᱟᱵᱟ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - EVS 2: Plants & Trees
    await _insertOrUpdateLesson(db, {
      'id': 'g1_evs_02',
      'grade': 'Grade 1',
      'subject': 'Environmental',
      'topic': 'Plants & Trees',
      'title_hi': 'पेड़-पौधे और हरियाली',
      'title_sat': 'ᱫᱟᱨᱮ-ᱱᱟᱹᱲᱤ ᱟᱨ ᱥᱟᱨᱡᱚᱢ',
      'title_en': 'Plants, Trees & Greenery',
      'objective_hi': 'स्थानीय पेड़ों (साल, महुआ, नीम) और पौधों के अंगों की पहचान करना।',
      'objective_sat': 'ᱟᱥᱯᱟᱥ ᱨᱮᱭᱟᱜ ᱫᱟᱨᱮ (ᱥᱟᱨᱡᱚᱢ, ᱢᱟᱛᱠᱚᱢ, ᱱᱤᱢ) ᱟᱨ ᱥᱟᱠᱟᱢ ᱪᱤᱱᱦᱟᱹᱣ᱾',
      'content_hi': 'साल का पेड़ (ᱥᱟᱨᱡᱚᱢ - Sarjom), महुआ (ᱢᱟᱛᱠᱚᱢ - Matkom), पत्ता (ᱥᱟᱠᱟᱢ - Sakam), फूल (ᱵᱟᱦᱟ - Baha)।',
      'content_sat': 'ᱥᱟᱨᱡᱚᱢ ᱫᱟᱨᱮ (Sal Tree), ᱢᱟᱛᱠᱚᱢ (Mahua), ᱥᱟᱠᱟᱢ (Patta), ᱵᱟᱦᱟ (Phool)᱾',
      'activity_hi': 'विद्यालय परिसर में गिरे हुए अलग-अलग प्रकार के पत्ते इकट्ठा करना।',
      'activity_sat': 'ᱵᱤᱨᱫᱟᱹᱜᱟᱲ ᱨᱮ ᱧᱩᱨ ᱟᱠᱟᱱ ᱵᱷᱮᱜᱟᱨ ᱵᱷᱮᱜᱟᱨ ᱥᱟᱠᱟᱢ ᱡᱟᱣᱨᱟᱭ᱾',
      'assessment_hi': 'साल और महुआ के पत्तों को देखकर उनका नाम बताना।',
      'assessment_sat': 'ᱥᱟᱨᱡᱚᱢ ᱟᱨ ᱢᱟᱛᱠᱚᱢ ᱥᱟᱠᱟᱢ ᱧᱮᱞ ᱠᱟᱛᱮ ᱧᱩᱛᱩᱢ ᱞᱟᱹᱭ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G1 - EVS 3: Cleanliness & Handwashing
    await _insertOrUpdateLesson(db, {
      'id': 'g1_evs_03',
      'grade': 'Grade 1',
      'subject': 'Environmental',
      'topic': 'Cleanliness & Hygiene',
      'title_hi': 'स्वच्छता और हाथ धोना',
      'title_sat': 'ᱥᱟᱯᱷᱟ-ᱥᱟᱹᱯᱷᱤ ᱟᱨ ᱛᱤ ᱟᱹᱨᱩᱵ',
      'title_en': 'Cleanliness & Handwashing Routine',
      'objective_hi': 'भोजन से पहले साबुन से हाथ धोने और साफ़ पानी पीने का महत्व समझना।',
      'objective_sat': 'ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱥᱟᱵᱚᱱ ᱛᱮ ᱛᱤ ᱟᱹᱨᱩᱵ ᱟᱨ ᱥᱟᱯᱷᱟ ᱫᱟᱜ ᱧᱩ ᱨᱮᱭᱟᱜ ᱜᱩᱱ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      'content_hi': 'खाना खाने से पहले हाथ धोना (ᱛᱤ ᱟᱹᱨᱩᱵ - Ti Arub), साफ़ पानी पीना (ᱥᱟᱯᱷᱟ ᱫᱟᱜ - Sapha Daag), नाखून साफ़ रखना।',
      'content_sat': 'ᱫᱟᱠᱟ ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱛᱤ ᱟᱹᱨᱩᱵ, ᱥᱟᱯᱷᱟ ᱫᱟᱜ ᱧᱩ, ᱨᱩᱣᱟᱹ ᱠᱷᱚᱱ ᱵᱟᱧᱪᱟᱣ᱾',
      'activity_hi': 'मध्याह्न भोजन (MDM) से पहले साबुन से हाथ धोने का सही क्रम अभ्यास करना।',
      'activity_sat': 'ᱫᱤᱱᱟᱹᱢ ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱥᱟᱵᱚᱱ ᱛᱮ ᱛᱤ ᱟᱹᱨᱩᱵ ᱨᱮᱭᱟᱜ ᱦᱚᱨᱟ ᱪᱮᱫᱚᱜ᱾',
      'assessment_hi': 'हाथ धोने के मुख्य चरण करके दिखाना।',
      'assessment_sat': 'ᱛᱤ ᱟᱹᱨᱩᱵ ᱨᱮᱭᱟᱜ ᱠᱟᱹᱢᱤ ᱩᱫᱩᱜ ᱢᱮ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // ==========================================
    // GRADE 2 LESSONS
    // ==========================================

    // G2 - Math 1: Concrete Addition
    await _insertOrUpdateLesson(db, {
      'id': 'g2_math_01',
      'grade': 'Grade 2',
      'subject': 'Mathematics',
      'topic': 'Concrete Addition',
      'title_hi': 'वस्तुओं के साथ जोड़',
      'title_sat': 'ᱡᱤᱱᱤᱥ ᱥᱟᱶ ᱡᱚᱲᱟᱣ',
      'title_en': 'Concrete Addition up to 20',
      'objective_hi': 'विद्यार्थी दो समूहों की वस्तुओं को मिलाकर कुल संख्या बताना सीखेंगे।',
      'objective_sat': 'ᱜᱤᱫᱽᱨᱟᱹ ᱵᱟᱨ ᱜᱩᱴ ᱡᱤᱱᱤᱥ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱞᱮᱠᱷᱟ ᱞᱟᱹᱭ ᱠᱚ ᱪᱮᱫᱚᱜᱼᱟ᱾',
      'content_hi': '३ पत्ते और २ पत्ते मिलकर ५ पत्ते बनते हैं (३ + २ = ५ / ᱯᱮ + ᱵᱟᱨ = ᱢᱚᱬᱮ)।',
      'content_sat': '᱓ ᱥᱟᱠᱟᱢ ᱟᱨ ᱒ ᱥᱟᱠᱟᱢ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱕ ᱥᱟᱠᱟᱢ ᱦᱩᱭᱩᱜᱼᱟ (ᱯᱮ + ᱵᱟᱨ = ᱢᱚᱬᱮ)᱾',
      'activity_hi': 'कंकड़ों के दो समूह बनाकर जोड़ का खेल खेलना।',
      'activity_sat': 'ᱫᱷᱤᱨᱤ ᱨᱮᱭᱟᱜ ᱵᱟᱨ ᱜᱩᱴ ᱵᱮᱱᱟᱣ ᱠᱟᱛᱮ ᱡᱚᱲᱟᱣ ᱮᱱᱮᱡ᱾',
      'assessment_hi': '४ + ३ का मौखिक एवं स्लेट पर अभ्यास।',
      'assessment_sat': '᱔ + ᱓ ᱨᱮᱭᱟᱜ ᱢᱚᱪᱟ ᱛᱮ ᱟᱨ ᱥᱞᱮᱴ ᱨᱮ ᱠᱟᱹᱢᱤ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G2 - Math 2: Subtraction
    await _insertOrUpdateLesson(db, {
      'id': 'g2_math_02',
      'grade': 'Grade 2',
      'subject': 'Mathematics',
      'topic': 'Subtraction',
      'title_hi': 'घटाव और बाकी निकालना',
      'title_sat': 'ᱜᱷᱟᱴᱟᱣ ᱟᱨ ᱠᱚᱢ',
      'title_en': 'Subtraction & Taking Away',
      'objective_hi': 'वस्तुओं के समूह में से कुछ वस्तुएं हटाकर शेष संख्या ज्ञात करना।',
      'objective_sat': 'ᱡᱤᱱᱤᱥ ᱨᱮᱭᱟᱜ ᱜᱩᱴ ᱠᱷᱚᱱ ᱛᱤᱱᱟᱹᱜ ᱜᱟᱱ ᱚᱪᱚᱜ ᱠᱟᱛᱮ ᱥᱟᱨᱮᱡ ᱮᱞ ᱞᱮᱠᱷᱟ᱾',
      'content_hi': '५ चिड़ियों में से २ उड़ गईं, तो ३ बचीं (५ - २ = ३ / ᱢᱚᱬᱮ - ᱵᱟᱨ = ᱯᱮ)।',
      'content_sat': '᱕ ᱪᱮᱬᱮ ᱠᱷᱚᱱ ᱒ ᱠᱤᱱ ᱩᱰᱟᱹᱣ ᱮᱱᱟ, ᱮᱱᱠᱷᱟᱱ ᱓ ᱠᱚ ᱥᱟᱨᱮᱡ ᱮᱱᱟ (᱕ - ᱒ = ᱓)᱾',
      'activity_hi': 'उंगलियों को मोड़कर घटाने की क्रिया का खेल।',
      'activity_sat': 'ᱠᱟᱹᱴᱩᱵ ᱞᱮᱵᱮᱫ ᱠᱟᱛᱮ ᱜᱷᱟᱴᱟᱣ ᱨᱮᱭᱟᱜ ᱮᱱᱮᱡ᱾',
      'assessment_hi': '७ में से ३ कंकड़ निकालने पर कितने बचेंगे? (४ / ᱯᱩᱱ)।',
      'assessment_sat': '᱗ ᱠᱷᱚᱱ ᱓ ᱫᱷᱤᱨᱤ ᱚᱪᱚᱜ ᱞᱮᱠᱷᱟᱱ ᱛᱤᱱᱟᱹᱜ ᱥᱟᱨᱮᱡᱚᱜᱼᱟ? (᱔ / ᱯᱩᱱ)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G2 - Math 3: Currency & Market
    await _insertOrUpdateLesson(db, {
      'id': 'g2_math_03',
      'grade': 'Grade 2',
      'subject': 'Mathematics',
      'topic': 'Currency & Money',
      'title_hi': 'मुद्रा एवं हाट बाजार',
      'title_sat': 'ᱯᱩᱭᱥᱟᱹ ᱟᱨ ᱦᱟᱴ ᱵᱟᱡᱟᱨ',
      'title_en': 'Currency & Village Haat Market',
      'objective_hi': '₹1, ₹2, ₹5, ₹10 के सिक्के और नोटों की पहचान एवं सरल खरीद-बिक्री।',
      'objective_sat': '᱑, ᱒, ᱕, ᱑᱐ ᱴᱟᱠᱟ ᱨᱮᱭᱟᱜ ᱯᱩᱭᱥᱟᱹ ᱟᱨ ᱱᱳᱴ ᱪᱤᱱᱦᱟᱹᱣ ᱟᱨ ᱠᱤᱨᱤᱧ-ᱟᱹᱠᱷᱨᱤᱧ᱾',
      'content_hi': '₹५ का सिक्का, ₹१० का नोट। हाट में २ रुपये की पेंसिल और ३ रुपये की रबर = ५ रुपये।',
      'content_sat': '᱕ ᱴᱟᱠᱟ ᱯᱩᱭᱥᱟᱹ, ᱑᱐ ᱴᱟᱠᱟ ᱱᱳᱴ᱾ ᱦᱟᱴ ᱨᱮ ᱒ ᱴᱟᱠᱟ ᱨᱮᱭᱟᱜ ᱯᱮᱱᱥᱤᱞ + ᱓ ᱴᱟᱠᱟ ᱨᱮᱭᱟᱜ ᱨᱟᱵᱟᱨ = ᱕ ᱴᱟᱠᱟ᱾',
      'activity_hi': 'कक्षा में हाट बाजार का अभिनय: कागज़ के नोटों से खरीदारी करना।',
      'activity_sat': 'ᱠᱞᱟᱥ ᱨᱮ ᱦᱟᱴ ᱵᱮᱱᱟᱣ ᱠᱟᱛᱮ ᱠᱟᱜᱚᱡᱽ ᱴᱟᱠᱟ ᱛᱮ ᱠᱤᱨᱤᱧ-ᱟᱹᱠᱷᱨᱤᱧ ᱮᱱᱮᱡ᱾',
      'assessment_hi': '५ रुपये का नोट दिखाकर उसका मूल्य पूछना।',
      'assessment_sat': '᱕ ᱴᱟᱠᱟ ᱱᱳᱴ ᱩᱫᱩᱜ ᱠᱟᱛᱮ ᱚᱱᱟ ᱨᱮᱭᱟᱜ ᱫᱟᱢ ᱠᱩᱞᱤ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G2 - Language 1: Picture Storytelling
    await _insertOrUpdateLesson(db, {
      'id': 'g2_lang_01',
      'grade': 'Grade 2',
      'subject': 'Language',
      'topic': 'Picture Storytelling',
      'title_hi': 'चित्र पठन एवं कहानी कथन',
      'title_sat': 'ᱪᱤᱛᱟᱹᱨ ᱯᱟᱲᱦᱟᱣ ᱟᱨ ᱠᱟᱹᱦᱱᱤ',
      'title_en': 'Picture Storytelling & Oral Expression',
      'objective_hi': 'चित्रों के क्रम को देखकर कहानी समझना और अपने शब्दों में व्यक्त करना।',
      'objective_sat': 'ᱪᱤᱛᱟᱹᱨ ᱛᱷᱟᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱠᱟᱹᱦᱱᱤ ᱵᱩᱡᱷᱟᱹᱣ ᱟᱨ ᱟᱯᱱᱟᱨ ᱟᱲᱟᱝ ᱛᱮ ᱞᱟᱹᱭ᱾',
      'content_hi': 'चालाक लोमड़ी और खट्टे अंगूर की सचित्र कहानी। प्यासे कौवे की कंकड़ डालने वाली कहानी।',
      'content_sat': 'ᱪᱟᱞᱟᱠ ᱛᱩᱭᱩ ᱟᱨ ᱠᱷᱟᱴᱟ ᱟᱝᱜᱩᱨ ᱨᱮᱭᱟᱜ ᱠᱟᱹᱦᱱᱤ᱾ ᱫᱟᱜ ᱛᱮᱛᱟᱝ ᱠᱟᱣᱟ ᱨᱮᱭᱟᱜ ᱠᱟᱹᱦᱱᱤ᱾',
      'activity_hi': '४ चित्रों को सही क्रम में लगाकर कहानी सुनाना।',
      'activity_sat': '᱔ ᱜᱚᱴᱟᱝ ᱪᱤᱛᱟᱹᱨ ᱞᱟᱦᱟ-ᱛᱟᱭᱚᱢ ᱥᱟᱡᱟᱣ ᱠᱟᱛᱮ ᱠᱟᱹᱦᱱᱤ ᱞᱟᱹᱭ᱾',
      'assessment_hi': 'चित्र देखकर बताना कि कौवे ने घड़े में पानी ऊपर कैसे लाया?',
      'assessment_sat': 'ᱪᱤᱛᱟᱹᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱞᱟᱹᱭ ᱢᱮ ᱠᱟᱣᱟ ᱪᱮᱫ ᱞᱮᱠᱟᱛᱮ ᱫᱟᱜ ᱪᱮᱛᱟᱱ ᱮ ᱨᱟᱠᱟᱵ ᱠᱮᱫᱟ?',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G2 - Language 2: Action Verbs
    await _insertOrUpdateLesson(db, {
      'id': 'g2_lang_02',
      'grade': 'Grade 2',
      'subject': 'Language',
      'topic': 'Action Verbs',
      'title_hi': 'कक्षा निर्देश एवं क्रिया शब्द',
      'title_sat': 'ᱠᱟᱹᱢᱤ ᱟᱹᱲᱟᱹ ᱟᱨ ᱱᱤᱨᱫᱮᱥ',
      'title_en': 'Action Verbs & Daily Instructions',
      'objective_hi': 'पढ़ना, लिखना, दौड़ना, गाना जैसे क्रिया शब्दों को समझना और वाक्य में प्रयोग करना।',
      'objective_sat': 'ᱯᱟᱲᱦᱟᱣ, ᱚᱞ, ᱫᱟᱹᱲ, ᱥᱮᱨᱮᱧ ᱮᱢᱟᱱ ᱠᱟᱹᱢᱤ ᱟᱹᱲᱟᱹ ᱵᱩᱡᱷᱟᱹᱣ ᱟᱨ ᱨᱚᱲ᱾',
      'content_hi': 'पढ़ो (ᱯᱟᱲᱦᱟᱣ ᱢᱮ - Parhao me), लिखो (ᱚᱞ ᱢᱮ - Ol me), बैठो (ᱫᱩᱲᱩᱵ ᱢᱮ - Durup me), गाओ (ᱥᱮᱨᱮᱧ ᱢᱮ - Serenj me)।',
      'content_sat': 'ᱯᱟᱲᱦᱟᱣ ᱢᱮ (Padho), ᱚᱞ ᱢᱮ (Likho), ᱫᱩᱲᱩᱵ ᱢᱮ (Baitho), ᱛᱤᱸᱜᱩᱱ ᱢᱮ (Khade ho jao)᱾',
      'activity_hi': 'शिक्षक मातृभाषा में निर्देश देंगे और बच्चे क्रिया का अभिनय करेंगे।',
      'activity_sat': 'ᱢᱟᱪᱮᱛ ᱦᱩᱠᱩᱢ ᱮᱢᱟᱭ ᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ ᱚᱱᱟ ᱠᱟᱹᱢᱤ ᱠᱟᱛᱮ ᱠᱚ ᱩᱫᱩᱜᱟ᱾',
      'assessment_hi': '"किताब पढ़ो" कहने पर सही क्रिया करके दिखाना।',
      'assessment_sat': '"ᱯᱩᱛᱷᱤ ᱯᱟᱲᱦᱟᱣ ᱢᱮ" ᱢᱮᱱ ᱞᱮᱠᱷᱟᱱ ᱚᱱᱟ ᱠᱟᱹᱢᱤ ᱩᱫᱩᱜ ᱢᱮ᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G2 - EVS 1: Animals & Birds
    await _insertOrUpdateLesson(db, {
      'id': 'g2_evs_01',
      'grade': 'Grade 2',
      'subject': 'Environmental',
      'topic': 'Animals & Birds',
      'title_hi': 'हमारे पालतू और जंगली पशु',
      'title_sat': 'ᱟᱥᱩᱞ ᱟᱨ ᱵᱤᱨ ᱡᱤᱭᱟᱹᱞᱤ',
      'title_en': 'Domestic & Wild Animals Around Us',
      'objective_hi': 'पालतू पशु (गाय, बकरी) और जंगली जानवरों (बाघ, हाथी) में अंतर समझना।',
      'objective_sat': 'ᱚᱲᱟᱜ ᱨᱤᱱ ᱟᱥᱩᱞ (ᱜᱟᱹᱭ, ᱢᱮᱨᱚᱢ) ᱟᱨ ᱵᱤᱨ ᱨᱤᱱ (ᱛᱟᱹᱨᱩᱵ, ᱦᱟᱹᱛᱤ) ᱡᱤᱭᱟᱹᱞᱤ ᱵᱷᱮᱜᱟᱨ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      'content_hi': 'गाय दूध देती है (ᱜᱟᱹᱭ - Gai), बकरी (ᱢᱮᱨᱚᱢ - Merom), बाघ जंगल में रहता है (ᱛᱟᱹᱨᱩᱵ - Tarub), हाथी (ᱦᱟᱹᱛᱤ - Hati)।',
      'content_sat': 'ᱜᱟᱹᱭ (Cow), ᱢᱮᱨᱚᱢ (Goat), ᱥᱮᱛᱟ (Dog), ᱛᱟᱹᱨᱩᱵ (Tiger), ᱦᱟᱹᱛᱤ (Elephant), ᱪᱮᱬᱮ (Bird)᱾',
      'activity_hi': 'जानवरों की आवाज़ों की नकल करना और नाम पहचानना।',
      'activity_sat': 'ᱡᱤᱭᱟᱹᱞᱤ ᱠᱚᱣᱟᱜ ᱨᱟᱜ ᱨᱚᱲ ᱠᱟᱛᱮ ᱧᱩᱛᱩᱢ ᱪᱤᱱᱦᱟᱹᱣ ᱮᱱᱮᱡ᱾',
      'assessment_hi': 'पूछना: जंगल का राजा कौन है? (बाघ / ᱛᱟᱹᱨᱩᱵ)।',
      'assessment_sat': 'ᱵᱤᱨ ᱨᱤᱱᱤᱡ ᱨᱟᱡᱟ ᱫᱚ ᱚᱠᱚᱭ ᱠᱟᱱᱟᱭ? (ᱛᱟᱹᱨᱩᱵ / बाघ)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G2 - EVS 2: Community Helpers
    await _insertOrUpdateLesson(db, {
      'id': 'g2_evs_02',
      'grade': 'Grade 2',
      'subject': 'Environmental',
      'topic': 'Community Helpers',
      'title_hi': 'हमारे मददगार (गाँव के कारीगर)',
      'title_sat': 'ᱟᱵᱚ ᱨᱤᱱ ᱜᱚᱲᱚᱭᱤᱡ ᱦᱚᱲ',
      'title_en': 'Community Helpers in Village',
      'objective_hi': 'किसान, कुम्हार, लोहार और शिक्षक के योगदान को समझना और सम्मान देना।',
      'objective_sat': 'ᱪᱟᱥᱤ (ᱠᱤᱥᱟᱱ), ᱠᱩᱢᱦᱟᱹᱨ, ᱠᱟᱢᱟᱨ ᱟᱨ ᱢᱟᱪᱮᱛ ᱠᱚᱣᱟᱜ ᱠᱟᱹᱢᱤ ᱟᱨ ᱢᱟᱹᱱ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      'content_hi': 'किसान अन्न उगाता है (ᱪᱟᱥᱤ - Chasi), कुम्हार घड़ा बनाता है (ᱠᱩᱢᱦᱟᱹᱨ - Kumhar), शिक्षक पढ़ाते हैं (ᱢᱟᱪᱮᱛ - Machet)।',
      'content_sat': 'ᱪᱟᱥᱤ (Farmer), ᱠᱩᱢᱦᱟᱹᱨ (Potter), ᱢᱟᱪᱮᱛ (Teacher), ᱨᱟᱱ ᱮᱢᱚᱜᱤᱡ/ᱰᱟᱠᱛᱚᱨ (Doctor)᱾',
      'activity_hi': 'मिट्टी से छोटा दीया या खिलौना बनाने का अनुभव।',
      'activity_sat': 'ᱦᱟᱥᱟ ᱛᱮ ᱠᱟᱹᱴᱤᱡ ᱵᱟᱹᱛᱤ ᱥᱮ ᱠᱷᱮᱞᱚᱱᱰ ᱵᱮᱱᱟᱣ ᱠᱟᱹᱢᱤ᱾',
      'assessment_hi': 'अन्न कौन उगाता है? (किसान / ᱪᱟᱥᱤ)।',
      'assessment_sat': 'ᱫᱟᱠᱟ-ᱪᱟᱣᱞᱮ ᱚᱠᱚᱭ ᱮ ᱪᱟᱥ-ᱟ? (ᱪᱟᱥᱤ / किसान)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // ==========================================
    // GRADE 3 LESSONS
    // ==========================================

    // G3 - Math 1: Multiplication through Repeated Addition
    await _insertOrUpdateLesson(db, {
      'id': 'g3_math_01',
      'grade': 'Grade 3',
      'subject': 'Mathematics',
      'topic': 'Multiplication',
      'title_hi': 'बार-बार जोड़ से गुणा',
      'title_sat': 'ᱜᱩᱬᱟᱹᱣ ᱟᱨ ᱫᱚᱦᱲᱟ ᱡᱚᱲᱟᱣ',
      'title_en': 'Multiplication through Repeated Addition',
      'objective_hi': 'समान समूहों को बार-बार जोड़कर गुणा की अवधारणा समझना (२, ३, ५ के पहाड़े)।',
      'objective_sat': 'ᱢᱤᱫ ᱞᱮᱠᱟᱱ ᱜᱩᱴ ᱫᱚᱦᱲᱟ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱜᱩᱬᱟᱹᱣ ᱵᱩᱡᱷᱟᱹᱣ᱾',
      'content_hi': '२ + २ + २ = ६, यानी ३ बार २ = ६ (३ × २ = ६ / ᱯᱮ ᱫᱷᱟᱣ ᱵᱟᱨ = ᱛᱩᱨᱩᱭ)।',
      'content_sat': '᱒ + ᱒ + ᱒ = ᱖, ᱢᱮᱱᱫᱚ ᱓ ᱫᱷᱟᱣ ᱒ = ᱖ (᱓ × ᱒ = ᱖)᱾',
      'activity_hi': 'बीजों को ३-३ के ४ समूहों में रखकर कुल बीज गिनना (४ × ३ = १२)।',
      'activity_sat': 'ᱡᱟᱝ ᱠᱚ ᱓-᱓ ᱠᱟᱛᱮ ᱔ ᱜᱩᱴ ᱨᱮ ᱫᱚᱦᱚ ᱠᱟᱛᱮ ᱞᱮᱠᱷᱟᱭ (᱔ × ᱓ = ᱑᱒)᱾',
      'assessment_hi': '५ के ३ समूहों में कुल कितने होंगे? (१५ / ᱜᱮᱞ ᱢᱚᱬᱮ)।',
      'assessment_sat': '᱕ ᱨᱮᱭᱟᱜ ᱓ ᱜᱩᱴ ᱨᱮ ᱡᱚᱛᱚᱛᱮ ᱛᱤᱱᱟᱹᱜ? (᱑᱕ / ᱜᱮᱞ ᱢᱚᱬᱮ)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G3 - Math 2: Time & Calendar
    await _insertOrUpdateLesson(db, {
      'id': 'g3_math_02',
      'grade': 'Grade 3',
      'subject': 'Mathematics',
      'topic': 'Time & Calendar',
      'title_hi': 'समय और घड़ी देखना',
      'title_sat': 'ᱜᱷᱩᱲᱤ ᱟᱨ ᱚᱠᱛᱚ ᱧᱮᱞ',
      'title_en': 'Time, Clocks & Days of Week',
      'objective_hi': 'घड़ी में पूरे घंटे पहचानना तथा सप्ताह के दिनों के नाम जानना।',
      'objective_sat': 'ᱜᱷᱩᱲᱤ ᱨᱮ ᱴᱟᱲᱟᱝ ᱧᱮᱞ ᱟᱨ ᱦᱟᱯᱛᱟ ᱨᱮᱭᱟᱜ ᱢᱟᱦᱟᱸ ᱠᱚ ᱵᱟᱰᱟᱭ᱾',
      'content_hi': 'सुबह ९ बजे स्कूल (ᱥᱮᱛᱟᱜ ᱙ ᱴᱟᱲᱟᱝ), शाम को खेल (ᱟᱹᱭᱩᱵ)। सप्ताह के ७ दिन (ᱮᱭᱟᱭ ᱢᱟᱦᱟᱸ)।',
      'content_sat': 'ᱥᱮᱛᱟᱜ (Morning), ᱛᱤᱠᱤᱱ (Noon), ᱟᱹᱭᱩᱵ (Evening), ᱧᱤᱫᱟᱹ (Night)᱾ ᱦᱟᱯᱛᱟ ᱨᱮ ᱮᱭᱟᱭ ᱢᱟᱦᱟᱸ᱾',
      'activity_hi': 'कागज़ की घड़ी बनाकर सुइयों को अलग-अलग समय पर घुमाना।',
      'activity_sat': 'ᱠᱟᱜᱚᱡᱽ ᱜᱷᱩᱲᱤ ᱵᱮᱱᱟᱣ ᱠᱟᱛᱮ ᱥᱩᱭ ᱟᱹᱪᱩᱨ ᱮᱱᱮᱡ᱾',
      'assessment_hi': 'छोटी सुई ३ पर और बड़ी १२ पर हो तो कितने बजे हैं? (३ बजे / ᱯᱮ ᱴᱟᱲᱟᱝ)।',
      'assessment_sat': 'ᱠᱟᱹᱴᱤᱡ ᱥᱩᱭ ᱓ ᱨᱮ ᱟᱨ ᱢᱟᱨᱟᱝ ᱑᱒ ᱨᱮ ᱛᱟᱦᱮᱸᱱ ᱠᱷᱟᱱ ᱛᱤᱱᱟᱹᱜ ᱴᱟᱲᱟᱝ? (᱓ ᱴᱟᱲᱟᱝ)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G3 - Language 1: Reading Comprehension
    await _insertOrUpdateLesson(db, {
      'id': 'g3_lang_01',
      'grade': 'Grade 3',
      'subject': 'Language',
      'topic': 'Reading Comprehension',
      'title_hi': 'पाठ पठन एवं समझ',
      'title_sat': 'ᱯᱟᱲᱦᱟᱣ ᱟᱨ ᱵᱩᱡᱷᱟᱹᱣ',
      'title_en': 'Reading Comprehension & Folktales',
      'objective_hi': 'सरल संथाली/हिंदी अनुच्छेदों को समझकर प्रश्नों के उत्तर देना।',
      'objective_sat': 'ᱟᱞᱜᱟ ᱚᱞ ᱯᱟᱲᱦᱟᱣ ᱠᱟᱛᱮ ᱠᱩᱠᱞᱤ ᱨᱮᱭᱟᱜ ᱛᱮᱞᱟ ᱮᱢ᱾',
      'content_hi': '"एक जंगल में हाथी और गौरैया रहते थे। दोनों में पक्की मित्रता थी।"',
      'content_sat': 'ᱢᱤᱫᱴᱟᱝ ᱵᱤᱨ ᱨᱮ ᱦᱟᱹᱛᱤ ᱟᱨ ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ ᱠᱤᱱ ᱛᱟᱦᱮᱸ ᱠᱟᱱᱟ᱾ ᱵᱟᱱᱟᱨ ᱦᱚᱲ ᱟᱹᱰᱤ ᱜᱟᱹᱦᱤᱨ ᱜᱟᱛᱮ ᱠᱤᱱ ᱛᱟᱦᱮᱸ ᱠᱟᱱᱟ᱾',
      'activity_hi': 'कहानी को बारी-बारी से कक्षा में ज़ोर से पढ़ना।',
      'activity_sat': 'ᱠᱟᱹᱦᱱᱤ ᱢᱤᱫ-ᱢᱤᱫ ᱛᱮ ᱠᱞᱟᱥ ᱨᱮ ᱨᱟᱣᱟᱞ ᱛᱮ ᱯᱟᱲᱦᱟᱣ᱾',
      'assessment_hi': 'कहानी में हाथी का पक्का मित्र कौन था? (गौरैया / ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ)।',
      'assessment_sat': 'ᱠᱟᱹᱦᱱᱤ ᱨᱮ ᱦᱟᱹᱛᱤ ᱨᱤᱱᱤᱡ ᱜᱟᱛᱮ ᱫᱚ ᱚᱠᱚᱭ ᱛᱟᱦᱮᱸ ᱠᱟᱱᱟ? (ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ / गौरैया)᱾',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // G3 - EVS 1: Water Conservation
    await _insertOrUpdateLesson(db, {
      'id': 'g3_evs_01',
      'grade': 'Grade 3',
      'subject': 'Environmental',
      'topic': 'Water Conservation',
      'title_hi': 'जल स्रोत और संरक्षण',
      'title_sat': 'ᱫᱟᱜ ᱨᱮᱭᱟᱜ ᱯᱷᱮᱰᱟᱛ ᱟᱨ ᱡᱚᱜᱟᱣ',
      'title_en': 'Water Sources & Conservation',
      'objective_hi': 'नदी, तालाब, कुआँ, वर्षा जल संचयन और पानी बचाने के उपाय जानना।',
      'objective_sat': 'ᱜᱟᱰᱟ, ᱯᱩᱠᱷᱨᱤ, ᱠᱩᱧ ᱟᱨ ᱫᱟᱜ ᱡᱚᱜᱟᱣ ᱨᱮᱭᱟᱜ ᱦᱚᱨᱟ ᱵᱟᱰᱟᱭ᱾',
      'content_hi': 'नदी (ᱱᱟᱹᱭ - Nai), तालाब (ᱯᱩᱠᱷᱨᱤ - Pukhur), कुआँ (ᱠᱩᱧ - Kunj), बारिश का पानी बचाना (ᱫᱟᱜ ᱡᱚᱜᱟᱣ)।',
      'content_sat': 'ᱜᱟᱰᱟ/ᱱᱟᱹᱭ (River), ᱯᱩᱠᱷᱨᱤ (Pond), ᱠᱩᱧ (Well), ᱡᱟᱹᱯᱩᱫ ᱫᱟᱜ ᱡᱚᱜᱟᱣ (Rainwater harvesting)᱾',
      'activity_hi': 'पानी बचाने के लिए कक्षा में पोस्टर बनाना: "जल ही जीवन है / ᱫᱟᱜ ᱜᱮ ᱡᱤᱣᱤ"।',
      'activity_sat': 'ᱫᱟᱜ ᱵᱟᱧᱪᱟᱣ ᱞᱟᱹᱜᱤᱫ ᱯᱳᱥᱴᱚᱨ ᱵᱮᱱᱟᱣ: "ᱫᱟᱜ ᱜᱮ ᱡᱤᱣᱤ"᱾',
      'assessment_hi': 'पीने का पानी कहाँ से मिलता है और उसे साफ़ कैसे रखते हैं?',
      'assessment_sat': 'ᱧᱩ ᱫᱟᱜ ᱠᱷᱚᱱ ᱧᱟᱢᱚᱜᱼᱟ ᱟᱨ ᱪᱮᱫ ᱞᱮᱠᱟᱛᱮ ᱥᱟᱯᱷᱟ ᱫᱚᱦᱚᱭᱟ?',
      'verification_status': verificationNotice,
      'is_completed': 0,
      'created_at': nowIso,
    });

    // ==========================================
    // LEARNING OUTCOMES SEEDING
    // ==========================================
    final outcomes = [
      // Grade 1 Math 1
      {'id': 'lo_g1_math_01_1', 'lesson_id': 'g1_math_01', 'code': 'LO-M1.1', 'hi': '१ से १० तक संख्याओं की पहचान और मौखिक उच्चारण।', 'sat': '᱑ ᱠᱷᱚᱱ ᱑᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱮᱞ ᱪᱤᱱᱦᱟᱹᱣ ᱟᱨ ᱢᱚᱪᱟ ᱛᱮ ᱨᱚᱲ᱾', 'en': 'Number recognition and verbal pronunciation from 1 to 10.'},
      {'id': 'lo_g1_math_01_2', 'lesson_id': 'g1_math_01', 'code': 'LO-M1.2', 'hi': 'मूर्त वस्तुओं (कंकड़, बीज) को गिनकर संख्या बताना।', 'sat': 'ᱫᱷᱤᱨᱤ, ᱡᱟᱝ ᱮᱢᱟᱱ ᱡᱤᱱᱤᱥ ᱞᱮᱠᱷᱟ ᱠᱟᱛᱮ ᱮᱞ ᱞᱟᱹᱭ᱾', 'en': 'One-to-one correspondence counting of concrete physical objects.'},
      // Grade 1 Math 2
      {'id': 'lo_g1_math_02_1', 'lesson_id': 'g1_math_02', 'code': 'LO-M1.3', 'hi': 'दैनिक जीवन की 2D आकृतियों (गोल, चौकोर) की पहचान।', 'sat': 'ᱫᱤᱱᱟᱹᱢ ᱡᱤᱭᱚᱱ ᱨᱮᱭᱟᱜ ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱯᱩᱱ ᱠᱳᱬ ᱨᱩᱯ ᱪᱤᱱᱦᱟᱹᱣ᱾', 'en': 'Identify basic 2D shapes (circle, square, triangle) in daily environment.'},
      // Grade 1 Math 3
      {'id': 'lo_g1_math_03_1', 'lesson_id': 'g1_math_03', 'code': 'LO-M1.4', 'hi': 'वस्तुओं के आकार (बड़ा/छोटा) एवं भार (भारी/हल्का) की तुलना करना।', 'sat': 'ᱡᱤᱱᱤᱥ ᱨᱮᱭᱟᱜ ᱢᱟᱨᱟᱝ/ᱦᱩᱰᱤᱧ ᱟᱨ ᱦᱟᱢᱟᱞ/ᱨᱟᱣᱟᱞ ᱨᱮᱭᱟᱜ ᱛᱩᱞᱟᱹᱡᱚᱠᱷᱟ᱾', 'en': 'Qualitative comparison of physical attributes like size and weight.'},
      // Grade 1 Math 4
      {'id': 'lo_g1_math_04_1', 'lesson_id': 'g1_math_04', 'code': 'LO-M1.5', 'hi': '१० के बंडल और इकाई की सहायता से ११ से २० तक की संख्याओं का बोध।', 'sat': '᱑᱐ ᱨᱮᱭᱟᱜ ᱵᱤᱸᱰᱟᱹ ᱛᱮ ᱑᱑ ᱠᱷᱚᱱ ᱒᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱮᱞ ᱵᱩᱡᱷᱟᱹᱣ᱾', 'en': 'Understand numbers 11 to 20 using bundles of tens and loose units.'},
      // Grade 1 Lang 1
      {'id': 'lo_g1_lang_01_1', 'lesson_id': 'g1_lang_01', 'code': 'LO-L1.1', 'hi': 'मातृभाषा एवं हिंदी वर्णों की ध्वनि पहचान।', 'sat': 'ᱟᱭᱳ ᱟᱲᱟᱝ ᱟᱨ ᱦᱤᱱᱫᱤ ᱟᱠᱷᱚᱨ ᱨᱮᱭᱟᱜ ᱥᱟᱰᱮ ᱪᱤᱱᱦᱟᱹᱣ᱾', 'en': 'Phonological awareness and letter-sound association in mother tongue and Hindi.'},
      // Grade 1 Lang 2
      {'id': 'lo_g1_lang_02_1', 'lesson_id': 'g1_lang_02', 'code': 'LO-L1.2', 'hi': 'दो अक्षरों के सरल अमात्रिक शब्दों को पढ़ना और बोलना।', 'sat': 'ᱵᱟᱨ ᱟᱠᱷᱚᱨ ᱨᱮᱭᱟᱜ ᱟᱹᱲᱟᱹ ᱯᱟᱲᱦᱟᱣ ᱟᱨ ᱨᱚᱲ᱾', 'en': 'Decode and blend simple two-letter words.'},
      // Grade 1 Lang 3
      {'id': 'lo_g1_lang_03_1', 'lesson_id': 'g1_lang_03', 'code': 'LO-L1.3', 'hi': 'हाव-भाव और लय के साथ सामूहिक बालगीत गाना।', 'sat': 'ᱛᱟᱲ ᱟᱨ ᱦᱤᱞᱟᱹᱣ ᱥᱟᱶ ᱜᱤᱫᱽᱨᱟᱹ ᱥᱮᱨᱮᱧ ᱨᱚᱲ᱾', 'en': 'Choral recitation of rhythmic rhymes with bodily gestures.'},
      // Grade 1 EVS 1
      {'id': 'lo_g1_evs_01_1', 'lesson_id': 'g1_evs_01', 'code': 'LO-E1.1', 'hi': 'परिवार के सदस्यों और पारिवारिक रिश्तों की मातृभाषा में पहचान।', 'sat': 'ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱤᱱ ᱦᱚᱲ ᱟᱨ ᱥᱟᱹᱜᱟᱹᱭ ᱪᱤᱱᱦᱟᱹᱣ᱾', 'en': 'Identify family members and relationships in mother tongue.'},
      // Grade 1 EVS 2
      {'id': 'lo_g1_evs_02_1', 'lesson_id': 'g1_evs_02', 'code': 'LO-E1.2', 'hi': 'आसपास के स्थानीय पेड़-पौधों और उनके भागों की पहचान।', 'sat': 'ᱟᱥᱯᱟᱥ ᱨᱮᱭᱟᱜ ᱫᱟᱨᱮ-ᱱᱟᱹᱲᱤ ᱪᱤᱱᱦᱟᱹᱣ᱾', 'en': 'Recognize local trees, leaves, and botanical surroundings.'},
      // Grade 1 EVS 3
      {'id': 'lo_g1_evs_03_1', 'lesson_id': 'g1_evs_03', 'code': 'LO-E1.3', 'hi': 'भोजन से पूर्व हाथ धोने और व्यक्तिगत स्वच्छता का नियमित पालन।', 'sat': 'ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱛᱤ ᱟᱹᱨᱩᱵ ᱟᱨ ᱥᱟᱯᱷᱟ ᱫᱚᱦᱚ᱾', 'en': 'Demonstrate hand hygiene and cleanliness routines before meals.'},
      // Grade 2 Math 1
      {'id': 'lo_g2_math_01_1', 'lesson_id': 'g2_math_01', 'code': 'LO-M2.1', 'hi': 'वस्तुओं को मिलाकर २० तक संख्याओं का जोड़।', 'sat': 'ᱡᱤᱱᱤᱥ ᱠᱚ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱒᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱮᱞ ᱡᱚᱲᱟᱣ᱾', 'en': 'Perform concrete addition up to 20 using contextual objects.'},
      // Grade 2 Math 2
      {'id': 'lo_g2_math_02_1', 'lesson_id': 'g2_math_02', 'code': 'LO-M2.2', 'hi': 'वस्तुओं को हटाकर शेष ज्ञात करना (२० तक घटाव)।', 'sat': 'ᱡᱤᱱᱤᱥ ᱚᱪᱚᱜ ᱠᱟᱛᱮ ᱥᱟᱨᱮᱡ ᱮᱞ ᱞᱮᱠᱷᱟ᱾', 'en': 'Understand concrete subtraction as taking away up to 20.'},
      // Grade 2 Math 3
      {'id': 'lo_g2_math_03_1', 'lesson_id': 'g2_math_03', 'code': 'LO-M2.3', 'hi': 'सिक्कों और नोटों की पहचान तथा हाट-बाज़ार की सरल गणना।', 'sat': 'ᱯᱩᱭᱥᱟᱹ ᱟᱨ ᱱᱳᱴ ᱪᱤᱱᱦᱟᱹᱣ ᱥᱟᱶ ᱦᱟᱴ ᱨᱮᱭᱟᱜ ᱞᱮᱠᱷᱟ᱾', 'en': 'Recognize Indian currency denominations and basic transactions.'},
      // Grade 2 Lang 1
      {'id': 'lo_g2_lang_01_1', 'lesson_id': 'g2_lang_01', 'code': 'LO-L2.1', 'hi': 'चित्रों के क्रम को समझकर अपनी भाषा में कहानी सुनाना।', 'sat': 'ᱪᱤᱛᱟᱹᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱟᱯᱱᱟᱨ ᱯᱟᱹᱨᱥᱤ ᱛᱮ ᱠᱟᱹᱦᱱᱤ ᱞᱟᱹᱭ᱾', 'en': 'Narrate short stories by interpreting sequenced pictures.'},
      // Grade 2 Lang 2
      {'id': 'lo_g2_lang_02_1', 'lesson_id': 'g2_lang_02', 'code': 'LO-L2.2', 'hi': 'कक्षा के क्रिया शब्दों (पढ़ो, लिखो, बैठो) का सही प्रयोग।', 'sat': 'ᱠᱟᱹᱢᱤ ᱟᱹᱲᱟᱹ ᱨᱮᱭᱟᱜ ᱴᱷᱤᱠ ᱵᱮᱵᱷᱟᱨ᱾', 'en': 'Comprehend and execute action verbs and instructional commands.'},
      // Grade 2 EVS 1
      {'id': 'lo_g2_evs_01_1', 'lesson_id': 'g2_evs_01', 'code': 'LO-E2.1', 'hi': 'पालतू पशु और जंगली जानवरों के स्वभाव और आवास की पहचान।', 'sat': 'ᱟᱥᱩᱞ ᱟᱨ ᱵᱤᱨ ᱡᱤᱭᱟᱹᱞᱤ ᱠᱚᱣᱟᱜ ᱵᱷᱮᱜᱟᱨ ᱵᱩᱡᱷᱟᱹᱣ᱾', 'en': 'Differentiate between domestic and wild animals and their shelters.'},
      // Grade 2 EVS 2
      {'id': 'lo_g2_evs_02_1', 'lesson_id': 'g2_evs_02', 'code': 'LO-E2.2', 'hi': 'गाँव के मददगारों (किसान, कुम्हार, लोहार) के कार्य और सम्मान।', 'sat': 'ᱪᱟᱥᱤ, ᱠᱩᱢᱦᱟᱹᱨ ᱮᱢᱟᱱ ᱜᱚᱲᱚᱭᱤᱡ ᱠᱚᱣᱟᱜ ᱠᱟᱹᱢᱤ ᱵᱩᱡᱷᱟᱹᱣ᱾', 'en': 'Appreciate community helpers and their contributions in village life.'},
      // Grade 3 Math 1
      {'id': 'lo_g3_math_01_1', 'lesson_id': 'g3_math_01', 'code': 'LO-M3.1', 'hi': 'समान समूहों को बार-बार जोड़कर गुणा की अवधारणा समझना।', 'sat': 'ᱫᱚᱦᱲᱟ ᱡᱚᱲᱟᱣ ᱛᱮ ᱜᱩᱬᱟᱹᱣ ᱵᱩᱡᱷᱟᱹᱣ᱾', 'en': 'Understand multiplication as repeated addition of equal groups.'},
      // Grade 3 Math 2
      {'id': 'lo_g3_math_02_1', 'lesson_id': 'g3_math_02', 'code': 'LO-M3.2', 'hi': 'घड़ी में पूरे घंटे देखना और दिनचर्या के समय की समझ।', 'sat': 'ᱜᱷᱩᱲᱤ ᱨᱮ ᱴᱟᱲᱟᱝ ᱧᱮᱞ ᱟᱨ ᱚᱠᱛᱚ ᱵᱟᱰᱟᱭ᱾', 'en': 'Read hours on analog clocks and relate time to daily routines.'},
      // Grade 3 Lang 1
      {'id': 'lo_g3_lang_01_1', 'lesson_id': 'g3_lang_01', 'code': 'LO-L3.1', 'hi': 'सरल गद्यांश पढ़कर मुख्य पात्र और घटना की समझ।', 'sat': 'ᱚᱞ ᱯᱟᱲᱦᱟᱣ ᱠᱟᱛᱮ ᱠᱟᱛᱷᱟ ᱵᱩᱡᱷᱟᱹᱣ᱾', 'en': 'Read vernacular passages with fluency and answering questions.'},
      // Grade 3 EVS 1
      {'id': 'lo_g3_evs_01_1', 'lesson_id': 'g3_evs_01', 'code': 'LO-E3.1', 'hi': 'स्थानीय जल स्रोतों की पहचान और जल संरक्षण के उपाय।', 'sat': 'ᱫᱟᱜ ᱨᱮᱭᱟᱜ ᱯᱷᱮᱰᱟᱛ ᱟᱨ ᱡᱚᱜᱟᱣ ᱦᱚᱨᱟ ᱵᱟᱰᱟᱭ᱾', 'en': 'Identify local water sources and understand water conservation methods.'},
    ];

    for (final outcome in outcomes) {
      await _insertOrUpdateOutcome(db, {
        'id': outcome['id']!,
        'lesson_id': outcome['lesson_id']!,
        'code': outcome['code']!,
        'description_hi': outcome['hi']!,
        'description_sat': outcome['sat']!,
        'description_en': outcome['en']!,
        'verification_status': verificationNotice,
      });
    }

    // Seed Classroom Phrases
    final phrases = [
      {
        'id': 'cp_01',
        'intent': 'GREETING',
        'hindi': 'नमस्ते बच्चों',
        'santhali': 'ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ',
        'ol_chiki': 'ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ',
        'latin': 'Johar gidra',
        'audio_path': 'assets/audio/phrases/greeting.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_02',
        'intent': 'OPEN_BOOK',
        'hindi': 'अपनी किताब खोलो',
        'santhali': 'ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ',
        'ol_chiki': 'ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ',
        'latin': 'Amag puthi khulae me',
        'audio_path': 'assets/audio/phrases/open_book.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_03',
        'intent': 'LOOK_HERE',
        'hindi': 'यहाँ देखो',
        'santhali': 'ᱱᱚᱸᱰᱮ ᱧᱮᱞ ᱢᱮ',
        'ol_chiki': 'ᱱᱚᱸᱰᱮ ᱧᱮᱞ ᱢᱮ',
        'latin': 'Nonde nel me',
        'audio_path': 'assets/audio/phrases/look_here.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_04',
        'intent': 'LISTEN',
        'hindi': 'ध्यान से सुनो',
        'santhali': 'ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ',
        'ol_chiki': 'ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ',
        'latin': 'Dheyan te anjom me',
        'audio_path': 'assets/audio/phrases/listen.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_05',
        'intent': 'REPEAT',
        'hindi': 'मेरे बाद दोहराओ',
        'santhali': 'ᱤᱧ ᱛᱟᱭᱚᱢ ᱨᱚᱲ ᱢᱮ',
        'ol_chiki': 'ᱤᱧ ᱛᱟᱭᱚᱢ ᱨᱚᱲ ᱢᱮ',
        'latin': 'Iny tayom rod me',
        'audio_path': 'assets/audio/phrases/repeat.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_06',
        'intent': 'COUNT',
        'hindi': 'एक साथ गिनो',
        'santhali': 'ᱢᱤᱫ ᱥᱟᱶᱛᱮ ᱞᱮᱠᱷᱟᱭ ᱯᱮ',
        'ol_chiki': 'ᱢᱤᱫ ᱥᱟᱶᱛᱮ ᱞᱮᱠᱷᱟᱭ ᱯᱮ',
        'latin': 'Mid sawte lekhay pe',
        'audio_path': 'assets/audio/phrases/count.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_07',
        'intent': 'STAND_UP',
        'hindi': 'खड़े हो जाओ',
        'santhali': 'ᱛᱤᱸᱜᱩᱱ ᱢᱮ',
        'ol_chiki': 'ᱛᱤᱸᱜᱩᱱ ᱢᱮ',
        'latin': 'Tingun me',
        'audio_path': 'assets/audio/phrases/stand_up.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_08',
        'intent': 'SIT_DOWN',
        'hindi': 'बैठ जाओ',
        'santhali': 'ᱫᱩᱲᱩᱵ ᱢᱮ',
        'ol_chiki': 'ᱫᱩᱲᱩᱵ ᱢᱮ',
        'latin': 'Durup me',
        'audio_path': 'assets/audio/phrases/sit_down.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_09',
        'intent': 'GOOD',
        'hindi': 'बहुत अच्छा',
        'santhali': 'ᱟᱹᱰᱤ ᱱᱟᱯᱟᱭ',
        'ol_chiki': 'ᱟᱹᱰᱤ ᱱᱟᱯᱟᱭ',
        'latin': 'Adi napay',
        'audio_path': 'assets/audio/phrases/good.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'cp_10',
        'intent': 'TRY_AGAIN',
        'hindi': 'फिर से कोशिश करो',
        'santhali': 'ᱟᱨᱦᱚᱸ ᱠᱩᱨᱩᱢᱩᱴᱩᱭ ᱢᱮ',
        'ol_chiki': 'ᱟᱨᱦᱚᱸ ᱠᱩᱨᱩᱢᱩᱴᱩᱭ ᱢᱮ',
        'latin': 'Arho kurumutu me',
        'audio_path': 'assets/audio/phrases/try_again.mp3',
        'verification_status': verificationNotice,
      },
    ];

    for (final phrase in phrases) {
      await db.insert('classroom_phrases', phrase, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Vocabulary (Counting 1–10)
    final vocab = [
      {'num': '1', 'hi': 'एक', 'sat': 'ᱢᱤᱫ', 'latin': 'Mid'},
      {'num': '2', 'hi': 'दो', 'sat': 'ᱵᱟᱨ', 'latin': 'Bar'},
      {'num': '3', 'hi': 'तीन', 'sat': 'ᱯᱮ', 'latin': 'Pe'},
      {'num': '4', 'hi': 'चार', 'sat': 'ᱯᱩᱱ', 'latin': 'Pun'},
      {'num': '5', 'hi': 'पाँच', 'sat': 'ᱢᱚᱬᱮ', 'latin': 'Mone'},
      {'num': '6', 'hi': 'छह', 'sat': 'ᱛᱩᱨᱩᱭ', 'latin': 'Turuy'},
      {'num': '7', 'hi': 'सात', 'sat': 'ᱮᱭᱟᱭ', 'latin': 'Eyay'},
      {'num': '8', 'hi': 'आठ', 'sat': 'ᱤᱨᱟᱹᱞ', 'latin': 'Iral'},
      {'num': '9', 'hi': 'नौ', 'sat': 'ᱟᱨᱮ', 'latin': 'Are'},
      {'num': '10', 'hi': 'दस', 'sat': 'ᱜᱮᱞ', 'latin': 'Gel'},
    ];

    for (int i = 0; i < vocab.length; i++) {
      final v = vocab[i];
      await db.insert('vocabulary', {
        'id': 'vocab_num_${i + 1}',
        'lesson_id': 'g1_math_01',
        'word_hi': v['hi']!,
        'word_sat': v['sat']!,
        'ol_chiki': v['sat']!,
        'latin': v['latin']!,
        'meaning_en': 'Number ${v['num']}',
        'category': 'Numbers',
        'verification_status': verificationNotice,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Flashcards (1–5)
    final flashcards = [
      {
        'id': 'fc_01',
        'category': 'Numbers',
        'item_index': 1,
        'visual_symbol': '1️⃣',
        'word_hi': 'एक (1)',
        'word_sat': 'ᱢᱤᱫ (᱑)',
        'latin': 'Mid',
        'description': 'One • Cardinal Number 1',
        'audio_path': 'assets/audio/flashcards/num_1.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'fc_02',
        'category': 'Numbers',
        'item_index': 2,
        'visual_symbol': '2️⃣',
        'word_hi': 'दो (2)',
        'word_sat': 'ᱵᱟᱨ (᱒)',
        'latin': 'Bar',
        'description': 'Two • Cardinal Number 2',
        'audio_path': 'assets/audio/flashcards/num_2.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'fc_03',
        'category': 'Numbers',
        'item_index': 3,
        'visual_symbol': '3️⃣',
        'word_hi': 'तीन (3)',
        'word_sat': 'ᱯᱮ (᱓)',
        'latin': 'Pe',
        'description': 'Three • Cardinal Number 3',
        'audio_path': 'assets/audio/flashcards/num_3.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'fc_04',
        'category': 'Numbers',
        'item_index': 4,
        'visual_symbol': '4️⃣',
        'word_hi': 'चार (4)',
        'word_sat': 'ᱯᱩᱱ (᱔)',
        'latin': 'Pun',
        'description': 'Four • Cardinal Number 4',
        'audio_path': 'assets/audio/flashcards/num_4.mp3',
        'verification_status': verificationNotice,
      },
      {
        'id': 'fc_05',
        'category': 'Numbers',
        'item_index': 5,
        'visual_symbol': '5️⃣',
        'word_hi': 'पाँच (5)',
        'word_sat': 'ᱢᱚᱬᱮ (᱕)',
        'latin': 'Mone',
        'description': 'Five • Cardinal Number 5',
        'audio_path': 'assets/audio/flashcards/num_5.mp3',
        'verification_status': verificationNotice,
      },
    ];

    for (final fc in flashcards) {
      await db.insert('flashcards', fc, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Checks whether first-time user has completed onboarding walkthrough
  Future<bool> isOnboardingCompleted() async {
    try {
      final db = await database;
      await db.execute('CREATE TABLE IF NOT EXISTS app_preferences (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
      final res = await db.query(
        'app_preferences',
        where: 'key = ?',
        whereArgs: ['onboarding_completed'],
      );
      if (res.isEmpty) return false;
      return res.first['value'] == 'true';
    } catch (e) {
      debugPrint('Error reading onboarding status: $e');
      return false;
    }
  }

  /// Marks onboarding walkthrough as completed
  Future<void> setOnboardingCompleted({bool completed = true}) async {
    try {
      final db = await database;
      await db.execute('CREATE TABLE IF NOT EXISTS app_preferences (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
      await db.insert(
        'app_preferences',
        {'key': 'onboarding_completed', 'value': completed ? 'true' : 'false'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving onboarding status: $e');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
