import 'dart:math';
import 'tribal_lexicon_data.dart';

enum TribalLanguage {
  santhali,
  ho,
  mundari;

  String get displayName {
    switch (this) {
      case TribalLanguage.santhali:
        return 'Santhali (Ol Chiki)';
      case TribalLanguage.ho:
        return 'Ho (हो)';
      case TribalLanguage.mundari:
        return 'Mundari (मुंडारी)';
    }
  }

  String get nativeLabel {
    switch (this) {
      case TribalLanguage.santhali:
        return 'ᱥᱟᱱᱛᱟᱲᱤ (Ol Chiki)';
      case TribalLanguage.ho:
        return 'हो (Warang Chiti / Devanagari)';
      case TribalLanguage.mundari:
        return 'मुंडारी (Bani / Devanagari)';
    }
  }
}

class TranslationResult {
  final String sourceText;
  final String sourceLang;
  final String targetLang;
  final String primaryText; // In native script (e.g. Ol Chiki for Santhali)
  final String phoneticDevanagari; // Phonetic Devanagari for Hindi teachers
  final String latinPronunciation; // Phonetic Latin pronunciation
  final String englishMeaning;
  final String visualSymbol; // Child-friendly emoji icon
  final int latencyMs;
  final String matchType; // Exact Intent, Vocabulary Match, Rule Synthesized, Fallback
  final bool isOfflineReady;

  const TranslationResult({
    required this.sourceText,
    required this.sourceLang,
    required this.targetLang,
    required this.primaryText,
    required this.phoneticDevanagari,
    required this.latinPronunciation,
    required this.englishMeaning,
    this.visualSymbol = '🌟',
    required this.latencyMs,
    required this.matchType,
    this.isOfflineReady = true,
  });
}

class TranslationEngine {
  static final TranslationEngine instance = TranslationEngine._init();
  TranslationEngine._init();

  /// Syllabic Ol Chiki to Devanagari transliteration maps (produces fluent matras without halant cutoff)
  static final Map<String, String> _olChikiVowelsIndependent = {
    'ᱚ': 'अ', 'ᱟ': 'आ', 'ᱤ': 'इ', 'ᱩ': 'उ', 'ᱮ': 'ए', 'ᱳ': 'ओ',
  };

  static final Map<String, String> _olChikiVowelsMatra = {
    'ᱚ': 'ो', 'ᱟ': 'ा', 'ᱤ': 'ि', 'ᱩ': 'ु', 'ᱮ': 'े', 'ᱳ': 'ो',
  };

  static final Map<String, String> _olChikiConsonants = {
    'ᱛ': 'त', 'ᱜ': 'ग', 'ᱝ': 'ं', 'ᱞ': 'ल',
    'ᱠ': 'क', 'ᱡ': 'ज', 'ᱢ': 'म', 'ᱣ': 'व',
    'ᱥ': 'स', 'ᱦ': 'ह', 'ᱧ': 'ञ', 'ᱨ': 'र',
    'ᱪ': 'च', 'ᱫ': 'द', 'ᱬ': 'ण', 'ᱭ': 'य',
    'ᱯ': 'प', 'ᱰ': 'ड', 'ᱱ': 'न', 'ᱲ': 'ड़',
    'ᱴ': 'ट', 'ᱵ': 'ब',
  };

  static final Map<String, String> _olChikiAspirated = {
    'क': 'ख', 'ग': 'घ',
    'च': 'छ', 'ज': 'झ',
    'ट': 'ठ', 'ड': 'ढ',
    'त': 'थ', 'द': 'ध',
    'प': 'फ', 'ब': 'भ',
  };

  static final Map<String, String> _olChikiModifiers = {
    '᱐': '०', '᱑': '१', '᱒': '२', '᱓': '३', '᱔': '४',
    '᱕': '५', '᱖': '६', '᱗': '७', '᱘': '८', '᱙': '९',
    'ᱸ': 'ं', 'ᱹ': '', 'ᱺ': 'ः', 'ᱼ': ' ', 'ᱽ': '', '᱾': '।', '᱿': '॥',
  };

  /// Translate from Hindi to selected Tribal Language
  TranslationResult translateHindiToTribal(
    String input, {
    TribalLanguage targetLanguage = TribalLanguage.santhali,
  }) {
    final stopwatch = Stopwatch()..start();
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) {
      stopwatch.stop();
      return TranslationResult(
        sourceText: input,
        sourceLang: 'Hindi',
        targetLang: targetLanguage.displayName,
        primaryText: '',
        phoneticDevanagari: '',
        latinPronunciation: '',
        englishMeaning: '',
        latencyMs: max(1, stopwatch.elapsedMilliseconds),
        matchType: 'Empty',
      );
    }

