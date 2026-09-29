import 'dart:math';
import '../../../core/services/tribal_lexicon_data.dart';
import '../models/quiz_question_model.dart';

/// Algorithmic Quiz Generator that produces unlimited fresh questions
/// across FLN Mathematics, Santhali Language, and Environmental Studies.
class QuizQuestionGenerator {
  static final QuizQuestionGenerator instance = QuizQuestionGenerator._init();
  QuizQuestionGenerator._init();

  final Random _rng = Random();

  static const List<Map<String, String>> _mathItems = [
    {'name': 'सेब', 'visual': '🍎'},
    {'name': 'आम', 'visual': '🥭'},
    {'name': 'अमरूद', 'visual': '🍐'},
    {'name': 'फूल', 'visual': '🌸'},
    {'name': 'तारे', 'visual': '⭐'},
    {'name': 'चिड़िया', 'visual': '🐦'},
  ];

  /// Generate a fresh batch of randomized questions
  List<QuizQuestion> generateQuiz({int count = 5, String category = 'all'}) {
    final List<QuizQuestion> questions = [];
    final setIds = <String>{};

    int attempts = 0;
    while (questions.length < count && attempts < 40) {
      attempts++;
      QuizQuestion q;
      final cat = category == 'all' ? _pickRandomCategory() : category;

      switch (cat) {
        case 'maths':
          q = _generateMathQuestion();
          break;
        case 'language':
          q = _generateLanguageQuestion();
          break;
        case 'evs':
          q = _generateEvsQuestion();
          break;
        default:
          q = _generateMathQuestion();
      }

      if (!setIds.contains(q.id)) {
        setIds.add(q.id);
        questions.add(q);
      }
    }

    return questions;
  }

  String _pickRandomCategory() {
    const cats = ['maths', 'maths', 'language', 'evs'];
    return cats[_rng.nextInt(cats.length)];
  }

  // -------------------------------------------------------------
  // FLN Mathematics Questions
  // -------------------------------------------------------------
  QuizQuestion _generateMathQuestion() {
    final type = _rng.nextInt(4);
    switch (type) {
      case 0:
        return _generateAdditionQuestion();
      case 1:
        return _generateSubtractionQuestion();
      case 2:
        return _generateCountingOlChikiQuestion();
      default:
        return _generateShapeQuestion();
    }
  }

  QuizQuestion _generateAdditionQuestion() {
    final a = _rng.nextInt(5) + 1; // 1 to 5
    final b = _rng.nextInt(5) + 1; // 1 to 5
    final sum = a + b;
    final item = _mathItems[_rng.nextInt(_mathItems.length)];

    final aNum = TribalLexiconData.numbers.firstWhere((n) => n['num'] == a);
    final bNum = TribalLexiconData.numbers.firstWhere((n) => n['num'] == b);
    final sumNum = TribalLexiconData.numbers.firstWhere((n) => n['num'] == sum);

    final visualA = List.filled(a, item['visual']!).join(' ');
    final visualB = List.filled(b, item['visual']!).join(' ');

    // Options
    final options = <QuizOption>[
      QuizOption(
        label: '$sum ${item['name']}',
        scriptText: '${sumNum['santhali_word']} (${sumNum['santhali_ol']})',
        phonetic: '${sumNum['santhali_dev']}',
        visual: '✅',
        isCorrect: true,
      ),
    ];

    // Distractors
    final wrongVals = <int>{};
    for (int offset in [-2, -1, 1, 2, 3]) {
      final val = sum + offset;
      if (val > 0 && val <= 10 && val != sum) {
        wrongVals.add(val);
      }
    }
    int candidate = 1;
    while (wrongVals.length < 3 && candidate <= 10) {
      if (candidate != sum) {
        wrongVals.add(candidate);
      }
      candidate++;
    }
    final wrongList = wrongVals.toList()..shuffle(_rng);
    for (int i = 0; i < 3; i++) {
      final wVal = wrongList[i];
      final wNum = TribalLexiconData.numbers.firstWhere((n) => n['num'] == wVal);
      options.add(
        QuizOption(
          label: '$wVal ${item['name']}',
          scriptText: '${wNum['santhali_word']} (${wNum['santhali_ol']})',
          phonetic: '${wNum['santhali_dev']}',
          visual: '⭕',
          isCorrect: false,
        ),
      );
    }
    options.shuffle(_rng);

    return QuizQuestion(
      id: 'math_add_${a}_${b}_${DateTime.now().microsecondsSinceEpoch}',
      category: 'maths',
      titleHi: '$visualA ($a)  +  $visualB ($b) = कितने ${item['name']}?',
      titleSat: '${aNum['santhali_ol']} + ${bNum['santhali_ol']} = ?',
      spokenAudioPrompt: 'प्यारे बच्चों, $a ${item['name']} और $b ${item['name']} को मिलाकर गिनें, कुल कितने होंगे?',
      visualSymbol: item['visual']!,
      options: options,
      explanation: '$a और $b मिलकर $sum होते हैं! संथाली में इसे ${sumNum['santhali_dev']} (${sumNum['santhali_ol']}) कहते हैं।',
    );
  }

