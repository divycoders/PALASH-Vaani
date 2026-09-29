import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/core/services/translation_engine.dart';
import 'package:palash_vaani/core/services/tribal_lexicon_data.dart';

void main() {
  group('TranslationEngine Core Tests', () {
    final engine = TranslationEngine.instance;

    test('Translates Hindi greeting to Santhali (Ol Chiki + Devanagari phonetic guide)', () {
      final res = engine.translateHindiToTribal(
        'नमस्ते बच्चों',
        targetLanguage: TribalLanguage.santhali,
      );

      expect(res.primaryText, equals('ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ'));
      expect(res.phoneticDevanagari, contains('जोहार'));
      expect(res.latinPronunciation, contains('Johar'));
      expect(res.latencyMs, lessThan(3000));
      expect(res.isOfflineReady, isTrue);
    });

    test('Translates classroom instruction to Ho dialect', () {
      final res = engine.translateHindiToTribal(
        'अपनी किताब खोलो',
        targetLanguage: TribalLanguage.ho,
      );

      expect(res.primaryText, contains('पुथि'));
      expect(res.latinPronunciation, contains('puthi'));
      expect(res.latencyMs, lessThan(3000));
    });

    test('Translates classroom instruction to Mundari dialect', () {
      final res = engine.translateHindiToTribal(
        'अपनी किताब खोलो',
        targetLanguage: TribalLanguage.mundari,
      );

      expect(res.primaryText, contains('पुथी'));
      expect(res.latinPronunciation, contains('puthi'));
      expect(res.latencyMs, lessThan(3000));
    });

    test('Bidirectional: Translates Student tribal input back to Teacher Hindi', () {
      final res = engine.translateTribalToHindi(
        'ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ',
        sourceLanguage: TribalLanguage.santhali,
      );

      expect(res.primaryText, equals('अपनी किताब खोलो'));
      expect(res.targetLang, equals('Hindi'));
      expect(res.latencyMs, lessThan(3000));
    });

    test('Translates NIPUN Bharat Cardinal Numbers accurately', () {
      final resOne = engine.translateHindiToTribal('१', targetLanguage: TribalLanguage.santhali);
      expect(resOne.primaryText, contains('ᱢᱤᱫ'));

      final resFive = engine.translateHindiToTribal('पाँच', targetLanguage: TribalLanguage.santhali);
      expect(resFive.primaryText, contains('ᱢᱚᱬᱮ'));

      final resTen = engine.translateHindiToTribal('10', targetLanguage: TribalLanguage.santhali);
      expect(resTen.primaryText, contains('ᱜᱮᱞ'));
    });

    test('Translates NIPUN FLN vocabulary terms', () {
      final resTree = engine.translateHindiToTribal('पेड़', targetLanguage: TribalLanguage.santhali);
      expect(resTree.primaryText, equals('ᱫᱟᱨᱮ'));

      final resFlower = engine.translateHindiToTribal('फूल', targetLanguage: TribalLanguage.santhali);
      expect(resFlower.primaryText, contains('ᱵᱟᱦᱟ'));

      final resWater = engine.translateHindiToTribal('पानी', targetLanguage: TribalLanguage.santhali);
      expect(resWater.primaryText, equals('ᱫᱟᱜ'));
    });

    test('Ol Chiki transliteration utility maps to Devanagari phonetics', () {
      final dev = engine.olChikiToDevanagari('ᱡᱚᱦᱟᱨ');
      expect(dev, contains('ज'));
      expect(dev, contains('ह'));
      expect(dev, contains('र'));
    });

    test('Translates custom dynamic sentence: सभी बच्चे बाहर जाओ', () {
      final resSat = engine.translateHindiToTribal(
        'सभी बच्चे बाहर जाओ',
        targetLanguage: TribalLanguage.santhali,
      );
      expect(resSat.primaryText, contains('ᱵᱟᱦᱨᱮ'));
      expect(resSat.primaryText, contains('ᱪᱟᱞᱟᱜ'));
      expect(resSat.phoneticDevanagari, contains('बाहरे'));

      final resHo = engine.translateHindiToTribal(
        'सभी बच्चे बाहर जाओ',
        targetLanguage: TribalLanguage.ho,
      );
      expect(resHo.primaryText, contains('सोबेन'));
      expect(resHo.primaryText, contains('बाहरे'));

      final resMun = engine.translateHindiToTribal(
        'सभी बच्चे बाहर जाओ',
        targetLanguage: TribalLanguage.mundari,
      );
      expect(resMun.primaryText, contains('सोबेन'));
      expect(resMun.primaryText, contains('बाहरे'));
    });

    test('Translates dynamic classroom sentence: मैदान में खेलो', () {
      final res = engine.translateHindiToTribal(
        'मैदान में खेलो',
        targetLanguage: TribalLanguage.santhali,
      );
      expect(res.primaryText, contains('ᱴᱟᱺᱰᱤ'));
      expect(res.phoneticDevanagari, contains('तांडी'));
    });

    test('Latency SLA is strictly within 3000ms SIH constraint', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 20; i++) {
        engine.translateHindiToTribal('ध्यान से सुनो और मेरे बाद दोहराओ');
      }
      stopwatch.stop();

      // 20 translations should take under 500ms total
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Real-time English translation into Santhali (Ol Chiki + Devanagari phonetics)', () {
      // 1. English phrase
      final resBook = engine.translateHindiToTribal('open your book', targetLanguage: TribalLanguage.santhali);
      expect(resBook.primaryText, equals('ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ'));
      expect(resBook.phoneticDevanagari, contains('पुथि'));

      // 2. English routine
      final resWater = engine.translateHindiToTribal('drink water', targetLanguage: TribalLanguage.santhali);
      expect(resWater.primaryText, contains('ᱫᱟᱜ'));

      // 3. English vocabulary
      final resApple = engine.translateHindiToTribal('apple', targetLanguage: TribalLanguage.santhali);
      expect(resApple.primaryText, contains('ᱥᱮᱣ'));

      final resElephant = engine.translateHindiToTribal('elephant', targetLanguage: TribalLanguage.santhali);
      expect(resElephant.primaryText, contains('ᱦᱟᱹᱛᱤ'));

      // 4. English numbers
      final resFour = engine.translateHindiToTribal('four', targetLanguage: TribalLanguage.santhali);
      expect(resFour.primaryText, contains('ᱯᱩᱱ'));
    });

    test('Real-time Hinglish translation into Santhali, Ho, and Mundari', () {
      // 1. Hinglish phrase: "kitab kholo"
      final resHinglishBook = engine.translateHindiToTribal('kitab kholo', targetLanguage: TribalLanguage.santhali);
      expect(resHinglishBook.primaryText, equals('ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ'));
      expect(resHinglishBook.phoneticDevanagari, contains('पुथि'));

      // 2. Hinglish phrase: "baith jao"
      final resSit = engine.translateHindiToTribal('baith jao', targetLanguage: TribalLanguage.santhali);
      expect(resSit.primaryText, contains('ᱫᱩᱲᱩᱵ'));

      // 3. Hinglish routine: "pani pina hai"
      final resWaterHinglish = engine.translateHindiToTribal('pani pina hai', targetLanguage: TribalLanguage.santhali);
      expect(resWaterHinglish.primaryText, contains('ᱫᱟᱜ'));

      // 4. Hinglish vocabulary: "seb" -> Apple, "hathi" -> Elephant
      final resSeb = engine.translateHindiToTribal('seb', targetLanguage: TribalLanguage.santhali);
      expect(resSeb.primaryText, contains('ᱥᱮᱣ'));

      final resHathi = engine.translateHindiToTribal('hathi', targetLanguage: TribalLanguage.santhali);
      expect(resHathi.primaryText, contains('ᱦᱟᱹᱛᱤ'));

      // 5. Hinglish numbers: "paanch" -> 5
      final resPaanch = engine.translateHindiToTribal('paanch', targetLanguage: TribalLanguage.santhali);
      expect(resPaanch.primaryText, contains('ᱢᱚᱬᱮ'));
    });
  });

  group('TribalLexiconData Integrity Tests', () {
    test('Contains rich classroom phrases across 3 tribal languages', () {
      expect(TribalLexiconData.classroomPhrases.length, greaterThanOrEqualTo(10));
      for (final p in TribalLexiconData.classroomPhrases) {
        expect(p['santhali'], isNotNull);
        expect(p['ho'], isNotNull);
        expect(p['mundari'], isNotNull);
        expect(p['hindi'], isNotNull);
      }
    });

    test('Contains NIPUN Bharat numbers', () {
      expect(TribalLexiconData.numbers.length, greaterThanOrEqualTo(10));
    });

    test('Contains multi-category vocabulary', () {
      final categories = TribalLexiconData.vocabulary.map((v) => v['category']).toSet();
      expect(categories, contains('Animals'));
      expect(categories, contains('Nature'));
      expect(categories, contains('Classroom'));
      expect(categories, contains('Shapes'));
      expect(categories, contains('Colors'));
    });
  });
}