    final lowerInput = cleanInput.toLowerCase();

    // 0a. Check English & Hinglish Universal Intent Map (Classroom Commands & Routines)
    if (TribalLexiconData.englishHinglishToIntent.containsKey(lowerInput)) {
      final intent = TribalLexiconData.englishHinglishToIntent[lowerInput]!;
      final phrase = TribalLexiconData.classroomPhrases.firstWhere(
        (p) => p['intent'] == intent,
        orElse: () => {},
      );
      if (phrase.isNotEmpty) {
        stopwatch.stop();
        return _formatResultFromPhrase(cleanInput, phrase, targetLanguage, stopwatch.elapsedMilliseconds, 'Classroom Intent (English/Hinglish)');
      }
    }
    for (final entry in TribalLexiconData.englishHinglishToIntent.entries) {
      if (lowerInput.contains(entry.key) && entry.key.length >= 4) {
        final phrase = TribalLexiconData.classroomPhrases.firstWhere(
          (p) => p['intent'] == entry.value,
          orElse: () => {},
        );
        if (phrase.isNotEmpty) {
          stopwatch.stop();
          return _formatResultFromPhrase(cleanInput, phrase, targetLanguage, stopwatch.elapsedMilliseconds, 'Classroom Intent (English/Hinglish)');
        }
      }
    }

    // 0b. Check English & Hinglish Vocabulary Mapping (Animals, Fruits, Family, Nature)
    if (TribalLexiconData.englishHinglishToHindiVocab.containsKey(lowerInput)) {
      final targetHi = TribalLexiconData.englishHinglishToHindiVocab[lowerInput]!;
      for (final vocab in TribalLexiconData.vocabulary) {
        final vocabHi = (vocab['hindi'] as String).toLowerCase();
        if (vocabHi == targetHi || vocabHi.split('/').any((p) => p.trim() == targetHi)) {
          stopwatch.stop();
          return _formatResultFromVocab(cleanInput, vocab, targetLanguage, stopwatch.elapsedMilliseconds, 'FLN Vocabulary (English/Hinglish)');
        }
      }
    }

    // 0c. Check Direct English Meaning in Vocabulary
    for (final vocab in TribalLexiconData.vocabulary) {
      final meaningEn = (vocab['meaning_en'] as String).toLowerCase();
      final parts = meaningEn.split(RegExp(r'[/,]')).map((p) => p.trim());
      if (lowerInput == meaningEn || parts.contains(lowerInput)) {
        stopwatch.stop();
        return _formatResultFromVocab(cleanInput, vocab, targetLanguage, stopwatch.elapsedMilliseconds, 'FLN Vocabulary (English)');
      }
    }

    // 0d. Check Exact Vocabulary Match (Single Noun or Direct Hindi Term)
    for (final vocab in TribalLexiconData.vocabulary) {
      final vocabHi = (vocab['hindi'] as String).toLowerCase();
      final parts = vocabHi.split('/').map((p) => p.trim());
      if (lowerInput == vocabHi || parts.contains(lowerInput)) {
        stopwatch.stop();
        return _formatResultFromVocab(cleanInput, vocab, targetLanguage, stopwatch.elapsedMilliseconds, 'FLN Vocabulary (Exact)');
      }
    }

    // 1. Check Exact or Keyword Classroom Intent Match
    for (final phrase in TribalLexiconData.classroomPhrases) {
      final phraseHi = (phrase['hindi'] as String).toLowerCase();
      final phraseEn = (phrase['meaning_en'] as String).toLowerCase();
      final keywords = (phrase['keywords_hi'] as List<dynamic>? ?? []).map((e) => e.toString().toLowerCase());

      if (lowerInput == phraseHi || lowerInput.contains(phraseHi) ||
          lowerInput == phraseEn || lowerInput.contains(phraseEn) ||
          keywords.any((k) => lowerInput.contains(k))) {
        stopwatch.stop();
        return _formatResultFromPhrase(cleanInput, phrase, targetLanguage, stopwatch.elapsedMilliseconds, 'Classroom Intent');
      }
    }

    // 2. Check Number Match (Digits, Hindi Words, English Words, Hinglish Words 1-100)
    final numResult = _matchNumber(cleanInput, targetLanguage, stopwatch);
    if (numResult != null) {
      return numResult;
    }

