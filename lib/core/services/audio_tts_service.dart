import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'translation_engine.dart';

/// Audio language mode for MTB-MLE classroom lessons
enum LessonAudioMode {
  /// Pure Santhali (student mother tongue) - Recommended & Default
  santhali,

  /// Dual-language bridge: speaks Santhali first, followed by Hindi meaning
  bilingual,

  /// Pure Hindi pedagogical guidance for non-tribal teacher
  hindi,
}

class AudioTtsService {
  static final AudioTtsService instance = AudioTtsService._init();
  AudioTtsService._init();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isPlaying = false;

  Map<String, String>? _selectedVoice;
  String _activeVoiceName = 'दीदी (सौम्य भारतीय आवाज़)';
  
  // Pure natural frequency without TD-PSOLA DSP pitch-shift bass distortion
  static const double kTeacherPitch = 1.0;
  // Calm, rhythmic primary teacher cadence
  static const double kTeacherSpeechRate = 0.48;
  // Safe volume (0.80 gives -2dB headroom, preventing DAC clipping and initial AGC limiter pumping)
  static const double kSafeVolume = 0.80;

  double _pitch = kTeacherPitch;
  double _speechRate = kTeacherSpeechRate;

  bool _voiceConfigured = false;
  double _appliedPitch = -1.0;
  double _appliedSpeechRate = -1.0;
  double _appliedVolume = -1.0;

  String get activeVoiceLabel => _activeVoiceName;
  double get currentPitch => _pitch;
  double get currentSpeechRate => _speechRate;
  Map<String, String>? get selectedVoice => _selectedVoice;

  /// Customizes pitch and speech rate for classroom environments
  void setCadence({double? pitch, double? speechRate}) {
    if (pitch != null && pitch != _pitch) {
      _pitch = pitch;
      _appliedPitch = -1.0;
    }
    if (speechRate != null && speechRate != _speechRate) {
      _speechRate = speechRate;
      _appliedSpeechRate = -1.0;
    }
  }

  /// Reactive notifier broadcasting which UI element/phrase ID is currently speaking
  final ValueNotifier<String?> currentPlayingIdNotifier = ValueNotifier<String?>(null);

  bool get isPlaying => _isPlaying;
  String? get currentPlayingId => currentPlayingIdNotifier.value;

  Future<void> _initTts() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();
      if (!kIsWeb) {
        try {
          // Explicitly request Google TTS engine if available on Android
          final dynamic engines = await _flutterTts!.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _flutterTts!.setEngine('com.google.android.tts');
          }
        } catch (e) {
          debugPrint('Engine configuration notice: $e');
        }

        // Apply clean cadence and safe volume (0.80 prevents DAC clipping / initial AGC distortion)
        await _flutterTts!.setSpeechRate(_speechRate);
        _appliedSpeechRate = _speechRate;
        await _flutterTts!.setPitch(_pitch);
        _appliedPitch = _pitch;
        await _flutterTts!.setVolume(kSafeVolume);
        _appliedVolume = kSafeVolume;

