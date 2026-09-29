import 'package:flutter/material.dart';
import '../../../../core/services/audio_tts_service.dart';
import '../../../../core/services/speech_recognition_service.dart';
import '../../../../core/services/translation_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  // Mode: 0 = Teacher (Hindi -> Tribal), 1 = Student (Tribal -> Hindi)
  int _selectedMode = 0;
  TribalLanguage _selectedLanguage = TribalLanguage.santhali;
  String _selectedCategory = 'all';

  final TextEditingController _inputController = TextEditingController(text: 'अपनी किताब खोलो');
  TranslationResult? _currentResult;

  bool _isListening = false;
  String _liveSpeechStatus = '';
  int _classroomStars = 0;

  final Map<String, Map<String, dynamic>> _routineCategories = {
    'all': {'label': 'सभी निर्देश', 'icon': Icons.apps},
    'morning': {'label': 'प्रार्थना व स्वागत', 'icon': Icons.wb_sunny_outlined},
    'instruction': {'label': 'पठन व निर्देश', 'icon': Icons.menu_book_outlined},
    'discipline': {'label': 'अनुशासन व खेल', 'icon': Icons.groups_outlined},
    'hygiene': {'label': 'भोजन व स्वच्छता', 'icon': Icons.clean_hands_outlined},
    'emergency': {'label': 'ज़रूरी आवश्यकताएँ', 'icon': Icons.health_and_safety_outlined},
    'praise': {'label': 'प्रशंसा व उत्साह', 'icon': Icons.celebration_outlined},
  };

  static const List<Map<String, dynamic>> _quickRoutines = [
    // Morning & Greetings
    {
      'category': 'morning',
      'emoji': '🌅',
      'hindi': 'नमस्ते बच्चों',
      'santhali_dev': 'जोहार गिद्रा',
      'santhali_ol': 'ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ',
      'latin': 'Johar gidra',
      'ho': 'जोहार होनको',
      'mundari': 'जोहार हुनको',
      'meaning_en': 'Hello children',
    },
    {
      'category': 'morning',
      'emoji': '😊',
      'hindi': 'आप सब कैसे हैं?',
      'santhali_dev': 'आपे चेद लेका मेनाग पेया?',
      'santhali_ol': 'ᱟᱯᱮ ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱜ ᱯᱮᱭᱟ?',
      'latin': 'Ape ched leka menag peya?',
      'ho': 'अपे चिलके मेनापेया?',
      'mundari': 'अपे चिलकेना मेनापेया?',
      'meaning_en': 'How are you all?',
    },
    {
      'category': 'morning',
      'emoji': '😃',
      'hindi': 'सब बच्चे मुस्कुराओ',
      'santhali_dev': 'जोतो गिद्रा लांदाय पे',
      'santhali_ol': 'ᱡᱚᱛᱚ ᱜᱤᱫᱽᱨᱟᱹ ᱞᱟᱸᱫᱟᱭ ᱯᱮ',
      'latin': 'Joto gidra landay pe',
      'ho': 'सोबेन होनको लांदाए पे',
      'mundari': 'सोबेन हुनको लांदाए पे',
      'meaning_en': 'All children smile',
    },

    // Instructions & Reading
    {
      'category': 'instruction',
      'emoji': '📖',
      'hindi': 'अपनी किताब खोलो',
      'santhali_dev': 'आमाग पुथि खुलाय मे',
      'santhali_ol': 'ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ',
      'latin': 'Amag puthi khulae me',
      'ho': 'अमाः पुथि कुलै मे',
      'mundari': 'अमाः पुथी कुलै मे',
      'meaning_en': 'Open your book',
    },
    {
      'category': 'instruction',
      'emoji': '👉',
      'hindi': 'यहाँ देखो',
      'santhali_dev': 'नोंडे ञेल मे',
      'santhali_ol': 'ᱱᱚᱸᱰᱮ ᱧᱮᱞ ᱢᱮ',
      'latin': 'Nonde nyel me',
      'ho': 'नेनपा नेल मे',
      'mundari': 'नेते नेल मे',
      'meaning_en': 'Look here',
    },
    {
      'category': 'instruction',
      'emoji': '👂',
      'hindi': 'ध्यान से सुनो',
      'santhali_dev': 'धेयान ते आंजोम मे',
      'santhali_ol': 'ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ',
      'latin': 'Dheyan te anjom me',
      'ho': 'मन लगाके आयुम मे',
      'mundari': 'सुपुई ते आयुम मे',
      'meaning_en': 'Listen carefully',
    },
    {
      'category': 'instruction',
      'emoji': '🗣️',
      'hindi': 'मेरे बाद दोहराओ',
      'santhali_dev': 'इञ तायोम रोड़ मे',
      'santhali_ol': 'ᱤᱧ ᱛᱟᱭᱚᱢ ᱨᱚᱲ ᱢᱮ',
      'latin': 'Iny tayom rod me',
      'ho': 'अयिंग तायोम काजि मे',
      'mundari': 'अयिंग तायोम जगर मे',
      'meaning_en': 'Repeat after me',
    },
    {
      'category': 'instruction',
      'emoji': '🔢',
      'hindi': 'एक साथ गिनो',
      'santhali_dev': 'मिद सावते लेखाय पे',
      'santhali_ol': 'ᱢᱤᱫ ᱥᱟᱶᱛᱮ ᱞᱮᱠᱷᱟᱭ ᱯᱮ',
      'latin': 'Mid sawte lekhay pe',
      'ho': 'मियद सांवते लेकाए पे',
      'mundari': 'मियद सोंगे लेकाए पे',
      'meaning_en': 'Count together',
    },
    {
      'category': 'instruction',
      'emoji': '✏️',
      'hindi': 'अपनी स्लेट पर लिखो',
      'santhali_dev': 'आमाग स्लेट रे ओल मे',
      'santhali_ol': 'ᱟᱢᱟᱜ ᱥᱞᱮᱴ ᱨᱮ ᱚᱞ ᱢᱮ',
      'latin': 'Amag slate re ol me',
      'ho': 'अमाः स्लेट रे ओल मे',
      'mundari': 'अमाः स्लेट रे ओल मे',
      'meaning_en': 'Write on your slate',
    },

    // Discipline & Activities
    {
      'category': 'discipline',
      'emoji': '🧍',
      'hindi': 'खड़े हो जाओ',
      'santhali_dev': 'तिंगुन मे',
      'santhali_ol': 'ᱛᱤᱸᱜᱩᱱ ᱢᱮ',
      'latin': 'Tingun me',
      'ho': 'तिंगुन मे',
      'mundari': 'तिंगुन मे',
      'meaning_en': 'Stand up',
    },
    {
      'category': 'discipline',
      'emoji': '🪑',
      'hindi': 'बैठ जाओ',
      'santhali_dev': 'दुड़ुब मे',
      'santhali_ol': 'ᱫᱩᱲᱩᱵ ᱢᱮ',
      'latin': 'Durup me',
      'ho': 'दुब मे',
      'mundari': 'दुब मे',
      'meaning_en': 'Sit down',
    },
    {
      'category': 'discipline',
      'emoji': '🤫',
      'hindi': 'सब शांत हो जाओ',
      'santhali_dev': 'जोतो होड़ थीर कोग पे',
      'santhali_ol': 'ᱡᱚᱛᱚ ᱦᱚᱲ ᱛᱷᱤᱨ ᱠᱚᱜ ᱯᱮ',
      'latin': 'Joto hor thir kog pe',
      'ho': 'सोबेन होड़ थीर लेन पे',
      'mundari': 'सोबेन होड़ थीर लेन पे',
      'meaning_en': 'Everyone be quiet',
    },
    {
      'category': 'discipline',
      'emoji': '👏',
      'hindi': 'सब बच्चे ताली बजाओ',
      'santhali_dev': 'जोतो गिद्रा थाय मे',
      'santhali_ol': 'ᱡᱚᱛᱚ ᱜᱤᱫᱽᱨᱟᱹ ᱛᱷᱟᱹᱭᱟᱹ ᱢᱮ',
      'latin': 'Joto gidra thaye me',
      'ho': 'सोबेन होनको ताली दुर मे',
      'mundari': 'सोबेन हुनको थाली साडी मे',
      'meaning_en': 'All children clap',
    },
    {
      'category': 'discipline',
      'emoji': '⚽',
      'hindi': 'चलो खेल खेलते हैं',
      'santhali_dev': 'देला बोन एनेजा',
      'santhali_ol': 'ᱫᱮᱞᱟ ᱵᱚᱱ ᱮᱱᱮᱡᱼᱟ',
      'latin': 'Dela bon eneja',
      'ho': 'दिलाबों ईनीजा',
      'mundari': 'दिलाबों ईनीजा',
      'meaning_en': 'Let us play a game',
    },
    {
      'category': 'discipline',
      'emoji': '🎵',
      'hindi': 'कविता / गाना गाओ',
      'santhali_dev': 'सेरेञ मे',
      'santhali_ol': 'ᱥᱮᱨᱮᱧ ᱢᱮ',
      'latin': 'Serenj me',
      'ho': 'दुरंग मे',
      'mundari': 'दुरंग मे',
      'meaning_en': 'Sing a song / rhyme',
    },

    // Hygiene & MDM
    {
      'category': 'hygiene',
      'emoji': '💧',
      'hindi': 'पानी पी लो',
      'santhali_dev': 'दाग ञुय मे',
      'santhali_ol': 'ᱫᱟᱜ ᱧᱩᱭ ᱢᱮ',
      'latin': 'Dag nyuy me',
      'ho': 'दाः नुई मे',
      'mundari': 'दाः नुई मे',
      'meaning_en': 'Drink water',
    },
    {
      'category': 'hygiene',
      'emoji': '🧼',
      'hindi': 'हाथ धो लो',
      'santhali_dev': 'ती आरुब मे',
      'santhali_ol': 'ᱛᱤ ᱟᱹᱨᱩᱵ ᱢᱮ',
      'latin': 'Ti arub me',
      'ho': 'ती अरुब मे',
      'mundari': 'ती अरुब मे',
      'meaning_en': 'Wash your hands',
    },
    {
      'category': 'hygiene',
      'emoji': '🍲',
      'hindi': 'खाना खा लो',
      'santhali_dev': 'दाका जोम मे',
      'santhali_ol': 'ᱫᱟᱠᱟ ᱡᱚᱢ ᱢᱮ',
      'latin': 'Daka jom me',
      'ho': 'मंडी जोम मे',
      'mundari': 'मंडी जोम मे',
      'meaning_en': 'Eat your meal',
    },

    // Emergency & Student Needs
    {
      'category': 'emergency',
      'emoji': '🩺',
      'hindi': 'मेरे पेट में दर्द हो रहा है',
      'santhali_dev': 'इंज लाच हासुईदीन काना',
      'santhali_ol': 'ᱤᱧ ᱞᱟᱪ ᱦᱟᱹᱥᱩᱭᱮᱫᱤᱧ ᱠᱟᱱᱟ',
      'latin': 'Inj lach hasuyedinj kana',
      'ho': 'अयिंग लाः हासुतानिया',
      'mundari': 'अयिंग लाः हासुतानिया',
      'meaning_en': 'My stomach is hurting',
    },
    {
      'category': 'emergency',
      'emoji': '🏠',
      'hindi': 'मुझे घर जाना है',
      'santhali_dev': 'इंज ओड़ाः चालाग सानाइँदीन काना',
      'santhali_ol': 'ᱤᱧ ᱚᱲᱟᱜ ᱪᱟᱞᱟᱜ ᱥᱟᱱᱟᱭᱤᱧ ᱠᱟᱱᱟ',
      'latin': 'Inj odag chalag sanayinj kana',
      'ho': 'अयिंग ओड़ाः सेन सानाईंग तना',
      'mundari': 'अयिंग ओड़ाः सेन सानाईंग तना',
      'meaning_en': 'I want to go home',
    },
    {
      'category': 'emergency',
      'emoji': '🚽',
      'hindi': 'मुझे बाहर / शौचालय जाना है',
      'santhali_dev': 'इंज बाहरे चालाग सानाइँदीन काना',
      'santhali_ol': 'ᱤᱧ ᱵᱟᱦᱨᱮ ᱪᱟᱞᱟᱜ ᱥᱟᱱᱟᱭᱤᱧ ᱠᱟᱱᱟ',
      'latin': 'Inj bahre chalag sanayinj kana',
      'ho': 'अयिंग बाहरे सेन सानाईंग तना',
      'mundari': 'अयिंग बाहरे सेन सानाईंग तना',
      'meaning_en': 'I need to go outside / restroom',
    },
    {
      'category': 'emergency',
      'emoji': '📖',
      'hindi': 'मेरे पास किताब नहीं है',
      'santhali_dev': 'इंज ठेन पुथि बानुअः-आ',
      'santhali_ol': 'ᱤᱧ ᱴᱷᱮᱱ ᱯᱩᱛᱷᱤ ᱵᱟᱹᱱᱩᱜᱼᱟ',
      'latin': 'Inj then puthi banug-a',
      'ho': 'अयिंग ताःरे पुथि बनोःआ',
      'mundari': 'अयिंग ताःरे पुथि बनोःआ',
      'meaning_en': 'I do not have a book',
    },

    // Praise & Encouragement
    {
      'category': 'praise',
      'emoji': '🌟',
      'hindi': 'बहुत अच्छा / शाबाश',
      'santhali_dev': 'आडि नापाय',
      'santhali_ol': 'ᱟᱹᱰᱤ ᱱᱟᱯᱟᱭ',
      'latin': 'Adi napay',
      'ho': 'एतोगान बेस',
      'mundari': 'पुरः बुगिन',
      'meaning_en': 'Very good / Well done',
    },
    {
      'category': 'praise',
      'emoji': '💪',
      'hindi': 'फिर से कोशिश करो',
      'santhali_dev': 'आरहों कुरुमुटुय मे',
      'santhali_ol': 'ᱟᱨᱦᱚᱸ ᱠᱩᱨᱩᱢᱩᱴᱩᱭ ᱢᱮ',
      'latin': 'Arho kurumutu me',
      'ho': 'आरहो कुरुमुटू मे',
      'mundari': 'आरहो चेष्टाए मे',
      'meaning_en': 'Try again',
    },
    {
      'category': 'praise',
      'emoji': '✅',
      'hindi': 'हाँ, मुझे समझ आ गया',
      'santhali_dev': 'हें, इञिञ बुझाव केदा',
      'santhali_ol': 'ᱦᱮᱸ, ᱤᱧᱤᱧ ᱵᱩᱡᱷᱟᱹᱣ ᱠᱮᱫᱟ',
      'latin': 'Hen, inyin bujhau keda',
      'ho': 'हें, अयिंग बुझौ किदा',
      'mundari': 'हें, अयिंग बुझौ किदा',
      'meaning_en': 'Yes, I understood',
    },
  ];

  @override
  void initState() {
    super.initState();
    _executeTranslation(_inputController.text);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _executeTranslation(String text) {
    if (text.trim().isEmpty) {
      setState(() => _currentResult = null);
      return;
    }

    TranslationResult result;
    if (_selectedMode == 0) {
      result = TranslationEngine.instance.translateHindiToTribal(
        text,
        targetLanguage: _selectedLanguage,
      );
    } else {
      result = TranslationEngine.instance.translateTribalToHindi(
        text,
        sourceLanguage: _selectedLanguage,
      );
    }

    setState(() {
      _currentResult = result;
      if (_inputController.text != text) {
        _inputController.text = text;
      }
    });
  }

  Future<void> _playCurrentAudio() async {
    if (_currentResult == null) return;
    if (_selectedMode == 0) {
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
    final santhaliPhonetic = _currentResult!.phoneticDevanagari.isNotEmpty
        ? _currentResult!.phoneticDevanagari
        : _currentResult!.latinPronunciation;
    final teacherScript = 'प्यारे बच्चों, इसे संथाली में कहते हैं $santhaliPhonetic, और हिंदी में ${_inputController.text.trim()}।';
    await AudioTtsService.instance.speak(teacherScript, languageCode: 'hi-IN');
  }

  Future<void> _repeatWithKids() async {
    await _playCurrentAudio();
    setState(() => _classroomStars += 1);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🌟 बहुत खूब! सब बच्चे साथ बोले! (+1 Star ⭐ कुल: $_classroomStars)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleMicInput() async {
    if (_isListening) {
      await SpeechRecognitionService.instance.stopListening();
      setState(() {
        _isListening = false;
        _liveSpeechStatus = '';
      });
      if (_inputController.text.trim().isNotEmpty) {
        await _playCurrentAudio();
      }
    } else {
      final available = await SpeechRecognitionService.instance.initialize();
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('माइक उपलब्ध नहीं है • आप नीचे लिखकर अनुवाद कर सकते हैं'),
            backgroundColor: AppColors.secondary,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        _isListening = true;
        _liveSpeechStatus = '🎙️ माइक सुन रहा है... आप बोलिए';
      });

      await SpeechRecognitionService.instance.startListening(
        languageCode: _selectedMode == 0 ? 'hi_IN' : 'en_IN',
        onResult: (words) {
          if (!mounted) return;
          setState(() {
            _inputController.text = words;
            _liveSpeechStatus = 'पहचाना: "$words"';
          });
          _executeTranslation(words);
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
            if (_inputController.text.trim().isNotEmpty) {
              _playCurrentAudio();
            }
          }
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            final errStr = err.toLowerCase();
            if (errStr.contains('language_unavailable') ||
                errStr.contains('network') ||
                errStr.contains('server')) {
              _liveSpeechStatus =
                  '⚠️ ऑफ़लाइन माइक: Android OS में Hindi वॉइस पैक चाहिए (Settings > Voice Typing > Offline Speech) • त्वरित मोमेंट्स दबाएं या लिखें';
            } else {
              _liveSpeechStatus = 'माइक में आवाज़ नहीं मिली • कृपया दोबारा बोलें या नीचे मोमेंट्स चुनें';
            }
          });
        },
      );
    }
  }

  void _showFaceToFaceModal(BuildContext context) {
    if (_currentResult == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B), // Deep high contrast slate
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
                        Icon(Icons.face_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'कक्षा प्रदर्शन (Face-to-Face Kids View)',
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
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: AppSpacing.md),
              // Big Devanagari Pronunciation
              Text(
                _currentResult?.phoneticDevanagari.isNotEmpty == true
                    ? _currentResult!.phoneticDevanagari
                    : (_currentResult?.primaryText ?? ''),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 38,
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
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Hindi meaning
              Text(
                'हिंदी: ${_inputController.text.trim()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
                ),
              ),
              const Spacer(),
              // Action row
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
                    label: const Text('उच्चारण सुनाएं', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _playCurrentAudio,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                    label: const Text('+1 Star', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: _repeatWithKids,
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

  List<Map<String, dynamic>> _getFilteredRoutines() {
    if (_selectedCategory == 'all') return _quickRoutines;
    return _quickRoutines.where((r) => r['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoutines = _getFilteredRoutines();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Teacher / Student Role & Dialect Selector Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                // Direction Toggle
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMode = 0;
                                _inputController.text = 'अपनी किताब खोलो';
                              });
                              _executeTranslation(_inputController.text);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedMode == 0 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🧑‍🏫 शिक्षक मोड',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedMode == 0 ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMode = 1;
                                _inputController.text = 'मेरे पेट में दर्द हो रहा है';
                              });
                              _executeTranslation(_inputController.text);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedMode == 1 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🧒 विद्यार्थी मोड',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedMode == 1 ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Dialect Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<TribalLanguage>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    isDense: true,
                    items: TribalLanguage.values.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(
                          lang.displayName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (lang) {
                      if (lang != null) {
                        setState(() => _selectedLanguage = lang);
                        _executeTranslation(_inputController.text);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 2. Classroom Stars & Gamified Practice Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade50, Colors.amber.shade100.withValues(alpha: 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'कक्षा सहभागिता: $_classroomStars Stars ⭐',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                      ),
                      const Text(
                        'बच्चों के साथ एक स्वर में मातृभाषा बोलकर स्टार्स जीतें!',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    elevation: 0,
                    side: BorderSide(color: Colors.amber.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.tv_rounded, size: 16, color: AppColors.primary),
                  label: const Text('फेस-टू-फेस', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _showFaceToFaceModal(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 3. Live Classroom Interaction Arena
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
                          Icon(
                            _selectedMode == 0 ? Icons.record_voice_over : Icons.hearing,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _selectedMode == 0 ? 'कक्षा संवाद (Teacher in Hindi)' : 'छात्र अभिव्यक्ति (Student Voice)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isListening)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.mic, size: 12, color: Colors.red),
                            SizedBox(width: 4),
                            Text('सुन रहा हूँ...', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Speech / Text Input Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: _selectedMode == 0 ? 'माइक में बोलें या यहाँ लिखें...' : 'मातृभाषा में बोलें या लिखें...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (text) => _executeTranslation(text),
                        ),
                      ),
                      if (_inputController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _inputController.clear();
                            _executeTranslation('');
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.stop_circle : Icons.mic,
                          color: _isListening ? Colors.red : AppColors.primary,
                        ),
                        tooltip: 'माइक चालू/बंद',
                        onPressed: _toggleMicInput,
                      ),
                    ],
                  ),
                ),

                if (_liveSpeechStatus.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(_liveSpeechStatus, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                ],

                const SizedBox(height: AppSpacing.md),

                // Vernacular Output Presentation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryContainer.withValues(alpha: 0.3), AppColors.primaryContainer.withValues(alpha: 0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  _currentResult?.visualSymbol ?? '💬',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedMode == 0
                                        ? '${_selectedLanguage.displayName} (बच्चे सुनेंगे):'
                                        : 'हिंदी अनुवाद (शिक्षक के लिए):',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          StatusBadge(label: _selectedMode == 0 ? 'सत्यापित' : 'छात्र स्वर', color: AppColors.primary),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Large Devanagari Pronunciation Guide (Crisp on all devices!)
                      if (_selectedMode == 0) ...[
                        Text(
                          _currentResult?.phoneticDevanagari.isNotEmpty == true
                              ? _currentResult!.phoneticDevanagari
                              : (_currentResult?.primaryText ?? ''),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Ol Chiki script text & Romanized pronunciation
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(
                            'संथाली: ${_currentResult?.primaryText ?? ''}  |  उच्चारण: ${_currentResult?.latinPronunciation ?? ''}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Student mode: show Hindi output
                        Text(
                          _currentResult?.primaryText ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],

                      const Divider(height: 20),

                      // 1-Tap Action Bar
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          AppButton(
                            label: 'उच्चारण सुनें',
                            icon: Icons.volume_up,
                            variant: AppButtonVariant.primary,
                            onPressed: _playCurrentAudio,
                          ),
                          AppButton(
                            label: 'शिक्षक व्याख्या',
                            icon: Icons.psychology_alt_outlined,
                            variant: AppButtonVariant.outlined,
                            onPressed: _playTeacherExplanation,
                          ),
                          AppButton(
                            label: 'साथ दोहराएँ (+1 ⭐)',
                            icon: Icons.stars_rounded,
                            variant: AppButtonVariant.secondary,
                            onPressed: _repeatWithKids,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 4. Quick Classroom Moments & Scenarios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'त्वरित कक्षा निर्देश (Classroom Moments):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${filteredRoutines.length} निर्देश',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Category Chips for Routines
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _routineCategories.entries.map((entry) {
                final isSelected = _selectedCategory == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(entry.value['icon'] as IconData, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
                    label: Text(entry.value['label'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = entry.key);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Routine Cards Grid
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredRoutines.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final routine = filteredRoutines[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _inputController.text = routine['hindi'] as String;
                  });
                  _executeTranslation(routine['hindi'] as String);
                  _playCurrentAudio();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        routine['emoji'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine['hindi'] as String,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'संथाली: ${routine['santhali_dev']} (${routine['latin']})',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_outlined, size: 20, color: AppColors.primary),
                        onPressed: () {
                          setState(() {
                            _inputController.text = routine['hindi'] as String;
                          });
                          _executeTranslation(routine['hindi'] as String);
                          _playCurrentAudio();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