  QuizQuestion _generateSubtractionQuestion() {
    final a = _rng.nextInt(6) + 4; // 4 to 9
    final b = _rng.nextInt(a - 1) + 1; // 1 to a-1
    final rem = a - b;
    final item = _mathItems[_rng.nextInt(_mathItems.length)];

    final remNum = TribalLexiconData.numbers.firstWhere((n) => n['num'] == rem);

    final options = <QuizOption>[
      QuizOption(
        label: '$rem ${item['name']}',
        scriptText: '${remNum['santhali_word']} (${remNum['santhali_ol']})',
        phonetic: '${remNum['santhali_dev']}',
        visual: '✅',
        isCorrect: true,
      ),
    ];

    final wrongVals = <int>{};
    for (int offset in [-2, -1, 1, 2, 3]) {
      final val = rem + offset;
      if (val > 0 && val <= 10 && val != rem) {
        wrongVals.add(val);
      }
    }
    int candidate = 1;
    while (wrongVals.length < 3 && candidate <= 10) {
      if (candidate != rem) {
        wrongVals.add(candidate);
      }
      candidate++;
    }
    final wrongList = wrongVals.toList()..shuffle(_rng);
    for (int i = 0; i < 3; i++) {
      final wVal = wrongList[i];
      final wNum = TribalLexiconData.numbers.firstWhere((n) => n['num'] == wVal);
      options.add(
        QuizOption(
          label: '$wVal ${item['name']}',
          scriptText: '${wNum['santhali_word']} (${wNum['santhali_ol']})',
          phonetic: '${wNum['santhali_dev']}',
          visual: '⭕',
          isCorrect: false,
        ),
      );
    }
    options.shuffle(_rng);

    return QuizQuestion(
      id: 'math_sub_${a}_${b}_${DateTime.now().microsecondsSinceEpoch}',
      category: 'maths',
      titleHi: 'टोकरी में $a ${item['name']} थे। $b निकाल लिए, तो कितने बचे?',
      titleSat: 'ᱜᱷᱟᱴᱟᱣ: $a - $b = ?',
      spokenAudioPrompt: 'प्यारे बच्चों, $a ${item['name']} में से $b घटाएँ तो कितने बचेंगे?',
      visualSymbol: '🧺',
      options: options,
      explanation: '$a में से $b घटाने पर $rem बचते हैं! संथाली में बोलें: ${remNum['santhali_dev']}!',
    );
  }

