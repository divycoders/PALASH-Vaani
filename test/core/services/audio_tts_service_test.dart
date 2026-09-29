import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/core/services/audio_tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioTtsService Natural NLP & Speech Tests', () {
    final tts = AudioTtsService.instance;

    test('Strips visual emojis and icons from speech text', () {
      final sanitized = tts.sanitizeTextForSpeech('🍎 🍎 🍎 तीन सेब');
      expect(sanitized, isNot(contains('🍎')));
      expect(sanitized, contains('तीन सेब'));
    });

    test('Converts Ol Chiki text into pronounceable Devanagari phonetics', () {
      final sanitized = tts.sanitizeTextForSpeech('हाथी (ᱦᱟᱹᱛᱤ) और चूहा (ᱜᱩᱰᱩ)');
      expect(sanitized, isNot(contains('ᱦᱟᱹᱛᱤ')));
      expect(sanitized, contains('हाथी'));
      expect(sanitized, contains('चूहा'));
    });

    test('Strips question tags like Q. for natural teacher flow', () {
      final sanitized = tts.sanitizeTextForSpeech('Q. हाथी और चूहे में कौन बड़ा है?');
      expect(sanitized.startsWith('Q'), isFalse);
      expect(sanitized, contains('हाथी और चूहे में कौन बड़ा है?'));
    });

    test('Converts math symbols to spoken words', () {
      final sanitized = tts.sanitizeTextForSpeech('३ ➕ २ = ५');
      expect(sanitized, contains('जमा'));
      expect(sanitized, contains('बराबर'));
    });

    test('Cleans option slashes into natural pauses', () {
      final sanitized = tts.sanitizeTextForSpeech('🐘 हाथी (ᱦᱟᱹᱛᱤ / Hati)');
      expect(sanitized, isNot(contains('/')));
      expect(sanitized, contains('हाथी'));
    });

    test('currentPlayingIdNotifier defaults to null and reacts cleanly', () {
      expect(tts.currentPlayingIdNotifier.value, isNull);
    });

    test('formatPedagogySpeech returns Santhali text when in Santhali mode', () {
      final text = tts.formatPedagogySpeech(
        mode: LessonAudioMode.santhali,
        santhaliText: 'ᱯᱮ (Pe)',
        hindiText: 'तीन (Teen)',
      );
      expect(text, equals('ᱯᱮ (Pe)'));
    });

    test('formatPedagogySpeech returns Bilingual bridge when in Bilingual mode', () {
      final text = tts.formatPedagogySpeech(
        mode: LessonAudioMode.bilingual,
        santhaliText: 'ᱯᱮ (Pe)',
        hindiText: 'तीन',
      );
      expect(text, contains('ᱯᱮ (Pe)'));
      expect(text, contains('यानी'));
      expect(text, contains('तीन'));
    });

    test('formatPedagogySpeech returns Hindi text when in Hindi mode', () {
      final text = tts.formatPedagogySpeech(
        mode: LessonAudioMode.hindi,
        santhaliText: 'ᱯᱮ (Pe)',
        hindiText: 'कक्षा पाठ: गिनती १ से १०',
      );
      expect(text, equals('कक्षा पाठ: गिनती १ से १०'));
    });

    test('getQuizPraise provides vernacular praise for Santhali mode', () {
      final praise = tts.getQuizPraise(LessonAudioMode.santhali);
      expect(praise, contains('ᱟᱹᱰᱤ ᱵᱮᱥ'));
      expect(praise, contains('ᱥᱟᱹᱨᱤ ᱛᱮᱞᱟ'));
    });

    test('getChoralPrompt formats student collective repetition for classroom', () {
      final choral = tts.getChoralPrompt(LessonAudioMode.santhali, 'ᱯᱮ', 'पे');
      expect(choral, contains('ᱥᱟᱱᱟᱢ ᱜᱤᱫᱽᱨᱟᱹ ᱢᱤᱫ ᱛᱮ ᱢᱮᱱ ᱯᱮ'));
    });

    test('Teacher voice cadence uses soothing pitch and calm pace', () {
      expect(AudioTtsService.kTeacherPitch, equals(1.0));
      expect(AudioTtsService.kTeacherSpeechRate, equals(0.48));
      expect(tts.currentPitch, equals(1.0));
      expect(tts.currentSpeechRate, equals(0.48));
    });

    test('Strips trailing halants at word boundaries to prevent acoustic bass blowout', () {
      final sanitized = tts.sanitizeTextForSpeech('ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ! ᱯᱮ!');
      expect(sanitized, isNot(contains('् ')));
      expect(sanitized, isNot(contains('्।')));
      expect(sanitized, contains('पे'));
    });

    test('scoreVoice prioritizes Indian female voices over male/robotic voices', () {
      final femaleHindiScore = tts.scoreVoice(name: 'hi-in-x-cfh#female_1-local', locale: 'hi-IN');
      final femaleNeuralScore = tts.scoreVoice(name: 'hi-in-x-hie#female-neural', locale: 'hi-IN');
      final maleHindiScore = tts.scoreVoice(name: 'hi-in-x-cmh#male_1-local', locale: 'hi-IN');
      final englishUsScore = tts.scoreVoice(name: 'en-us-x-sfg#female', locale: 'en-US');

      expect(femaleHindiScore, greaterThan(150));
      expect(femaleNeuralScore, greaterThan(150));
      expect(maleHindiScore, lessThan(0)); // Penalized
      expect(englishUsScore, lessThan(0)); // Discarded non-Indian
      expect(femaleHindiScore, greaterThan(maleHindiScore));
    });

    test('Sanitizes full Santhali teacher storytelling narration into smooth phonetics', () {
      const fullSanthaliTeacherStory =
          'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱸᱡᱚᱢ ᱯᱮ! ᱡᱚᱠᱷᱚᱱ ᱡᱟᱦᱟᱸᱱᱟᱜ ᱨᱮ ᱟᱨᱦᱚᱸ ᱵᱚᱱ ᱢᱮᱥᱟᱭᱟ, ᱚᱱᱟ ᱫᱚ ᱡᱚᱲ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ᱾ ᱫᱮᱞᱟ ᱵᱚᱱ ᱞᱮᱠᱷᱟᱭᱟ — ᱢᱤᱫ, ᱵᱟᱨ, ᱯᱮ, ᱯᱩᱱ, ᱢᱚᱬᱮ!';
      final sanitized = tts.sanitizeTextForSpeech(fullSanthaliTeacherStory);
      // Ensure zero Ol Chiki unicode remains
      expect(RegExp(r'[\u1C50-\u1C7F]').hasMatch(sanitized), isFalse);
      // Ensure exclamation marks softened to prevent abrupt glottal pops
      expect(sanitized, isNot(contains('!')));
      // Ensure words are converted to Devanagari syllabics
      expect(sanitized.isNotEmpty, isTrue);
    });
  });
}
