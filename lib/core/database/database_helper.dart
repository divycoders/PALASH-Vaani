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
    if (_database != null) return _database!;
    _database = await _initDB('palash_curriculum.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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

    // Seed Prototype Dataset
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    const verificationNotice = 'Prototype / Pending Native Verification';

    // Seed Grade 1 Mathematics: Counting 1–10
    await db.insert('lessons', {
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
      'created_at': DateTime.now().toIso8601String(),
    });

    // Seed Learning Outcomes
    await db.insert('learning_outcomes', {
      'id': 'lo_g1_math_01_1',
      'lesson_id': 'g1_math_01',
      'code': 'LO-M1.1',
      'description_hi': '१ से १० तक संख्याओं की पहचान और मौखिक उच्चारण।',
      'description_sat': '᱑ ᱠᱷᱚᱱ ᱑᱐ ᱫᱷᱟᱹᱵᱤᱡ ᱮᱞ ᱪᱤᱱᱦᱟᱹᱣ ᱟᱨ ᱢᱚᱪᱟ ᱛᱮ ᱨᱚᱲ᱾',
      'description_en': 'Number recognition and verbal pronunciation from 1 to 10.',
      'verification_status': verificationNotice,
    });

    await db.insert('learning_outcomes', {
      'id': 'lo_g1_math_01_2',
      'lesson_id': 'g1_math_01',
      'code': 'LO-M1.2',
      'description_hi': 'मूर्त वस्तुओं (कंकड़, बीज) को गिनकर संख्या बताना।',
      'description_sat': 'ᱫᱷᱤᱨᱤ, ᱡᱟᱝ ᱮᱢᱟᱱ ᱡᱤᱱᱤᱥ ᱞᱮᱠᱷᱟ ᱠᱟᱛᱮ ᱮᱞ ᱞᱟᱹᱭ᱾',
      'description_en': 'One-to-one correspondence counting of concrete physical objects.',
      'verification_status': verificationNotice,
    });

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
      await db.insert('classroom_phrases', phrase);
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
      });
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
      await db.insert('flashcards', fc);
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