  QuizQuestion _generateCountingOlChikiQuestion() {
    final num = _rng.nextInt(10) + 1; // 1 to 10
    final numData = TribalLexiconData.numbers.firstWhere((n) => n['num'] == num);

    final options = <QuizOption>[
      QuizOption(
        label: '${numData['hindi']} ($num)',
        scriptText: '${numData['santhali_word']} (${numData['santhali_ol']})',
        phonetic: '${numData['santhali_dev']}',
        visual: '🌟',
        isCorrect: true,
      ),
    ];

    final otherNums = TribalLexiconData.numbers.where((n) => n['num'] != num).toList()..shuffle(_rng);
    for (int i = 0; i < 3; i++) {
      final w = otherNums[i];
      options.add(
        QuizOption(
          label: '${w['hindi']} (${w['num']})',
          scriptText: '${w['santhali_word']} (${w['santhali_ol']})',
          phonetic: '${w['santhali_dev']}',
          visual: '🔢',
          isCorrect: false,
        ),
      );
    }
    options.shuffle(_rng);

    return QuizQuestion(
      id: 'math_count_${num}_${DateTime.now().microsecondsSinceEpoch}',
      category: 'maths',
      titleHi: 'संथाली लिपि में लिखी संख्या "${numData['santhali_ol']}" को पहचानें:',
      titleSat: 'ᱚᱞ ᱪᱤᱠᱤ: ${numData['santhali_ol']} = ?',
      spokenAudioPrompt: 'प्यारे बच्चों, ओल चिकी अंक ${numData['santhali_ol']} का हिंदी में क्या मान है?',
      visualSymbol: '🔢',
      options: options,
      explanation: 'ओल चिकी में "${numData['santhali_ol']}" संख्या $num (${numData['hindi']}) है, जिसे संथाली में ${numData['santhali_dev']} कहते हैं।',
    );
  }

  QuizQuestion _generateShapeQuestion() {
    const shapes = [
      {
        'object': 'रोटी (🫓)',
        'shape_hi': 'गोल (वृत्त)',
        'sat': 'ᱜᱩᱞᱟᱹᱭ',
        'sat_dev': 'गुलाय',
        'visual': '⭕',
      },
      {
        'object': 'पढ़ने वाली स्लेट (⬛)',
        'shape_hi': 'चौकोर (वर्ग)',
        'sat': 'ᱯᱩᱱ ᱠᱳᱬ',
        'sat_dev': 'पून कोण',
        'visual': '⬛',
      },
      {
        'object': 'समोसा (🔺)',
        'shape_hi': 'त्रिकोण (त्रिभुज)',
        'sat': 'ᱯᱮ ᱠᱳᱬ',
        'sat_dev': 'पे कोण',
        'visual': '🔺',
      },
    ];

    final correctIndex = _rng.nextInt(shapes.length);
    final correct = shapes[correctIndex];

    final options = <QuizOption>[
      QuizOption(
        label: correct['shape_hi']!,
        scriptText: correct['sat'],
        phonetic: correct['sat_dev'],
        visual: correct['visual'],
        isCorrect: true,
      ),
    ];

    for (int i = 0; i < shapes.length; i++) {
      if (i != correctIndex) {
        options.add(
          QuizOption(
            label: shapes[i]['shape_hi']!,
            scriptText: shapes[i]['sat'],
            phonetic: shapes[i]['sat_dev'],
            visual: shapes[i]['visual'],
            isCorrect: false,
          ),
        );
      }
    }
    // Add one extra distractor
    options.add(
      const QuizOption(
        label: 'लंबा (आयत)',
        scriptText: 'ᱡᱤᱞᱤᱧ',
        phonetic: 'जिलिञ',
        visual: '📏',
        isCorrect: false,
      ),
    );
    options.shuffle(_rng);

    return QuizQuestion(
      id: 'math_shape_${correctIndex}_${DateTime.now().microsecondsSinceEpoch}',
      category: 'maths',
      titleHi: '${correct['object']} का आकार कैसा होता है?',
      titleSat: 'ᱨᱩᱯ ᱪᱤᱱᱦᱟᱹᱣ: ${correct['sat']}?',
      spokenAudioPrompt: 'प्यारे बच्चों, ${correct['object']} की आकृति कैसी होती है?',
      visualSymbol: correct['visual']!,
      options: options,
      explanation: '${correct['object']} का आकार ${correct['shape_hi']} होता है, जिसे संथाली में ${correct['sat_dev']} (${correct['sat']}) कहते हैं!',
    );
  }