    // 3. Check Single Vocabulary Match for 1-2 word queries (Animals, Nature, Colors, Shapes, Classroom)
    if (cleanInput.split(RegExp(r'\s+')).length <= 2) {
      for (final vocab in TribalLexiconData.vocabulary) {
        final vocabHi = (vocab['hindi'] as String).toLowerCase();
        if (lowerInput.contains(vocabHi) || vocabHi.split('/').any((part) => lowerInput.contains(part.trim()))) {
          stopwatch.stop();
          return _formatResultFromVocab(cleanInput, vocab, targetLanguage, stopwatch.elapsedMilliseconds, 'FLN Vocabulary');
        }
      }
    }

    // 4. Dynamic Multi-Word Phrase & Sentence-Level NLP Translator
    return _translateDynamicSentence(cleanInput, targetLanguage, stopwatch);
  }

  /// Translate from Tribal Language to Hindi (Student to Teacher Dialogue)
  TranslationResult translateTribalToHindi(
    String input, {
    TribalLanguage sourceLanguage = TribalLanguage.santhali,
  }) {
    final stopwatch = Stopwatch()..start();
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) {
      stopwatch.stop();
      return TranslationResult(
        sourceText: input,
        sourceLang: sourceLanguage.displayName,
        targetLang: 'Hindi',
        primaryText: '',
        phoneticDevanagari: '',
        latinPronunciation: '',
        englishMeaning: '',
        latencyMs: max(1, stopwatch.elapsedMilliseconds),
        matchType: 'Empty',
      );
    }

    // 1. Check classroom phrases
    for (final phrase in TribalLexiconData.classroomPhrases) {
      final sat = (phrase['santhali'] as String?)?.toLowerCase() ?? '';
      final satDev = (phrase['santhali_dev'] as String?)?.toLowerCase() ?? '';
      final satLatin = (phrase['santhali_latin'] as String?)?.toLowerCase() ?? '';
      final ho = (phrase['ho'] as String?)?.toLowerCase() ?? '';
      final mundari = (phrase['mundari'] as String?)?.toLowerCase() ?? '';

      final lower = cleanInput.toLowerCase();
      if (lower == sat || lower.contains(sat) ||
          lower == satDev || lower.contains(satDev) ||
          lower == satLatin || lower.contains(satLatin) ||
          lower == ho || lower.contains(ho) ||
          lower == mundari || lower.contains(mundari)) {
        stopwatch.stop();
        return TranslationResult(
          sourceText: cleanInput,
          sourceLang: sourceLanguage.displayName,
          targetLang: 'Hindi',
          primaryText: phrase['hindi'] as String,
          phoneticDevanagari: phrase['hindi'] as String,
          latinPronunciation: phrase['hindi'] as String,
          englishMeaning: phrase['meaning_en'] as String,
          latencyMs: max(2, stopwatch.elapsedMilliseconds),
          matchType: 'Classroom Intent (Student -> Teacher)',
        );
      }
    }

    // 2. Check Numbers
    for (final numItem in TribalLexiconData.numbers) {
      final satWord = (numItem['santhali_word'] as String?)?.toLowerCase() ?? '';
      final satDev = (numItem['santhali_dev'] as String?)?.toLowerCase() ?? '';
      final satOl = (numItem['santhali_ol'] as String?) ?? '';
      final ho = (numItem['ho'] as String?)?.toLowerCase() ?? '';
      final mundari = (numItem['mundari'] as String?)?.toLowerCase() ?? '';
      final lower = cleanInput.toLowerCase();

      if (lower.contains(satWord) || lower.contains(satDev) || lower.contains(satOl) ||
          lower.contains(ho) || lower.contains(mundari)) {
        stopwatch.stop();
        return TranslationResult(
          sourceText: cleanInput,
          sourceLang: sourceLanguage.displayName,
          targetLang: 'Hindi',
          primaryText: '${numItem['hindi']} (${numItem['num']})',
          phoneticDevanagari: numItem['hindi'] as String,
          latinPronunciation: numItem['hindi'] as String,
          englishMeaning: 'Number ${numItem['num']}',
          latencyMs: max(2, stopwatch.elapsedMilliseconds),
          matchType: 'Numeracy Match',
        );
      }
    }

    // 3. Check Vocabulary
    for (final vocab in TribalLexiconData.vocabulary) {
      final sat = (vocab['santhali'] as String?)?.toLowerCase() ?? '';
      final satDev = (vocab['santhali_dev'] as String?)?.toLowerCase() ?? '';
      final satLatin = (vocab['santhali_latin'] as String?)?.toLowerCase() ?? '';
      final ho = (vocab['ho'] as String?)?.toLowerCase() ?? '';
      final mundari = (vocab['mundari'] as String?)?.toLowerCase() ?? '';
      final lower = cleanInput.toLowerCase();

      if (lower.contains(sat) || lower.contains(satDev) || lower.contains(satLatin) ||
          lower.contains(ho) || lower.contains(mundari)) {
        stopwatch.stop();
        return TranslationResult(
          sourceText: cleanInput,
          sourceLang: sourceLanguage.displayName,
          targetLang: 'Hindi',
          primaryText: vocab['hindi'] as String,
          phoneticDevanagari: vocab['hindi'] as String,
          latinPronunciation: vocab['hindi'] as String,
          englishMeaning: vocab['meaning_en'] as String,
          latencyMs: max(2, stopwatch.elapsedMilliseconds),
          matchType: 'FLN Vocabulary (Student -> Teacher)',
        );
      }
    }

    stopwatch.stop();
    return TranslationResult(
      sourceText: cleanInput,
      sourceLang: sourceLanguage.displayName,
      targetLang: 'Hindi',
      primaryText: cleanInput,
      phoneticDevanagari: cleanInput,
      latinPronunciation: cleanInput,
      englishMeaning: 'Classroom vernacular expression: $cleanInput',
      latencyMs: max(4, stopwatch.elapsedMilliseconds),
      matchType: 'Phonetic Transfer',
    );
  }

  TranslationResult? _matchNumber(
    String input,
    TribalLanguage targetLanguage,
    Stopwatch stopwatch,
  ) {
    const devanagariDigits = {'०': 0, '१': 1, '२': 2, '३': 3, '४': 4, '५': 5, '६': 6, '७': 7, '८': 8, '९': 9};
    const englishNumberWords = {
      'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
      'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
      'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
      'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19, 'twenty': 20,
    };
    const hinglishNumberWords = {
      'shunya': 0, 'sunya': 0, 'ek': 1, 'do': 2, 'teen': 3, 'tin': 3,
      'char': 4, 'chaar': 4, 'paanch': 5, 'panch': 5, 'chhe': 6, 'che': 6,
      'saat': 7, 'sat': 7, 'aath': 8, 'ath': 8, 'nau': 9, 'no': 9,
      'das': 10, 'dus': 10, 'gyarah': 11, 'barah': 12, 'terah': 13,
      'chaudah': 14, 'pandrah': 15, 'solah': 16, 'satrah': 17, 'atharah': 18,
      'unnis': 19, 'bees': 20,
    };

    int? parsedNum;
    final trimmed = input.trim().toLowerCase();

    if (englishNumberWords.containsKey(trimmed)) {
      parsedNum = englishNumberWords[trimmed];
    } else if (hinglishNumberWords.containsKey(trimmed)) {
      parsedNum = hinglishNumberWords[trimmed];
    } else if (devanagariDigits.containsKey(trimmed)) {
      parsedNum = devanagariDigits[trimmed];
    } else {
      final buffer = StringBuffer();
      for (int i = 0; i < trimmed.length; i++) {
        final ch = trimmed[i];
        if (devanagariDigits.containsKey(ch)) {
          buffer.write(devanagariDigits[ch]);
        } else if (RegExp(r'\d').hasMatch(ch)) {
          buffer.write(ch);
        }
      }
      if (buffer.isNotEmpty) {
        parsedNum = int.tryParse(buffer.toString());
      }
    }

    for (final item in TribalLexiconData.numbers) {
      final numVal = item['num'] as int;
      final hiName = (item['hindi'] as String).toLowerCase();

      if (parsedNum == numVal || input.toLowerCase().contains(hiName)) {
        stopwatch.stop();
        String primary;
        String dev;
        String latin;

        if (targetLanguage == TribalLanguage.santhali) {
          primary = '${item['santhali_word']} (${item['santhali_ol']})';
          dev = item['santhali_dev'] as String;
          latin = item['santhali_latin'] as String;
        } else if (targetLanguage == TribalLanguage.ho) {
          primary = '${item['ho']} ($numVal)';
          dev = item['ho'] as String;
          latin = item['ho_latin'] as String;
        } else {
          primary = '${item['mundari']} ($numVal)';
          dev = item['mundari'] as String;
          latin = item['mundari_latin'] as String;
        }

        return TranslationResult(
          sourceText: input,
          sourceLang: 'Hindi',
          targetLang: targetLanguage.displayName,
          primaryText: primary,
          phoneticDevanagari: dev,
          latinPronunciation: latin,
          englishMeaning: 'Cardinal Number $numVal',
          visualSymbol: (item['visual'] as String?) ?? '🔢',
          latencyMs: max(2, stopwatch.elapsedMilliseconds),
          matchType: 'FLN Numeracy Match',
        );
      }
    }
    return null;
  }

  TranslationResult _formatResultFromPhrase(
    String source,
    Map<String, dynamic> phrase,
    TribalLanguage targetLang,
    int elapsedMs,
    String matchType,
  ) {
    String primary;
    String dev;
    String latin;

    switch (targetLang) {
      case TribalLanguage.santhali:
        primary = phrase['santhali'] as String;
        dev = phrase['santhali_dev'] as String;
        latin = phrase['santhali_latin'] as String;
        break;
      case TribalLanguage.ho:
        primary = phrase['ho'] as String;
        dev = phrase['ho'] as String;
        latin = phrase['ho_latin'] as String;
        break;
      case TribalLanguage.mundari:
        primary = phrase['mundari'] as String;
        dev = phrase['mundari'] as String;
        latin = phrase['mundari_latin'] as String;
        break;
    }

    String visual = '🌟';
    final intent = phrase['intent'] as String?;
    if (intent == 'GREETING') {
      visual = '👋';
    } else if (intent == 'DRINK_WATER') {
      visual = '💧';
    } else if (intent == 'OPEN_BOOK' || intent == 'CLOSE_BOOK') {
      visual = '📖';
    } else if (intent == 'CLAP') {
      visual = '👏';
    } else if (intent == 'STAND_UP') {
      visual = '🧍';
    } else if (intent == 'SIT_DOWN') {
      visual = '🪑';
    } else if (intent == 'GOOD') {
      visual = '⭐';
    } else if (intent == 'BE_QUIET') {
      visual = '🤫';
    } else if (intent == 'WASH_HANDS') {
      visual = '🧼';
    } else if (intent == 'PLAY_GAME') {
      visual = '⚽';
    } else if (intent == 'SING') {
      visual = '🎵';
    } else if (intent == 'SMILE') {
      visual = '😊';
    } else if (intent == 'WRITE') {
      visual = '✏️';
    } else if (intent == 'EAT_FOOD') {
      visual = '🍲';
    }

    return TranslationResult(
      sourceText: source,
      sourceLang: 'Hindi',
      targetLang: targetLang.displayName,
      primaryText: primary,
      phoneticDevanagari: dev,
      latinPronunciation: latin,
      englishMeaning: phrase['meaning_en'] as String,
      visualSymbol: visual,
      latencyMs: max(2, elapsedMs),
      matchType: matchType,
    );
  }

  TranslationResult _formatResultFromVocab(
    String source,
    Map<String, dynamic> vocab,
    TribalLanguage targetLang,
    int elapsedMs,
    String matchType,
  ) {
    String primary;
    String dev;
    String latin;

    switch (targetLang) {
      case TribalLanguage.santhali:
        primary = vocab['santhali'] as String;
        dev = vocab['santhali_dev'] as String;
        latin = vocab['santhali_latin'] as String;
        break;
      case TribalLanguage.ho:
        primary = vocab['ho'] as String;
        dev = vocab['ho'] as String;
        latin = vocab['ho_latin'] as String;
        break;
      case TribalLanguage.mundari:
        primary = vocab['mundari'] as String;
        dev = vocab['mundari'] as String;
        latin = vocab['mundari_latin'] as String;
        break;
    }

    return TranslationResult(
      sourceText: source,
      sourceLang: 'Hindi',
      targetLang: targetLang.displayName,
      primaryText: primary,
      phoneticDevanagari: dev,
      latinPronunciation: latin,
      englishMeaning: vocab['meaning_en'] as String,
      visualSymbol: (vocab['visual'] as String?) ?? '🌸',
      latencyMs: max(2, elapsedMs),
      matchType: matchType,
    );
  }

  /// Converts Ol Chiki text into natural, fluent phonetic Devanagari guide
  /// Joins consonants and vowels into real Hindi matras (पे, बार, मिद)
  /// completely eliminating word-ending halant cutoffs and bass blowout.
  String olChikiToDevanagari(String olChiki) {
    final sb = StringBuffer();
    String? pendingConsonant;

    for (int i = 0; i < olChiki.length; i++) {
      final char = olChiki[i];

      // Aspiration modifier (ᱷ)
      if (char == 'ᱷ') {
        if (pendingConsonant != null && _olChikiAspirated.containsKey(pendingConsonant)) {
          pendingConsonant = _olChikiAspirated[pendingConsonant];
        } else {
          if (pendingConsonant != null) sb.write(pendingConsonant);
          pendingConsonant = 'ह';
        }
        continue;
      }

      // Vowels (matra vs independent)
      if (_olChikiVowelsMatra.containsKey(char)) {
        if (pendingConsonant != null) {
          sb.write(pendingConsonant);
          sb.write(_olChikiVowelsMatra[char]);
          pendingConsonant = null;
        } else {
          sb.write(_olChikiVowelsIndependent[char]);
        }
        continue;
      }

      // Consonants
      if (_olChikiConsonants.containsKey(char)) {
        if (pendingConsonant != null) {
          sb.write(pendingConsonant);
        }
        pendingConsonant = _olChikiConsonants[char];
        continue;
      }

      // Other symbols / modifiers / whitespace
      if (pendingConsonant != null) {
        sb.write(pendingConsonant);
        pendingConsonant = null;
      }

      if (_olChikiModifiers.containsKey(char)) {
        sb.write(_olChikiModifiers[char]);
      } else {
        sb.write(char);
      }
    }

    if (pendingConsonant != null) {
      sb.write(pendingConsonant);
    }

    return sb.toString();
  }

  static final Map<String, String> _devToOlChikiMap = {
    'अ': 'ᱚ', 'त्': 'ᱛ', 'त': 'ᱛ', 'ग्': 'ᱜ', 'ग': 'ᱜ', 'ं': 'ᱝ', 'ल्': 'ᱞ', 'ल': 'ᱞ',
    'आ': 'ᱟ', 'क्': 'ᱠ', 'क': 'ᱠ', 'ज्': 'ᱡ', 'ज': 'ᱡ', 'म्': 'ᱢ', 'म': 'ᱢ', 'व्': 'ᱣ', 'व': 'ᱣ',
    'इ': 'ᱤ', 'स्': 'ᱥ', 'स': 'ᱥ', 'ह्': 'ᱦ', 'ह': 'ᱦ', 'ञ्': 'ᱧ', 'ञ': 'ᱧ', 'र्': 'ᱨ', 'र': 'ᱨ',
    'उ': 'ᱩ', 'च्': 'ᱪ', 'च': 'ᱪ', 'द्': 'ᱫ', 'द': 'ᱫ', 'ण्': 'ᱬ', 'ण': 'ᱬ', 'य्': 'ᱭ', 'य': 'ᱭ',
    'ए': 'ᱮ', 'प्': 'ᱯ', 'प': 'ᱯ', 'ड्': 'ᱰ', 'ड': 'ᱰ', 'न्': 'ᱱ', 'न': 'ᱱ', 'ड़्': 'ᱲ', 'ड़': 'ᱲ',
    'ओ': 'ᱳ', 'ट्': 'ᱴ', 'ट': 'ᱴ', 'ब्': 'ᱵ', 'ब': 'ᱵ', 'ँ': 'ᱶ', 'ः': 'ᱺ',
    '०': '᱐', '१': '᱑', '२': '᱒', '३': '᱓', '४': '᱔',
    '५': '᱕', '६': '᱖', '७': '᱗', '८': '᱘', '९': '᱙',
    'ा': 'ᱟ', 'ि': 'ᱤ', 'ी': 'ᱤ', 'ु': 'ᱩ', 'ू': 'ᱩ', 'े': 'ᱮ', 'ै': 'ᱮ', 'ो': 'ᱳ', 'ौ': 'ᱳ', '।': '᱾', '॥': '᱿',
  };

  /// Transliterates Devanagari text into Ol Chiki script for Santhali
  String devanagariToOlChiki(String devanagari) {
    final sb = StringBuffer();
    for (int i = 0; i < devanagari.length; i++) {
      final ch = devanagari[i];
      if (_devToOlChikiMap.containsKey(ch)) {
        sb.write(_devToOlChikiMap[ch]);
      } else {
        sb.write(ch);
      }
    }
    return sb.toString();
  }

  void _appendMatchedWord(
    Map<String, String> match,
    TribalLanguage targetLanguage,
    List<String> primaryParts,
    List<String> devParts,
    List<String> latinParts,
  ) {
    if (targetLanguage == TribalLanguage.santhali) {
      primaryParts.add(match['sat'] ?? '');
      devParts.add(match['sat_dev'] ?? '');
      latinParts.add(match['sat_lat'] ?? '');
    } else if (targetLanguage == TribalLanguage.ho) {
      primaryParts.add(match['ho'] ?? '');
      devParts.add(match['ho'] ?? '');
      latinParts.add(match['ho_lat'] ?? '');
    } else {
      primaryParts.add(match['mun'] ?? '');
      devParts.add(match['mun'] ?? '');
      latinParts.add(match['mun_lat'] ?? '');
    }
  }

  TranslationResult _translateDynamicSentence(
    String cleanInput,
    TribalLanguage targetLanguage,
    Stopwatch stopwatch,
  ) {
    // 1. Punctuation handling
    String text = cleanInput.trim();
    String punctuation = '';
    if (text.endsWith('.') || text.endsWith('?') || text.endsWith('!') || text.endsWith('।')) {
      punctuation = text.substring(text.length - 1);
      text = text.substring(0, text.length - 1).trim();
    }

    // 2. Identify Visual Symbol
    String visualSymbol = '🌟';
    final lower = text.toLowerCase();
    if (lower.contains('बाहर') || lower.contains('दौड़') || lower.contains('भाग')) {
      visualSymbol = '🏃‍♂️';
    } else if (lower.contains('अंदर') || lower.contains('कमर') || lower.contains('कक्षा') || lower.contains('स्कूल')) {
      visualSymbol = '🏫';
    } else if (lower.contains('किताब') || lower.contains('पुस्तक') || lower.contains('पढ़')) {
      visualSymbol = '📖';
    } else if (lower.contains('लिख') || lower.contains('स्लेट') || lower.contains('कॉपी') || lower.contains('कलम')) {
      visualSymbol = '✏️';
    } else if (lower.contains('ताली')) {
      visualSymbol = '👏';
    } else if (lower.contains('पानी') || lower.contains('प्यास')) {
      visualSymbol = '💧';
    } else if (lower.contains('खाना') || lower.contains('भात') || lower.contains('रोटी') || lower.contains('भोजन') || lower.contains('फल')) {
      visualSymbol = '🍲';
    } else if (lower.contains('खेल') || lower.contains('मैदान')) {
      visualSymbol = '⚽';
    } else if (lower.contains('हाथ')) {
      visualSymbol = '✋';
    } else if (lower.contains('गा') || lower.contains('गीत') || lower.contains('कविता')) {
      visualSymbol = '🎵';
    } else if (lower.contains('हँस') || lower.contains('मुस्कुर')) {
      visualSymbol = '😊';
    } else if (lower.contains('शांत') || lower.contains('चुप')) {
      visualSymbol = '🤫';
    } else if (lower.contains('पेड़') || lower.contains('दारे')) {
      visualSymbol = '🌳';
    } else if (lower.contains('फूल') || lower.contains('बाहा')) {
      visualSymbol = '🌸';
    }

    // 3. Multi-Word Chunk & Word Token Matching
    final tokens = text.split(RegExp(r'\s+'));
    final List<String> primaryParts = [];
    final List<String> devParts = [];
    final List<String> latinParts = [];

    int i = 0;
    while (i < tokens.length) {
      // 3a. Try 3-word chunk
      if (i + 2 < tokens.length) {
        final tri = '${tokens[i]} ${tokens[i + 1]} ${tokens[i + 2]}'.toLowerCase();
        final match = TribalLexiconData.wordDictionary[tri];
        if (match != null) {
          _appendMatchedWord(match, targetLanguage, primaryParts, devParts, latinParts);
          i += 3;
          continue;
        }
      }

      // 3b. Try 2-word chunk
      if (i + 1 < tokens.length) {
        final bi = '${tokens[i]} ${tokens[i + 1]}'.toLowerCase();
        final match = TribalLexiconData.wordDictionary[bi];
        if (match != null) {
          _appendMatchedWord(match, targetLanguage, primaryParts, devParts, latinParts);
          i += 2;
          continue;
        }
      }

      // 3c. Try 1-word match in wordDictionary
      final single = tokens[i].toLowerCase();
      final matchSingle = TribalLexiconData.wordDictionary[single];
      if (matchSingle != null) {
        _appendMatchedWord(matchSingle, targetLanguage, primaryParts, devParts, latinParts);
        i++;
        continue;
      }

      // 3c-2. Try English/Hinglish vocabulary map
      if (TribalLexiconData.englishHinglishToHindiVocab.containsKey(single)) {
        final targetHi = TribalLexiconData.englishHinglishToHindiVocab[single]!;
        final matchedVocab = TribalLexiconData.vocabulary.firstWhere(
          (v) {
            final hi = (v['hindi'] as String).toLowerCase();
            return hi == targetHi || hi.split('/').any((p) => p.trim() == targetHi);
          },
          orElse: () => {},
        );
        if (matchedVocab.isNotEmpty) {
          if (targetLanguage == TribalLanguage.santhali) {
            primaryParts.add(matchedVocab['santhali'] as String);
            devParts.add(matchedVocab['santhali_dev'] as String);
            latinParts.add(matchedVocab['santhali_latin'] as String);
          } else if (targetLanguage == TribalLanguage.ho) {
            primaryParts.add(matchedVocab['ho'] as String);
            devParts.add(matchedVocab['ho'] as String);
            latinParts.add(matchedVocab['ho_latin'] as String);
          } else {
            primaryParts.add(matchedVocab['mundari'] as String);
            devParts.add(matchedVocab['mundari'] as String);
            latinParts.add(matchedVocab['mundari_latin'] as String);
          }
          i++;
          continue;
        }
      }

      // 3d. Try 1-word match in vocabulary
      final matchedVocab = TribalLexiconData.vocabulary.firstWhere(
        (v) {
          final hi = (v['hindi'] as String).toLowerCase();
          final en = (v['meaning_en'] as String).toLowerCase();
          final parts = hi.split('/').map((s) => s.trim());
          return parts.any((p) => p == single || single.contains(p)) || en == single;
        },
        orElse: () => {},
      );
      if (matchedVocab.isNotEmpty) {
        if (targetLanguage == TribalLanguage.santhali) {
          primaryParts.add(matchedVocab['santhali'] as String);
          devParts.add(matchedVocab['santhali_dev'] as String);
          latinParts.add(matchedVocab['santhali_latin'] as String);
        } else if (targetLanguage == TribalLanguage.ho) {
          primaryParts.add(matchedVocab['ho'] as String);
          devParts.add(matchedVocab['ho'] as String);
          latinParts.add(matchedVocab['ho_latin'] as String);
        } else {
          primaryParts.add(matchedVocab['mundari'] as String);
          devParts.add(matchedVocab['mundari'] as String);
          latinParts.add(matchedVocab['mundari_latin'] as String);
        }
        i++;
        continue;
      }

      // 3e. Try number match
      final numItem = TribalLexiconData.numbers.firstWhere(
        (n) {
          final hi = (n['hindi'] as String).toLowerCase();
          final numStr = '${n['num']}';
          return hi == single || numStr == single;
        },
        orElse: () => {},
      );
      if (numItem.isNotEmpty) {
        if (targetLanguage == TribalLanguage.santhali) {
          primaryParts.add(numItem['santhali_word'] as String);
          devParts.add(numItem['santhali_dev'] as String);
          latinParts.add(numItem['santhali_latin'] as String);
        } else if (targetLanguage == TribalLanguage.ho) {
          primaryParts.add(numItem['ho'] as String);
          devParts.add(numItem['ho'] as String);
          latinParts.add(numItem['ho_latin'] as String);
        } else {
          primaryParts.add(numItem['mundari'] as String);
          devParts.add(numItem['mundari'] as String);
          latinParts.add(numItem['mundari_latin'] as String);
        }
        i++;
        continue;
      }

      // 3f. Fallback: Phonetically transliterate to Ol Chiki for Santhali, retain Devanagari for Ho/Mundari
      if (targetLanguage == TribalLanguage.santhali) {
        final ol = devanagariToOlChiki(tokens[i]);
        primaryParts.add(ol);
        devParts.add(tokens[i]);
        latinParts.add(tokens[i]);
      } else {
        primaryParts.add(tokens[i]);
        devParts.add(tokens[i]);
        latinParts.add(tokens[i]);
      }
      i++;
    }

    stopwatch.stop();
    return TranslationResult(
      sourceText: cleanInput,
      sourceLang: 'Hindi',
      targetLang: targetLanguage.displayName,
      primaryText: primaryParts.join(' ') + (targetLanguage == TribalLanguage.santhali && punctuation == '।' ? ' ᱾' : punctuation),
      phoneticDevanagari: devParts.join(' ') + punctuation,
      latinPronunciation: latinParts.join(' ') + punctuation,
      englishMeaning: 'Classroom translation for: $cleanInput',
      visualSymbol: visualSymbol,
      latencyMs: max(4, stopwatch.elapsedMilliseconds),
      matchType: 'Dynamic Classroom NLP Synthesis',
    );
  }
}