        // Auto-discover and select highest quality warm Indian female voice
        await _configureNaturalVoice();
      }

      _flutterTts!.setStartHandler(() {
        _isPlaying = true;
      });

      _flutterTts!.setCompletionHandler(() {
        _isPlaying = false;
        currentPlayingIdNotifier.value = null;
      });

      _flutterTts!.setErrorHandler((msg) {
        _isPlaying = false;
        currentPlayingIdNotifier.value = null;
        debugPrint('TTS Error: $msg');
      });

      _flutterTts!.setCancelHandler(() {
        _isPlaying = false;
        currentPlayingIdNotifier.value = null;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize FlutterTts: $e');
    }
  }

  /// Discover and select best natural Indian Female (Didi / Shikshika) voice available on device
  Future<void> _configureNaturalVoice() async {
    try {
      final dynamic voices = await _flutterTts!.getVoices;
      if (voices is List && voices.isNotEmpty) {
        Map<String, String>? bestVoice;
        int bestScore = -999;

        for (final v in voices) {
          if (v is Map) {
            final name = v['name']?.toString() ?? '';
            final locale = v['locale']?.toString() ?? '';

            int score = scoreVoice(name: name, locale: locale);
            if (score > bestScore) {
              bestScore = score;
              bestVoice = {
                'name': name,
                'locale': locale.isNotEmpty ? locale : 'hi-IN',
              };
            }
          }
        }

        if (bestVoice != null && bestScore > 0) {
          _selectedVoice = bestVoice;
          _activeVoiceName = 'दीदी (सौम्य भारतीय आवाज़)';
          await _flutterTts!.setVoice(bestVoice);
          _voiceConfigured = true;
          debugPrint('TTS Selected Indian Female Voice: ${bestVoice['name']} (score: $bestScore)');
        }
      }
    } catch (e) {
      debugPrint('Voice auto-configuration notice: $e');
    }
  }

  /// Evaluates and scores TTS voices to guarantee a warm, soothing Indian Female voice
  int scoreVoice({required String name, required String locale}) {
    final lowerName = name.toLowerCase();
    final lowerLocale = locale.toLowerCase();

    final isHindi = lowerLocale.contains('hi');
    final isIndian = lowerLocale.contains('in') || lowerLocale.contains('ind');
    if (!isHindi && !isIndian) return -100;

    int score = 0;
    if (isHindi) score += 60;
    if (isIndian) score += 20;

    // Detect female markers first
    final isExplicitFemale = lowerName.contains('female') ||
        lowerName.contains('woman') ||
        lowerName.contains('girl');

    // HEAVILY PENALIZE MALE VOICES (completely eliminates harsh/deep/robotic tones)
    // Avoid false positives where "female" contains "male" or "woman" contains "man"
    final isMale = !isExplicitFemale &&
        (lowerName.contains('male') ||
            lowerName.contains('man') ||
            lowerName.contains('boy') ||
            lowerName.contains('-cm') ||
            lowerName.contains('-dm') ||
            lowerName.contains('#male'));

    if (isMale) {
      return -100;
    }

    // HIGHLY REWARD EXPLICIT FEMALE MARKERS
    if (isExplicitFemale) {
      score += 100;
    }

    // Google TTS Hindi Female Voice models:
    // cfh = compact female high, cfl = compact female low, dfe = neural female
    if (lowerName.contains('cfh') ||
        lowerName.contains('cfl') ||
        lowerName.contains('dfe') ||
        lowerName.contains('dfh')) {
      score += 90;
    }

    // Indian persona codenames known to be soft female educators
    if (lowerName.contains('hie') ||
        lowerName.contains('hia') ||
        lowerName.contains('swara') ||
        lowerName.contains('zira') ||
        lowerName.contains('ananya') ||
        lowerName.contains('aditi')) {
      score += 70;
    }

    // Neural / High Quality / Natural models
    if (lowerName.contains('neural') ||
        lowerName.contains('wavenet') ||
        lowerName.contains('natural')) {
      score += 30;
    }

    return score;
  }

  /// Cleans raw lesson/quiz text into natural, fluent spoken phonetics:
  /// 1. Transliterates any Ol Chiki characters into Devanagari phonetics
  /// 2. Strips visual emojis (🍎, 🐘, 🐭, ⚖️, 🔟, etc.) so TTS doesn't read symbol names
  /// 3. Cleans question tags (Q., 1., 2.) and brackets into natural commas
  /// 4. Converts mathematical operators into conversational words
  String sanitizeTextForSpeech(String rawText) {
    if (rawText.trim().isEmpty) return '';

    String text = rawText;

    // 1. Conversational mathematical symbols (convert before emoji stripping)
    text = text.replaceAll('➕', ' जमा ');
    text = text.replaceAll('➖', ' घटाव ');
    text = text.replaceAll('✖️', ' गुणा ');
    text = text.replaceAll('=', ' बराबर ');

    // 2. Convert Ol Chiki segments into Devanagari phonetics
    final olChikiRegex = RegExp(r'[\u1C50-\u1C7F]+');
    text = text.replaceAllMapped(olChikiRegex, (match) {
      final olChikiChunk = match.group(0)!;
      return ' ${TranslationEngine.instance.olChikiToDevanagari(olChikiChunk)} ';
    });

    // 2b. Strip any word-boundary halants (eliminates abrupt glottal acoustic pop / bass blowout at end of words)
    text = text.replaceAll(RegExp(r'्(?=\s|$|[।,\.!?\(\)\-])'), '');

    // 2c. Soften exclamation marks into periods (prevents punchy glottal stops at sentence endings)
    text = text.replaceAll('!', '। ');

    // 3. Remove emojis and visual icons
    text = text.replaceAll(
      RegExp(
        r'[\u{10000}-\u{10FFFF}]|[\u200D\uFE0F\u200B\u200E\u200F]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50]',
        unicode: true,
      ),
      '',
    );

    // 4. Clean quiz prefixes like "Q. ", "Q ", "1. ", "१. "
    text = text.replaceFirst(RegExp(r'^(Q\s*\.?\s*|[०-९0-9]+[\.\)]\s*)', caseSensitive: false), '');

    // 5. Clean brackets and slashes for natural pauses
    text = text.replaceAll('/', ' या ');
    text = text.replaceAll('(', ', ');
    text = text.replaceAll(')', ', ');
    text = text.replaceAll('•', ', ');
    text = text.replaceAll('➔', ' ');
    text = text.replaceAll('→', ' ');
    text = text.replaceAll('✓', ' ');
    text = text.replaceAll('⭐', ' ');
    text = text.replaceAll('🎯', ' ');
    text = text.replaceAll('🎉', ' ');

    // 6. Clean extra spaces and punctuation duplicates
    text = text.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'[,]{2,}'), ',').trim();

    return text;
  }

  /// Speak cleaned text with playing ID tracking.
  /// If [id] is already speaking, tapping again immediately stops it (toggle behavior).
  Future<void> speakClean(
    String rawText, {
    String? id,
    String languageCode = 'hi-IN',
  }) async {
    // If the same item is currently speaking, stop it immediately
    if (_isPlaying && id != null && currentPlayingId == id) {
      await stop();
      return;
    }

    try {
      if (_isPlaying) {
        await stop();
        // Give native Android AudioTrack and LocalSynthesizer 80ms to cleanly drain/flush
        await Future.delayed(const Duration(milliseconds: 80));
      } else {
        // Subtle 30ms settling buffer to prevent binder collision
        await Future.delayed(const Duration(milliseconds: 30));
      }

      await _initTts();

      final cleanText = sanitizeTextForSpeech(rawText);
      if (cleanText.isEmpty) {
        currentPlayingIdNotifier.value = null;
        return;
      }

      currentPlayingIdNotifier.value = id;

      if (_flutterTts != null) {
        // Only apply voice if not yet configured or if language changed
        if (!_voiceConfigured) {
          if (_selectedVoice != null) {
            await _flutterTts!.setVoice(_selectedVoice!);
          } else {
            await _flutterTts!.setLanguage(languageCode);
          }
          _voiceConfigured = true;
        }

        // Only re-apply parameters if changed (prevents resetting synthesis DSP mid-buffer)
        if (_appliedPitch != _pitch) {
          await _flutterTts!.setPitch(_pitch);
          _appliedPitch = _pitch;
        }
        if (_appliedSpeechRate != _speechRate) {
          await _flutterTts!.setSpeechRate(_speechRate);
          _appliedSpeechRate = _speechRate;
        }
        if (_appliedVolume != kSafeVolume) {
          await _flutterTts!.setVolume(kSafeVolume);
          _appliedVolume = kSafeVolume;
        }

        // Prepend an acoustic breath pause (', ') so the Android DAC and AudioTrack mixer
        // ramp up smoothly during 120ms of silence before phonation begins.
        // This eliminates the abrupt plosive pop/burst on the first consonant ('प').
        final speechPayload = ', $cleanText';

        await _flutterTts!.speak(speechPayload);
      }
    } catch (e) {
      debugPrint('Error during speakClean: $e');
      _isPlaying = false;
      currentPlayingIdNotifier.value = null;
    }
  }

  /// Plays a warm, welcoming teacher greeting to preview and verify voice quality
  Future<void> previewTeacherVoice() async {
    await speakClean(
      'नमस्ते बच्चों! आज हम सब मिलकर मजे से सीखेंगे।',
      id: 'preview_voice',
    );
  }

  /// Legacy / direct speak method (also cleans text and tracks ID)
  Future<void> speak(
    String text, {
    String? id,
    String languageCode = 'hi-IN',
  }) async {
    await speakClean(text, id: id, languageCode: languageCode);
  }

  /// Stop any ongoing speech and reset playing ID
  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    } finally {
      _isPlaying = false;
      currentPlayingIdNotifier.value = null;
    }
  }

  /// Formats speech text according to the selected classroom [LessonAudioMode]
  String formatPedagogySpeech({
    required LessonAudioMode mode,
    required String santhaliText,
    required String hindiText,
    String? dualBridge,
  }) {
    switch (mode) {
      case LessonAudioMode.santhali:
        return santhaliText.isNotEmpty ? santhaliText : hindiText;
      case LessonAudioMode.hindi:
        return hindiText.isNotEmpty ? hindiText : santhaliText;
      case LessonAudioMode.bilingual:
        if (dualBridge != null && dualBridge.isNotEmpty) {
          return dualBridge;
        }
        if (santhaliText.isNotEmpty && hindiText.isNotEmpty && santhaliText.trim() != hindiText.trim()) {
          return '$santhaliText , यानी , $hindiText';
        }
        return santhaliText.isNotEmpty ? santhaliText : hindiText;
    }
  }

  /// Returns encouraging praise text for children according to [mode]
  String getQuizPraise(LessonAudioMode mode) {
    switch (mode) {
      case LessonAudioMode.santhali:
        return 'ᱟᱹᱰᱤ ᱵᱮᱥ! ᱥᱟᱹᱨᱤ ᱛᱮᱞᱟ! ᱟᱹᱰᱤ ᱱᱟᱯᱟᱭ! (Adi bes! Sari tela! Shaabaash!)';
      case LessonAudioMode.bilingual:
        return 'ᱟᱹᱰᱤ ᱵᱮᱥ! बहुत अच्छा! सही जवाब! शाबाश!';
      case LessonAudioMode.hindi:
        return 'बहुत अच्छा! सही जवाब! शाबाश!';
    }
  }

  /// Returns classroom choral repetition prompt for [mode]
  String getChoralPrompt(LessonAudioMode mode, String phraseSat, String phraseHi) {
    switch (mode) {
      case LessonAudioMode.santhali:
        return 'ᱥᱟᱱᱟᱢ ᱜᱤᱫᱽᱨᱟᱹ ᱢᱤᱫ ᱛᱮ ᱢᱮᱱ ᱯᱮ: $phraseSat';
      case LessonAudioMode.bilingual:
        return 'ᱥᱟᱱᱟᱢ ᱜᱤᱫᱽᱨᱟᱹ ᱢᱤᱫ ᱛᱮ ᱢᱮᱱ ᱯᱮ: $phraseSat! सब बच्चे साथ बोलें: $phraseHi!';
      case LessonAudioMode.hindi:
        return 'सब बच्चे एक साथ दोहराएँ: $phraseHi';
    }
  }
}