  // -------------------------------------------------------------
  // Language & Santhali Vocabulary Questions
  // -------------------------------------------------------------
  QuizQuestion _generateLanguageQuestion() {
    // Pick from Animals, Fruits, Family, or Colors
    final eligible = TribalLexiconData.vocabulary
        .where((v) => ['Animals', 'Food', 'Family', 'Colors'].contains(v['category']))
        .toList();

    eligible.shuffle(_rng);
    final correct = eligible.first;

    final options = <QuizOption>[
      QuizOption(
        label: '${correct['santhali_dev']}',
        scriptText: '${correct['santhali']}',
        phonetic: '${correct['santhali_latin']}',
        visual: (correct['visual'] as String?) ?? '🌸',
        isCorrect: true,
      ),
    ];

    final wrongPool = eligible.where((v) => v['hindi'] != correct['hindi']).toList()..shuffle(_rng);
    for (int i = 0; i < min(3, wrongPool.length); i++) {
      final w = wrongPool[i];
      options.add(
        QuizOption(
          label: '${w['santhali_dev']}',
          scriptText: '${w['santhali']}',
          phonetic: '${w['santhali_latin']}',
          visual: (w['visual'] as String?) ?? '🌸',
          isCorrect: false,
        ),
      );
    }
    options.shuffle(_rng);

    return QuizQuestion(
      id: 'lang_${correct['hindi']}_${DateTime.now().microsecondsSinceEpoch}',
      category: 'language',
      titleHi: '"${correct['hindi']}" (${correct['visual']}) को संथाली में क्या कहते हैं?',
      titleSat: '${correct['santhali']} ᱢᱮᱱᱮᱛ ᱪᱮᱫ?',
      spokenAudioPrompt: 'प्यारे बच्चों, "${correct['hindi']}" को संथाली भाषा में क्या बोलते हैं?',
      visualSymbol: (correct['visual'] as String?) ?? '🌟',
      options: options,
      explanation: '"${correct['hindi']}" को संथाली में ${correct['santhali_dev']} (${correct['santhali']}) कहते हैं!',
    );
  }

  // -------------------------------------------------------------
  // Environmental Studies (EVS) Questions
  // -------------------------------------------------------------
  QuizQuestion _generateEvsQuestion() {
    final eligible = TribalLexiconData.vocabulary
        .where((v) => ['Nature', 'Animals', 'Body'].contains(v['category']))
        .toList();

    if (eligible.isEmpty) return _generateLanguageQuestion();
    eligible.shuffle(_rng);
    final correct = eligible.first;

    final options = <QuizOption>[
      QuizOption(
        label: '${correct['santhali_dev']}',
        scriptText: '${correct['santhali']}',
        phonetic: '${correct['santhali_latin']}',
        visual: (correct['visual'] as String?) ?? '🌿',
        isCorrect: true,
      ),
    ];

    final wrongPool = eligible.where((v) => v['hindi'] != correct['hindi']).toList()..shuffle(_rng);
    for (int i = 0; i < min(3, wrongPool.length); i++) {
      final w = wrongPool[i];
      options.add(
        QuizOption(
          label: '${w['santhali_dev']}',
          scriptText: '${w['santhali']}',
          phonetic: '${w['santhali_latin']}',
          visual: (w['visual'] as String?) ?? '🌿',
          isCorrect: false,
        ),
      );
    }
    options.shuffle(_rng);

    return QuizQuestion(
      id: 'evs_${correct['hindi']}_${DateTime.now().microsecondsSinceEpoch}',
      category: 'evs',
      titleHi: 'प्रकृति और पर्यावरण: "${correct['hindi']}" (${correct['visual']}) को पहचानें:',
      titleSat: 'ᱵᱤᱨ-ᱡᱤᱭᱟᱹᱞᱤ: ${correct['santhali']}?',
      spokenAudioPrompt: 'प्यारे बच्चों, हमारे आस-पास पाए जाने वाले "${correct['hindi']}" को संथाली में क्या कहते हैं?',
      visualSymbol: (correct['visual'] as String?) ?? '🌿',
      options: options,
      explanation: 'झारखंड की प्रकृति में "${correct['hindi']}" को संथाली में ${correct['santhali_dev']} (${correct['santhali']}) कहते हैं!',
    );
  }
}
