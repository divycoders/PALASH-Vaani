import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/audio_tts_service.dart';
import '../../../../core/services/speech_recognition_service.dart';
import '../../../../core/services/translation_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController =
      TextEditingController(text: 'नमस्ते बच्चों, अपनी किताब खोलो');
  TribalLanguage _selectedTribalLanguage = TribalLanguage.santhali;
  bool _isHindiToTribal = true;

  TranslationResult? _currentResult;
  TranslationResult? _santhaliResult;
  TranslationResult? _hoResult;
  TranslationResult? _mundariResult;

  // Real-time microphone listening state
  bool _isListening = false;
  String _liveSpeechStatus = '';
  String _pedagogyCategory = 'commands';
  bool _isSlowCadence = false;

  @override
  void initState() {
    super.initState();
    _translate();
  }

  void _swapLanguages() {
    setState(() {
      _isHindiToTribal = !_isHindiToTribal;
      if (_currentResult != null && _currentResult!.primaryText.isNotEmpty) {
        _inputController.text = _currentResult!.primaryText;
      }
    });
    _translate();
  }

  void _translate() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _currentResult = null;
        _santhaliResult = null;
        _hoResult = null;
        _mundariResult = null;
      });
      return;
    }

    if (_isHindiToTribal) {
      final sRes = TranslationEngine.instance.translateHindiToTribal(
        text,
        targetLanguage: TribalLanguage.santhali,
      );
      final hRes = TranslationEngine.instance.translateHindiToTribal(
        text,
        targetLanguage: TribalLanguage.ho,
      );
      final mRes = TranslationEngine.instance.translateHindiToTribal(
        text,
        targetLanguage: TribalLanguage.mundari,
      );

      TranslationResult primary;
      switch (_selectedTribalLanguage) {
        case TribalLanguage.santhali:
          primary = sRes;
          break;
        case TribalLanguage.ho:
          primary = hRes;
          break;
        case TribalLanguage.mundari:
          primary = mRes;
          break;
      }

      setState(() {
        _santhaliResult = sRes;
        _hoResult = hRes;
        _mundariResult = mRes;
        _currentResult = primary;
      });
    } else {
      final res = TranslationEngine.instance.translateTribalToHindi(
        text,
        sourceLanguage: _selectedTribalLanguage,
      );
      setState(() {
        _currentResult = res;
        _santhaliResult = null;
        _hoResult = null;
        _mundariResult = null;
      });
    }
  }

  Future<void> _playAudio({String? textOverride, bool slow = false}) async {
    if (_currentResult == null && textOverride == null) return;

    if (slow) {
      AudioTtsService.instance.setCadence(speechRate: 0.35);
    } else {
      AudioTtsService.instance.setCadence(speechRate: 0.48);
    }

    if (textOverride != null) {
      await AudioTtsService.instance.speak(textOverride, languageCode: 'hi-IN');
      return;
    }

    if (_isHindiToTribal) {
      final textToSpeak = _currentResult!.phoneticDevanagari.isNotEmpty
          ? _currentResult!.phoneticDevanagari
          : _currentResult!.latinPronunciation;
      await AudioTtsService.instance.speak(textToSpeak, languageCode: 'hi-IN');
    } else {
      await AudioTtsService.instance.speak(_currentResult!.primaryText, languageCode: 'hi-IN');
    }
  }

  Future<void> _playTeacherExplanation() async {
    if (_currentResult == null) return;
    final tribalPhonetic = _currentResult!.phoneticDevanagari.isNotEmpty
        ? _currentResult!.phoneticDevanagari
        : _currentResult!.latinPronunciation;
    final teacherScript =
        'प्यारे बच्चों, इसे ${_selectedTribalLanguage.displayName} में कहते हैं $tribalPhonetic, और हिंदी में ${_inputController.text.trim()}।';
    await AudioTtsService.instance.speak(teacherScript, languageCode: 'hi-IN');
  }

  Future<void> _practiceRepeat() async {
    await _playAudio(slow: _isSlowCadence);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.stars_rounded, color: Colors.amber, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '🌟 बहुत अच्छा! सब बच्चे शिक्षक के साथ एक स्वर में बोलें (Repeat Together!)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Real-Time Microphone Listener
  Future<void> _toggleMicInput() async {
    if (_isListening) {
      await SpeechRecognitionService.instance.stopListening();
      setState(() {
        _isListening = false;
        _liveSpeechStatus = '';
      });
      if (_inputController.text.trim().isNotEmpty) {
        await _playAudio();
      }
    } else {
      final available = await SpeechRecognitionService.instance.initialize();
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('माइक उपलब्ध नहीं है (Microphone unavailable). कृपया नीचे टाइप करके अनुवाद करें।'),
            backgroundColor: AppColors.secondary,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _liveSpeechStatus = 'माइक सक्रिय नहीं हो सका • नीचे टाइप करके अनुवाद करें';
        });
        return;
      }

      setState(() {
        _isListening = true;
        _liveSpeechStatus = '🎙️ माइक सुन रहा है... आप बोलिए (Listening...)';
      });

      await SpeechRecognitionService.instance.startListening(
        languageCode: _isHindiToTribal ? 'hi_IN' : 'en_IN',
        onResult: (words) {
          if (!mounted) return;
          setState(() {
            _inputController.text = words;
            _liveSpeechStatus = 'पहचाना: "$words"';
          });
          _translate();
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening' || status == 'done') {
            setState(() {
              _isListening = false;
            });
            if (_inputController.text.trim().isNotEmpty) {
              _playAudio();
            }
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            final errStr = error.toLowerCase();
            if (errStr.contains('language_unavailable') ||
                errStr.contains('network') ||
                errStr.contains('server')) {
              _liveSpeechStatus =
                  '⚠️ ऑफ़लाइन माइक: Android OS में Hindi वॉइस पैक चाहिए (Settings > Voice Typing > Offline Speech) • नीचे त्वरित वाक्य दबाएं या टाइप करें';
            } else {
              _liveSpeechStatus = 'माइक में आवाज़ नहीं मिली • कृपया दोबारा बोलें या नीचे त्वरित वाक्य चुनें';
            }
          });
        },
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _inputController.text = data.text!.trim();
      });
      _translate();
    }
  }

  String _getDisplayBadgeLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'ऑफ़लाइन';
    if (raw.toLowerCase().contains('intent')) return 'सत्यापित';
    if (raw.toLowerCase().contains('vocab')) return 'शब्दावली';
    return 'ऑफ़लाइन';
  }

  void _showBlackboardModal(BuildContext context) {
    if (_currentResult == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1E1B), // Deep chalkboard green
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tv_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'ब्लैकबोर्ड दृश्य (Classroom Presentation)',
                          style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Spacer(),
              // Big Emblem
              Text(
                _currentResult?.visualSymbol ?? '🌟',
                style: const TextStyle(fontSize: 68),
              ),
              const SizedBox(height: AppSpacing.md),
              // Big Devanagari Pronunciation Guide
              Text(
                _currentResult?.phoneticDevanagari.isNotEmpty == true
                    ? _currentResult!.phoneticDevanagari
                    : (_currentResult?.primaryText ?? ''),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Script Text
              Text(
                _currentResult?.primaryText ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Source Hindi Meaning
              Text(
                'हिंदी: ${_inputController.text.trim()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              if (_currentResult?.englishMeaning.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  'English: ${_currentResult!.englishMeaning}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const Spacer(),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.volume_up, size: 24),
                    label: const Text('उच्चारण सुनाएँ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () => _playAudio(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.psychology_alt_outlined, color: Colors.amber, size: 22),
                    label: const Text('व्याख्या', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () => _playTeacherExplanation(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (_isListening) {
      SpeechRecognitionService.instance.stopListening();
    }
    _inputController.dispose();
    super.dispose();
  }

  Widget _buildQuickVoiceChip(String text, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        avatar: const Icon(Icons.volume_up_rounded, size: 13, color: AppColors.primary),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        onPressed: () {
          setState(() {
            _inputController.text = text;
            _liveSpeechStatus = '🗣️ ऑफ़लाइन वाक्य: "$text"';
          });
          _translate();
          _playAudio();
        },
      ),
    );
  }

  List<Map<String, String>> _getPedagogyItems() {
    switch (_pedagogyCategory) {
      case 'commands':
        return [
          {'title': '📖 किताब खोलो', 'text': 'अपनी किताब खोलो'},
          {'title': '🤫 शांत रहो', 'text': 'सब शांत हो जाओ'},
          {'title': '👏 ताली बजाओ', 'text': 'सब बच्चे ताली बजाओ'},
          {'title': '✍️ स्लेट पर लिखो', 'text': 'अपनी स्लेट पर लिखो'},
          {'title': '🗣️ मेरे बाद दोहराओ', 'text': 'मेरे बाद दोहराओ'},
          {'title': '🧍 खड़े हो जाओ', 'text': 'खड़े हो जाओ'},
          {'title': '🪑 बैठ जाओ', 'text': 'बैठ जाओ'},
          {'title': '👉 यहाँ देखो', 'text': 'यहाँ देखो'},
        ];
      case 'numbers':
        return [
          {'title': '१ - एक', 'text': 'एक'},
          {'title': '२ - दो', 'text': 'दो'},
          {'title': '३ - तीन', 'text': 'तीन'},
          {'title': '४ - चार', 'text': 'चार'},
          {'title': '५ - पाँच', 'text': 'पाँच'},
          {'title': '१० - दस', 'text': 'दस'},
          {'title': '१५ - पंद्रह', 'text': 'पंद्रह'},
          {'title': '२० - बीस', 'text': 'बीस'},
        ];
      case 'nature':
        return [
          {'title': '🌳 पेड़', 'text': 'पेड़'},
          {'title': '💧 पानी', 'text': 'पानी'},
          {'title': '🌸 फूल', 'text': 'फूल'},
          {'title': '☀️ सूरज', 'text': 'सूरज'},
          {'title': '🐄 गाय', 'text': 'गाय'},
          {'title': '🐦 चिड़िया', 'text': 'चिड़िया'},
          {'title': '🌿 पत्ता', 'text': 'पत्ता'},
          {'title': '☁️ बादल', 'text': 'बादल'},
        ];
      case 'food':
        return [
          {'title': '🍚 भात / चावल', 'text': 'भात'},
          {'title': '🫓 रोटी', 'text': 'रोटी'},
          {'title': '🍲 दाल', 'text': 'दाल'},
          {'title': '🍎 फल', 'text': 'फल'},
          {'title': '🥛 दूध', 'text': 'दूध'},
          {'title': '🧂 नमक', 'text': 'नमक'},
          {'title': '💧 पानी पी लो', 'text': 'पानी पी लो'},
        ];
      case 'greetings':
        return [
          {'title': '🙏 नमस्ते बच्चों', 'text': 'नमस्ते बच्चों'},
          {'title': '😊 आप सब कैसे हैं?', 'text': 'आप सब कैसे हैं?'},
          {'title': '😃 हम सब अच्छे हैं', 'text': 'हम सब अच्छे हैं'},
          {'title': '🌟 शाबाश / बहुत अच्छा', 'text': 'बहुत अच्छा'},
          {'title': '💪 फिर कोशिश करो', 'text': 'फिर से कोशिश करो'},
          {'title': '✨ धन्यवाद', 'text': 'धन्यवाद'},
        ];
      case 'health':
        return [
          {'title': '🧼 हाथ धो लो', 'text': 'हाथ धो लो'},
          {'title': '🩹 पेट में दर्द है', 'text': 'मेरे पेट में दर्द हो रहा है'},
          {'title': '🤒 बुखार है', 'text': 'मुझे बुखार है'},
          {'title': '🏠 घर जाना है', 'text': 'मुझे घर जाना है'},
          {'title': '⚠️ चोट लग गई', 'text': 'मुझे चोट लग गई'},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceName = _isHindiToTribal ? 'Hindi (हिंदी)' : _selectedTribalLanguage.nativeLabel;
    final targetName = _isHindiToTribal ? _selectedTribalLanguage.nativeLabel : 'Hindi (हिंदी)';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Language Direction & Dialect Switcher Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _isHindiToTribal ? AppColors.primaryContainer.withValues(alpha: 0.4) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sourceName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: _isHindiToTribal ? AppColors.primaryDark : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 24),
                        tooltip: 'दिशा बदलें (Swap Languages)',
                        onPressed: _swapLanguages,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: !_isHindiToTribal ? AppColors.primaryContainer.withValues(alpha: 0.4) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          targetName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: !_isHindiToTribal ? AppColors.primaryDark : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                // Dialect Selector Pill Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.translate_rounded, size: 14, color: AppColors.textMuted),
                        SizedBox(width: 4),
                        Text('लक्ष्य बोली: ', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                    Flexible(
                      child: DropdownButton<TribalLanguage>(
                        value: _selectedTribalLanguage,
                        isDense: true,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: TribalLanguage.values.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(
                              lang.displayName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (lang) {
                          if (lang != null) {
                            setState(() => _selectedTribalLanguage = lang);
                            _translate();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 2. Offline Pedagogy Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.offline_bolt_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% ऑफ़लाइन जनजातीय अनुवादक',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'NEP 2020 प्राथमिक बहुभाषी शिक्षण (MTB-MLE)',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusBadge.offline(),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 3. Smart Source Input Box
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'इनपुट ($sourceName)',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: _pasteFromClipboard,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.paste_rounded, size: 13, color: AppColors.primary),
                                SizedBox(width: 3),
                                Text('पेस्ट', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                        if (_inputController.text.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              _inputController.clear();
                              _translate();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text('साफ़ करें', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Real-time speech status alert
                if (_isListening || _liveSpeechStatus.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _liveSpeechStatus.isNotEmpty ? _liveSpeechStatus : '🔴 माइक सुन रहा है... आप बोलिए (Listening...)',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                TextField(
                  controller: _inputController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'यहाँ टाइप करें या नीचे माइक दबाकर बोलें...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  onChanged: (_) => _translate(),
                ),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    // Mic button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red : AppColors.primaryContainer,
                        foregroundColor: _isListening ? Colors.white : AppColors.primaryDark,
                        elevation: _isListening ? 4 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: Icon(_isListening ? Icons.stop_circle : Icons.mic, size: 18),
                      label: Text(
                        _isListening ? 'रोकें (Stop)' : 'माइक में बोलें',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      onPressed: _toggleMicInput,
                    ),

                    AppButton(
                      label: 'अनुवाद करें',
                      icon: Icons.translate,
                      variant: AppButtonVariant.primary,
                      onPressed: _translate,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'त्वरित बोलें: ',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      _buildQuickVoiceChip('अपनी किताब खोलो', 'किताब खोलो'),
                      _buildQuickVoiceChip('सब शांत हो जाओ', 'शांत रहो'),
                      _buildQuickVoiceChip('बैठ जाओ', 'बैठ जाओ'),
                      _buildQuickVoiceChip('हाथ धो लो', 'हाथ धो लो'),
                      _buildQuickVoiceChip('पानी पी लो', 'पानी पी लो'),
                      _buildQuickVoiceChip('open your book', 'Open Book'),
                      _buildQuickVoiceChip('sit down', 'Sit Down'),
                      _buildQuickVoiceChip('pani pina hai', 'Pani Pina Hai'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 4. Primary Output Translation Card
          AppCard(
            backgroundColor: Colors.white,
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _currentResult?.visualSymbol ?? '🌟',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'अनुवाद ($targetName)',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          Text(
                            'मातृभाषा में प्राथमिक शिक्षण',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: _getDisplayBadgeLabel(_currentResult?.matchType),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Translation Display Area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Primary Script
                      Text(
                        _currentResult?.primaryText.isEmpty ?? true
                            ? 'अनुवाद यहाँ दिखेगा (Translation will appear here)...'
                            : _currentResult!.primaryText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _currentResult == null ? AppColors.textMuted : AppColors.primaryDark,
                          height: 1.25,
                        ),
                      ),

                      // Teacher's Devanagari Pronunciation Guide (CRITICAL FOR NON-TRIBAL TEACHERS!)
                      if (_isHindiToTribal &&
                          _currentResult != null &&
                          _currentResult!.phoneticDevanagari.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.record_voice_over_rounded, size: 20, color: Colors.brown),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'शिक्षक उच्चारण (बोलो ऐसे): ${_currentResult!.phoneticDevanagari}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Latin Pronunciation
                      if (_currentResult != null && _currentResult!.latinPronunciation.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Latin: ${_currentResult!.latinPronunciation}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ],

                      // English Meaning
                      if (_currentResult != null && _currentResult!.englishMeaning.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'English: ${_currentResult!.englishMeaning}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Interactive Action Toolbar
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Voice audio button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                      label: const Text('उच्चारण सुनें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: _currentResult == null ? null : () => _playAudio(slow: _isSlowCadence),
                    ),

                    // Slow speech toggle button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isSlowCadence ? AppColors.primaryDark : AppColors.textSecondary,
                        backgroundColor: _isSlowCadence ? AppColors.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
                        side: BorderSide(color: _isSlowCadence ? AppColors.primary : Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(_isSlowCadence ? Icons.speed : Icons.slow_motion_video_rounded, size: 16),
                      label: Text(_isSlowCadence ? '0.8x धीमा' : 'सामान्य गति', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() => _isSlowCadence = !_isSlowCadence);
                        _playAudio(slow: _isSlowCadence);
                      },
                    ),

                    // Teacher Explanation
                    TextButton.icon(
                      icon: const Icon(Icons.psychology_alt_outlined, size: 18, color: AppColors.primary),
                      label: const Text('व्याख्या', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: _currentResult == null ? null : _playTeacherExplanation,
                    ),

                    // Repeat with kids
                    TextButton.icon(
                      icon: const Icon(Icons.replay_rounded, size: 18, color: AppColors.secondary),
                      label: const Text('दोहराएँ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: _currentResult == null ? null : _practiceRepeat,
                    ),

                    // Blackboard modal
                    IconButton(
                      icon: const Icon(Icons.tv_rounded, size: 20, color: AppColors.primary),
                      tooltip: 'ब्लैकबोर्ड दृश्य (Face to Face)',
                      onPressed: _currentResult == null ? null : () => _showBlackboardModal(context),
                    ),

                    // Copy to clipboard
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'कॉपी करें (Copy text)',
                      onPressed: _currentResult == null
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: _currentResult!.primaryText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('अनुवाद कॉपी हो गया (Copied)'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 5. Simultaneous Tri-Dialect Comparison Studio (Only in Hindi -> Tribal mode)
          if (_isHindiToTribal && _santhaliResult != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              backgroundColor: const Color(0xFFF1F5F9),
              borderColor: Colors.blueGrey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.compare_arrows_rounded, color: AppColors.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'झारखंड त्रि-भाषा तुलना (Tri-Dialect Studio)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('3 Dialects', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'एक ही वाक्य को तीनों प्रमुख जनजातीय बोलियों में देखें और सुनें:',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Santhali Row
                  _buildDialectRow(
                    name: 'ᱥᱟᱱᱛᱟᱲᱤ (Santhali)',
                    scriptText: _santhaliResult!.primaryText,
                    devanagariPhonetic: _santhaliResult!.phoneticDevanagari,
                    latin: _santhaliResult!.latinPronunciation,
                    accentColor: AppColors.primary,
                    onPlay: () => _playAudio(
                      textOverride: _santhaliResult!.phoneticDevanagari.isNotEmpty
                          ? _santhaliResult!.phoneticDevanagari
                          : _santhaliResult!.latinPronunciation,
                    ),
                  ),

                  const Divider(height: 16),

                  // Ho Row
                  _buildDialectRow(
                    name: 'हो (Ho)',
                    scriptText: _hoResult?.primaryText ?? '',
                    devanagariPhonetic: _hoResult?.phoneticDevanagari ?? '',
                    latin: _hoResult?.latinPronunciation ?? '',
                    accentColor: Colors.deepOrange,
                    onPlay: () => _playAudio(
                      textOverride: _hoResult?.phoneticDevanagari.isNotEmpty == true
                          ? _hoResult!.phoneticDevanagari
                          : _hoResult?.primaryText,
                    ),
                  ),

                  const Divider(height: 16),

                  // Mundari Row
                  _buildDialectRow(
                    name: 'मुंडारी (Mundari)',
                    scriptText: _mundariResult?.primaryText ?? '',
                    devanagariPhonetic: _mundariResult?.phoneticDevanagari ?? '',
                    latin: _mundariResult?.latinPronunciation ?? '',
                    accentColor: Colors.teal,
                    onPlay: () => _playAudio(
                      textOverride: _mundariResult?.phoneticDevanagari.isNotEmpty == true
                          ? _mundariResult!.phoneticDevanagari
                          : _mundariResult?.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // 6. Primary School Pedagogy Explorer (कक्षा के दैनिक विषय)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '🎒 प्राथमिक कक्षा शब्दावली (FLN Explorer)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const StatusBadge(label: 'त्वरित अभ्यास', color: AppColors.tagLanguage),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'किसी भी विषय पर टैप करें — वाक्य सीधे अनुवादित होगा और उच्चारण सुनाई देगा।',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Pedagogy Category Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('commands', '🏫 कक्षा निर्देश'),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryChip('numbers', '🔢 FLN गिनती (1-20)'),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryChip('nature', '🌳 प्रकृति व पशु'),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryChip('food', '🍱 भोजन व MDM'),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryChip('greetings', '🤝 अभिवादन व आदर'),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryChip('health', '🚨 स्वास्थ्य व स्वच्छता'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Quick Topic Chips
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _getPedagogyItems().map((item) {
              return ActionChip(
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                label: Text(
                  item['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                onPressed: () {
                  setState(() {
                    _inputController.text = item['text']!;
                  });
                  _translate();
                  _playAudio(slow: _isSlowCadence);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label) {
    final isSelected = _pedagogyCategory == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      onSelected: (val) {
        if (val) setState(() => _pedagogyCategory = key);
      },
    );
  }

  Widget _buildDialectRow({
    required String name,
    required String scriptText,
    required String devanagariPhonetic,
    required String latin,
    required Color accentColor,
    required VoidCallback onPlay,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 85,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            name,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                devanagariPhonetic.isNotEmpty ? devanagariPhonetic : scriptText,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              if (scriptText != devanagariPhonetic && scriptText.isNotEmpty)
                Text(
                  '$scriptText ($latin)',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.volume_up_rounded, size: 20, color: accentColor),
          tooltip: 'उच्चारण सुनें',
          onPressed: onPlay,
        ),
      ],
    );
  }
}
