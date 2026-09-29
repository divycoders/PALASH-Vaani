import 'package:flutter/material.dart';
import '../../../../core/services/audio_tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/natural_audio_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/learning_outcome_model.dart';
import '../../data/models/lesson_model.dart';

/// Interactive 3-Step MTB-MLE Classroom Lesson Player
/// Implements the UNESCO / NEP 2020 Gradual Release of Responsibility (GRR):
/// 1. I Do (शिक्षक समझाए - Dual-Language Concept Bridge)
/// 2. We Do (साथ दोहराएँ - Choral Repetition & Star Rewards)
/// 3. You Do (बच्चे उत्तर दें - Quick FLN Pictorial Mastery Check)
class ClassroomLessonPlayer extends StatefulWidget {
  final LessonModel lesson;
  final List<LearningOutcomeModel> outcomes;
  final VoidCallback onLessonCompleted;
  final VoidCallback onStarEarned;

  const ClassroomLessonPlayer({
    super.key,
    required this.lesson,
    required this.outcomes,
    required this.onLessonCompleted,
    required this.onStarEarned,
  });

  @override
  State<ClassroomLessonPlayer> createState() => _ClassroomLessonPlayerState();
}

class _ClassroomLessonPlayerState extends State<ClassroomLessonPlayer> {
  int _currentStep = 0; // 0: I Do, 1: We Do, 2: You Do
  int _playerStars = 0;
  int? _selectedQuizIndex;
  bool _quizChecked = false;
  bool _isSaving = false;

  /// Audio mode for MTB-MLE classroom: Santhali (student) is the primary default
  LessonAudioMode _audioMode = LessonAudioMode.santhali;

  @override
  void dispose() {
    AudioTtsService.instance.stop();
    super.dispose();
  }

  String _getSpokenText({
    required String sat,
    required String hi,
    String? dual,
  }) {
    return AudioTtsService.instance.formatPedagogySpeech(
      mode: _audioMode,
      santhaliText: sat,
      hindiText: hi,
      dualBridge: dual,
    );
  }

  Map<String, dynamic> _getLessonPedagogyData() {
    final id = widget.lesson.id;

    if (id == 'g1_math_01') {
      return {
        'visual': '🍎 🍎 🍎',
        'visual_label': '3 Apples • ३ सेब',
        'key_script': 'ᱯᱮ (᱓) • Pe',
        'phonetic': 'पे (Pe)',
        'student_prompt_sat': 'ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱥᱟᱢᱟᱝ ᱨᱮ ᱧᱮᱞ ᱯᱮ — ᱢᱤᱫ, ᱵᱟᱨ, ᱯᱮ! ᱯᱮᱭᱟ ᱥᱮᱣ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱥᱟᱢᱟᱝ ᱨᱮ ᱧᱮᱞ ᱯᱮ! ᱱᱚᱸᱰᱮ ᱟᱨᱟᱜ ᱥᱮᱣ ᱫᱚᱦᱚ ᱢᱮᱱᱟᱜ-ᱟ᱾ ᱫᱮᱞᱟ ᱵᱚᱱ ᱢᱤᱫ ᱛᱮ ᱞᱮᱠᱷᱟᱭᱟ — ᱢᱤᱫ, ᱵᱟᱨ, ᱟᱨ ᱯᱮ! ᱛᱤᱱᱟᱹᱜ ᱥᱮᱣ ᱦᱩᱭᱮᱱᱟ? ᱯᱮᱭᱟ ᱥᱮᱣ! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱓ ᱫᱚ ᱯᱮ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, सामने देखिए! यहाँ सुंदर लाल सेब रखे हैं। आइए साथ में मिलकर गिनते हैं — एक, दो, और तीन! तो कुल कितने सेब हुए? तीन सेब! संथाली में तीन को कहते हैं: पे!',
        'teacher_narration_bilingual': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ, ᱱᱩᱠᱩ ᱠᱚ ᱞᱮᱠᱷᱟ ᱢᱮ — ᱢᱤᱫ, ᱵᱟᱨ, ᱯᱮ! यानी बच्चों, एक, दो, तीन! मिलकर बन गए ३ सेब!',
        'teacher_prompt': 'बच्चों को ३ सेब या ३ कंकड़ दिखाते हुए कहें: "इन्हें गिनते हैं — एक, दो, तीन!" फिर संथाली में बोलें: "ᱢᱤᱫ, ᱵᱟᱨ, ᱯᱮ (मिद, बार, पे)!"',
        'quiz_question': 'Q. ३ (पे) के लिए सही चित्र कौन सा है?',
        'quiz_question_sat': 'ᱯᱮ (Pe) ᱞᱟᱹᱜᱤᱫ ᱥᱟᱹᱨᱤ ᱪᱤᱛᱟᱹᱨ ᱚᱠᱟ ᱠᱟᱱᱟ?',
        'quiz_options': [
          {'text': '🍎 🍎 (२ / बार)', 'correct': false, 'spoken_sat': 'ᱵᱟᱨ (Bar - 2)', 'spoken_hi': 'दो'},
          {'text': '🍎 🍎 🍎 (३ / पे)', 'correct': true, 'spoken_sat': 'ᱯᱮ (Pe - 3)', 'spoken_hi': 'तीन'},
          {'text': '🍎 🍎 🍎 🍎 (४ / पुन)', 'correct': false, 'spoken_sat': 'ᱯᱩᱱ (Pun - 4)', 'spoken_hi': 'चार'},
        ],
      };
    } else if (id == 'g1_math_02') {
      return {
        'visual': '🔴  ⬛  🔺',
        'visual_label': 'Circle, Square, Triangle',
        'key_script': 'ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱯᱩᱱ ᱠᱳᱬ',
        'phonetic': 'गुलाय आर पुन कोण',
        'student_prompt_sat': 'ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱯᱩᱱ ᱠᱳᱬ — ᱨᱩᱴᱤ ᱫᱚ ᱜᱩᱞᱟᱹᱭ ᱜᱮᱭᱟ, ᱥᱞᱮᱴ ᱫᱚ ᱯᱩᱱ ᱠᱳᱬ ᱜᱮᱭᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱵᱚᱣᱟᱜ ᱟᱰᱮ-ᱯᱟᱥᱮ ᱟᱭᱢᱟ ᱨᱩᱯ ᱢᱮᱱᱟᱜ-ᱟ! ᱡᱮᱞᱮᱠᱟ ᱚᱲᱟᱜ ᱨᱮ ᱟᱭᱳ ᱡᱟᱦᱟᱸ ᱨᱩᱴᱤ ᱮ ᱛᱮᱭᱟᱨᱟ, ᱚᱱᱟ ᱫᱚ ᱜᱩᱞᱟᱹᱭ ᱜᱮᱭᱟ᱾ ᱟᱨ ᱯᱟᱲᱦᱟᱣ ᱥᱞᱮᱴ ᱫᱚ ᱯᱩᱱ ᱠᱳᱬ ᱜᱮᱭᱟ! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱜᱚᱞ ᱫᱚ ᱜᱩᱞᱟᱹᱭ ᱟᱨ ᱪᱚᱣᱠᱚᱨ ᱫᱚ ᱯᱩᱱ ᱠᱳᱬ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, हमारे चारों तरफ अलग-अलग आकृतियाँ होती हैं! जैसे घर में माँ जो रोटी बनाती है, वह गोल होती है। और जो स्लेट होती है, वह चौकोर होती है! गोल को संथाली में गुलाय कहते हैं, और चौकोर को पुन कोण!',
        'teacher_narration_bilingual': 'ᱨᱩᱴᱤ ᱫᱚ ᱜᱩᱞᱟᱹᱭ ᱜᱮᱭᱟ, ᱥᱞᱮᱴ ᱫᱚ ᱯᱩᱱ ᱠᱳᱬ ᱜᱮᱭᱟ! यानी बच्चों, रोटी गोल होती है और स्लेट चौकोर!',
        'teacher_prompt': 'रोटी और स्लेट दिखाते हुए कहें: "रोटी गोल (ᱜᱩᱞᱟᱹᱭ) है और स्लेट चौकोर (ᱯᱩᱱ ᱠᱳᱬ) है।"',
        'quiz_question': 'Q. रोटी किस आकार की होती है?',
        'quiz_question_sat': 'ᱨᱩᱴᱤ ᱫᱚ ᱚᱠᱟ ᱞᱮᱠᱟᱱᱟ? (ᱜᱩᱞᱟᱹᱭ ᱥᱮ ᱯᱩᱱ ᱠᱳᱬ?)',
        'quiz_options': [
          {'text': '🔴 गोल (ᱜᱩᱞᱟᱹᱭ / Gulay)', 'correct': true, 'spoken_sat': 'ᱜᱩᱞᱟᱹᱭ (Gulay - गोल)', 'spoken_hi': 'गोल'},
          {'text': '⬛ चौकोर (ᱯᱩᱱ ᱠᱳᱬ / Pun Kon)', 'correct': false, 'spoken_sat': 'ᱯᱩᱱ ᱠᱳᱬ (Pun Kon - चौकोर)', 'spoken_hi': 'चौकोर'},
          {'text': '🔺 तिकोना (ᱯᱮ ᱠᱳᱬ / Pe Kon)', 'correct': false, 'spoken_sat': 'ᱯᱮ ᱠᱳᱬ (Pe Kon - तिकोना)', 'spoken_hi': 'तिकोना'},
        ],
      };
    } else if (id == 'g1_math_03') {
      return {
        'visual': '🐘  🐭  ⚖️',
        'visual_label': 'Big Elephant & Small Mouse',
        'key_script': 'ᱢᱟᱨᱟᱝ ᱟᱨ ᱦᱩᱰᱤᱧ',
        'phonetic': 'मारांग आर हुडिंज (बड़ा और छोटा)',
        'student_prompt_sat': 'ᱦᱟᱹᱛᱤ ᱫᱚ ᱢᱟᱨᱟᱝ ᱜᱮᱭᱟ, ᱜᱩᱰᱩ ᱫᱚ ᱦᱩᱰᱤᱧ ᱜᱮᱭᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱧᱮᱞ ᱯᱮ ᱵᱤᱨ ᱨᱤᱱᱤᱡ ᱦᱟᱹᱛᱤ ᱛᱤᱱᱟᱹᱜ ᱢᱟᱨᱟᱝ ᱜᱮᱭᱟᱭ, ᱟᱨ ᱦᱩᱰᱤᱧ ᱜᱩᱰᱩ ᱛᱤᱱᱟᱹᱜ ᱠᱟᱹᱴᱤᱡ ᱜᱮᱭᱟᱭ! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱢᱟᱨᱟᱝ ᱡᱤᱱᱤᱥ ᱫᱚ ᱢᱟᱨᱟᱝ ᱟᱨ ᱠᱟᱹᱴᱤᱡ ᱫᱚ ᱦᱩᱰᱤᱧ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ! ᱦᱟᱹᱛᱤ ᱫᱚ ᱢᱟᱨᱟᱝ, ᱜᱩᱰᱩ ᱫᱚ ᱦᱩᱰᱤᱧ!',
        'teacher_narration_hi': 'प्यारे बच्चों, देखो जंगल का हाथी कितना बड़ा होता है, और नन्हा चूहा कितना छोटा! बड़े को संथाली में मारांग कहते हैं, और छोटे को हुड़िञ! हाथी बड़ा, चूहा छोटा!',
        'teacher_narration_bilingual': 'ᱦᱟᱹᱛᱤ ᱫᱚ ᱢᱟᱨᱟᱝ ᱜᱮᱭᱟ, ᱜᱩᱰᱩ ᱫᱚ ᱦᱩᱰᱤᱧ ᱜᱮᱭᱟ! यानी बच्चों, हाथी बड़ा होता है और चूहा छोटा!',
        'teacher_prompt': 'हाथी और चूहे का चित्र दिखाकर पूछें: "कौन बड़ा (ᱢᱟᱨᱟᱝ) है और कौन छोटा (ᱦᱩᱰᱤᱧ) है?"',
        'quiz_question': 'Q. हाथी और चूहे में कौन बड़ा (ᱢᱟᱨᱟᱝ) है?',
        'quiz_question_sat': 'ᱦᱟᱹᱛᱤ ᱟᱨ ᱜᱩᱰᱩ ᱨᱮ ᱚᱠᱚᱭ ᱢᱟᱨᱟᱝ ᱜᱮᱭᱟ?',
        'quiz_options': [
          {'text': '🐘 हाथी (ᱦᱟᱹᱛᱤ / Hati)', 'correct': true, 'spoken_sat': 'ᱦᱟᱹᱛᱤ (Hati - हाथी)', 'spoken_hi': 'हाथी'},
          {'text': '🐭 चूहा (ᱜᱩᱰᱩ / Gudu)', 'correct': false, 'spoken_sat': 'ᱜᱩᱰᱩ (Gudu - चूहा)', 'spoken_hi': 'चूहा'},
          {'text': 'दोनो बराबर', 'correct': false, 'spoken_sat': 'ᱵᱟᱱᱟᱨ ᱵᱟᱨᱟᱵᱟᱹᱨᱤ', 'spoken_hi': 'दोनो बराबर'},
        ],
      };
    } else if (id == 'g1_math_04') {
      return {
        'visual': '🔟 ➕ 3️⃣  =  1️⃣3️⃣',
        'visual_label': 'Bundle of 10 + 3 Sticks = 13',
        'key_script': 'ᱜᱮᱞ ᱯᱮ (᱑᱓) • Gel Pe',
        'phonetic': 'गेल पे (तेरह)',
        'student_prompt_sat': 'ᱜᱮᱞ ᱯᱮ — ᱜᱮᱞ ᱟᱨ ᱯᱮ ᱛᱤᱞᱤ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱜᱮᱞ ᱯᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱡᱚᱠᱷᱚᱱ ᱜᱮᱞ ᱜᱚᱴᱟᱝ ᱠᱟᱹᱴᱷᱤ ᱨᱮᱱᱟᱜ ᱢᱤᱫ ᱵᱤᱱᱰᱟ ᱵᱚᱱ ᱛᱚᱞᱟ, ᱚᱱᱟ ᱫᱚ ᱜᱮᱞ ᱠᱟᱱᱟ᱾ ᱱᱚᱶᱟ ᱜᱮᱞ ᱨᱮ ᱟᱨ ᱯᱮᱭᱟ ᱠᱟᱹᱴᱷᱤ ᱢᱮᱥᱟ ᱞᱮᱠᱷᱟᱱ ᱦᱩᱭᱩᱜ-ᱟ ᱜᱮᱞ ᱯᱮ (᱑᱓)! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱑᱓ ᱫᱚ ᱜᱮᱞ ᱯᱮ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, जब हम १० तीलियों का एक बंडल बनाते हैं और उसमें ३ खुली तीलियाँ मिलाते हैं, तो १० और ३ मिलकर तेरह बनते हैं! संथाली में इसे कहते हैं: गेल पे!',
        'teacher_narration_bilingual': 'ᱜᱮᱞ ᱟᱨ ᱯᱮ ᱛᱤᱞᱤ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱜᱮᱞ ᱯᱮ! यानी बच्चों, दस और तीन मिलकर बने तेरह!',
        'teacher_prompt': '१० तीलियों का १ बंडल दिखाएं और ३ खुली तीलियां जोड़कर कहें: "दस और तीन मिलकर बने तेरह (ᱜᱮᱞ ᱯᱮ)!"',
        'quiz_question': 'Q. १० का एक बंडल और ३ खुली तीलियाँ मिलकर क्या बनती हैं?',
        'quiz_question_sat': 'ᱜᱮᱞ ᱟᱨ ᱯᱮ ᱛᱤᱞᱤ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱛᱤᱱᱟᱹᱜ ᱦᱩᱭᱩᱜ-ᱟ?',
        'quiz_options': [
          {'text': '११ (ᱜᱮᱞ ᱢᱤᱫ)', 'correct': false, 'spoken_sat': 'ᱜᱮᱞ ᱢᱤᱫ (Gel Mid - 11)', 'spoken_hi': 'ग्यारह'},
          {'text': '१३ (ᱜᱮᱞ ᱯᱮ / Gel Pe)', 'correct': true, 'spoken_sat': 'ᱜᱮᱞ ᱯᱮ (Gel Pe - 13)', 'spoken_hi': 'तेरह'},
          {'text': '१५ (ᱜᱮᱞ ᱢᱚᱬᱮ)', 'correct': false, 'spoken_sat': 'ᱜᱮᱞ ᱢᱚᱬᱮ (Gel Mone - 15)', 'spoken_hi': 'पंद्रह'},
        ],
      };
    } else if (id == 'g1_lang_01') {
      return {
        'visual': '🔤 ᱚ ᱞ ᱠ ᱛ',
        'visual_label': 'Ol Chiki Primary Alphabet',
        'key_script': 'ᱚ ᱞ ᱠ ᱛ • Ol La Ka Ta',
        'phonetic': 'ओल, ला, का, ता',
        'student_prompt_sat': 'ᱚ, ᱞ, ᱠ, ᱛ — ᱢᱟᱨᱥᱟᱞ ᱪᱤᱠᱤ ᱢᱮᱱ ᱢᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱚᱞ ᱪᱤᱠᱤ ᱫᱚ ᱟᱵᱚᱣᱟᱜ ᱥᱟᱱᱛᱟᱲᱤ ᱯᱟᱹᱨᱥᱤ ᱨᱮᱱᱟᱜ ᱢᱚᱡᱽ ᱪᱤᱠᱤ ᱠᱟᱱᱟ! ᱡᱮᱞᱮᱠᱟ ᱚ, ᱞ, ᱠ, ᱛ! ᱫᱮᱞᱟ ᱵᱚᱱ ᱢᱤᱫ ᱛᱮ ᱢᱮᱱᱟ — ᱚ, ᱞ, ᱠ, ᱛ! ᱱᱚᱶᱟ ᱪᱤᱠᱤ ᱛᱮᱜᱮ ᱟᱵᱚ ᱥᱟᱱᱟᱢ ᱠᱟᱛᱷᱟ ᱵᱚᱱ ᱚᱞᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, ओल चिकी संथाली भाषा की सुंदर लिपि है! जैसे हिन्दी में क, ख, ग होता है, वैसे ही ओल चिकी में ओल, ला, का, ता होता है! आइए साथ बोलें — ओल, ला, का, ता!',
        'teacher_narration_bilingual': 'ᱚ, ᱞ, ᱠ, ᱛ — ᱢᱟᱨᱥᱟᱞ ᱪᱤᱠᱤ ᱢᱮᱱ ᱢᱮ! यानी बच्चों, यह हमारी सुंदर ओल चिकी वर्णमाला है!',
        'teacher_prompt': 'श्यामपट्ट पर "ᱚ" और "ᱞ" लिखकर बच्चों को ऊंचे स्वर में ध्वनि दोहराने को कहें।',
        'quiz_question': 'Q. पेड़ (ᱫᱟᱨᱮ - Dare) शब्द का पहला अक्षर कौन सा है?',
        'quiz_question_sat': 'ᱫᱟᱨᱮ (Dare) ᱨᱮᱱᱟᱜ ᱯᱩᱭᱞᱩ ᱪᱤᱠᱤ ᱚᱠᱟ ᱠᱟᱱᱟ?',
        'quiz_options': [
          {'text': 'ᱫ (द / Da)', 'correct': true, 'spoken_sat': 'ᱫ (Da)', 'spoken_hi': 'द'},
          {'text': 'ᱢ (म / Ma)', 'correct': false, 'spoken_sat': 'ᱢ (Ma)', 'spoken_hi': 'म'},
          {'text': 'ᱥ (स / Sa)', 'correct': false, 'spoken_sat': 'ᱥ (Sa)', 'spoken_hi': 'स'},
        ],
      };
    } else if (id == 'g1_lang_02') {
      return {
        'visual': '🏠  💧  🌳',
        'visual_label': 'Ghar (Olag) & Jal (Daag)',
        'key_script': 'ᱚᱲᱟᱜ ᱟᱨ ᱫᱟᱜ',
        'phonetic': 'ओड़ाग आर दाग (घर और जल)',
        'student_prompt_sat': 'ᱚᱲᱟᱜ ᱟᱨ ᱫᱟᱜ — ᱚᱲᱟᱜ ᱢᱮᱱᱟᱜ-ᱟ, ᱫᱟᱜ ᱧᱩᱭ ᱢᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱵᱚ ᱡᱟᱦᱟᱸ ᱨᱮ ᱵᱚᱱ ᱛᱟᱦᱮᱸᱱᱟ, ᱚᱱᱟ ᱫᱚ ᱚᱲᱟᱜ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ! ᱟᱨ ᱡᱟᱦᱟᱸ ᱫᱟᱜ ᱵᱚᱱ ᱧᱩᱭᱟ, ᱚᱱᱟ ᱫᱚ ᱫᱟᱜ ᱠᱟᱱᱟ! ᱚᱲᱟᱜ ᱫᱚ ᱟᱵᱚᱣᱟᱜ ᱛᱟᱦᱮᱸᱱ ᱴᱷᱟᱶ ᱟᱨ ᱫᱟᱜ ᱫᱚ ᱟᱵᱚᱣᱟᱜ ᱡᱤᱣᱤ!',
        'teacher_narration_hi': 'प्यारे बच्चों, हम जिस घर में रहते हैं, उसे संथाली में ओड़ाग कहते हैं! और जो पानी हम पीते हैं, उसे दाग कहते हैं! ओड़ाग यानी घर, दाग यानी पानी!',
        'teacher_narration_bilingual': 'ᱚᱲᱟᱜ ᱢᱮᱱᱟᱜ-ᱟ, ᱫᱟᱜ ᱧᱩᱭ ᱢᱮ! यानी ओड़ाग का अर्थ है घर, और दाग का अर्थ है जल!',
        'teacher_prompt': 'घर और पानी का चित्र दिखाते हुए कहें: "घर को संथाली में ᱚᱲᱟᱜ (Olag) और जल को ᱫᱟᱜ (Daag) कहते हैं।"',
        'quiz_question': 'Q. "पानी / जल" को संथाली में क्या कहते हैं?',
        'quiz_question_sat': 'ᱫᱟᱜ (Daag) ᱫᱚ ᱪᱮᱫ ᱠᱟᱱᱟ? ᱫᱟᱜ ᱫᱚ ᱪᱮᱫ ᱠᱚ ᱢᱮᱛᱟᱜ-ᱟ?',
        'quiz_options': [
          {'text': 'ᱫᱟᱜ (Daag)', 'correct': true, 'spoken_sat': 'ᱫᱟᱜ (Daag - जल)', 'spoken_hi': 'दाग (जल)'},
          {'text': 'ᱚᱲᱟᱜ (Olag)', 'correct': false, 'spoken_sat': 'ᱚᱲᱟᱜ (Olag - घर)', 'spoken_hi': 'ओड़ाग (घर)'},
          {'text': 'ᱫᱟᱨᱮ (Dare)', 'correct': false, 'spoken_sat': 'ᱫᱟᱨᱮ (Dare - पेड़)', 'spoken_hi': 'दारे (पेड़)'},
        ],
      };
    } else if (id == 'g1_lang_03') {
      return {
        'visual': '🎵  👏  🌙',
        'visual_label': 'Chando Ayo Action Song',
        'key_script': 'ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱥᱮᱨᱢᱟ ᱨᱮ',
        'phonetic': 'चाँदो आयो सेरमा रे (चंदा मामा)',
        'student_prompt_sat': 'ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱥᱮᱨᱢᱟ ᱨᱮ, ᱢᱟᱨᱥᱟᱞ ᱮᱢᱚᱜ ᱧᱤᱫᱟᱹ ᱨᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱧᱤᱫᱟᱹ ᱥᱮᱨᱢᱟ ᱨᱮ ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱢᱟᱨᱥᱟᱞ ᱮ ᱮᱢᱟᱵᱚᱱᱟ! ᱫᱮᱞᱟ ᱵᱚᱱ ᱥᱟᱱᱟᱢ ᱠᱚ ᱛᱷᱟᱭᱚ ᱛᱮ ᱥᱮᱨᱮᱧᱟ — ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱥᱮᱨᱢᱟ ᱨᱮ, ᱢᱟᱨᱥᱟᱞ ᱮᱢᱚᱜ ᱧᱤᱫᱟᱹ ᱨᱮ!',
        'teacher_narration_hi': 'प्यारे बच्चों, रात में आसमान में प्यारा चाँद निकलता है! संथाली में चंदा मामा को कहते हैं: चाँदॊ आयो! आइए साथ में ताली बजाकर गाते हैं — चाँदॊ आयो सेरमा रे!',
        'teacher_narration_bilingual': 'ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱥᱮᱨᱢᱟ ᱨᱮ! यानी चंदा मामा रात में हमें प्यारी रोशनी देते हैं!',
        'teacher_prompt': 'सभी बच्चों के साथ ताली बजाते हुए बालगीत गाएं: "ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱥᱮᱨᱢᱟ ᱨᱮ, ᱢᱟᱨᱥᱟᱞ ᱮᱢᱚᱜ ᱧᱤᱫᱟᱹ ᱨᱮ!"',
        'quiz_question': 'Q. बालगीत में चाँद को प्यार से क्या कहा गया है?',
        'quiz_question_sat': 'ᱥᱮᱨᱢᱟ ᱨᱮ ᱪᱟᱸᱫᱚ ᱟᱭᱳ ᱫᱚ ᱪᱮᱫ ᱠᱟᱱᱟᱭ?',
        'quiz_options': [
          {'text': 'ᱪᱟᱸᱫᱚ ᱟᱭᱳ (चाँदो आयो)', 'correct': true, 'spoken_sat': 'ᱪᱟᱸᱫᱚ ᱟᱭᱳ (Chando Ayo)', 'spoken_hi': 'चाँदो आयो'},
          {'text': 'ᱵᱮᱲᱟ (बेड़ा)', 'correct': false, 'spoken_sat': 'ᱵᱮᱲᱟ (Beda - सूरज)', 'spoken_hi': 'बेड़ा'},
          {'text': 'ᱫᱟᱨᱮ (दारे)', 'correct': false, 'spoken_sat': 'ᱫᱟᱨᱮ (Dare - पेड़)', 'spoken_hi': 'दारे'},
        ],
      };
    } else if (id == 'g1_evs_01') {
      return {
        'visual': '👨‍👩‍👧‍👦  🏡  ❤️',
        'visual_label': 'My Family & Loving Home',
        'key_script': 'ᱟᱭᱳ ᱟᱨ ᱵᱟᱵᱟ',
        'phonetic': 'आयो आर बाबा (माँ और पिताजी)',
        'student_prompt_sat': 'ᱟᱭᱳ ᱟᱨ ᱵᱟᱵᱟ — ᱟᱭᱳ ᱫᱚ ᱡᱚᱢᱟᱜ ᱮ ᱮᱢᱟᱵᱚᱱᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱵᱚᱣᱟᱜ ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱮ ᱟᱭᱳ ᱫᱚ ᱟᱹᱰᱤ ᱫᱩᱞᱟᱹᱲ ᱛᱮ ᱡᱚᱢᱟᱜ ᱮ ᱮᱢᱟᱵᱚᱱᱟ, ᱟᱨ ᱵᱟᱵᱟ ᱫᱚ ᱟᱵᱚᱭ ᱦᱟᱨᱟ ᱵᱩᱨᱩ ᱮᱫ ᱵᱚᱱᱟ! ᱟᱭᱳ ᱟᱨ ᱵᱟᱵᱟ ᱜᱮ ᱟᱵᱚᱣᱟᱜ ᱡᱚᱛᱚ ᱠᱷᱚᱱ ᱢᱟᱨᱟᱝ ᱫᱩᱞᱟᱹᱲ ᱠᱟᱱᱟᱠᱤᱱ!',
        'teacher_narration_hi': 'प्यारे बच्चों, हमारे परिवार में माँ हमें प्यार से खाना खिलाती हैं। माँ को संथाली में आयो कहते हैं, और पिताजी को बाबा! आयो और बाबा हमारे परिवार की जान हैं!',
        'teacher_narration_bilingual': 'ᱟᱭᱳ ᱟᱨ ᱵᱟᱵᱟ — ᱟᱭᱳ ᱫᱚ ᱡᱚᱢᱟᱜ ᱮ ᱮᱢᱟᱵᱚᱱᱟ! यानी माँ को आयो और पिताजी को बाबा कहते हैं!',
        'teacher_prompt': 'बच्चों से पूछें: "घर में आपको खाना कौन खिलाता है?" फिर बताएं: "माँ को हम प्यार से ᱟᱭᱳ (Ayo) कहते हैं।"',
        'quiz_question': 'Q. माँ को संथाली भाषा में क्या कहते हैं?',
        'quiz_question_sat': 'ᱡᱚᱢᱟᱜ ᱮᱢᱚᱜ ᱟᱭᱳ ᱫᱚ ᱚᱠᱚᱭ ᱠᱟᱱᱟᱭ?',
        'quiz_options': [
          {'text': 'ᱟᱭᱳ (Ayo)', 'correct': true, 'spoken_sat': 'ᱟᱭᱳ (Ayo - माँ)', 'spoken_hi': 'माँ (आयो)'},
          {'text': 'ᱵᱟᱵᱟ (Baba)', 'correct': false, 'spoken_sat': 'ᱵᱟᱵᱟ (Baba - पिताजी)', 'spoken_hi': 'पिताजी (बाबा)'},
          {'text': 'ᱢᱤᱥᱤ (Misi)', 'correct': false, 'spoken_sat': 'ᱢᱤᱥᱤ (Misi - बहन)', 'spoken_hi': 'बहन (मिसि)'},
        ],
      };
    } else if (id == 'g1_evs_02') {
      return {
        'visual': '🌳  🍃  🌸',
        'visual_label': 'Sal Tree (Sarjom) & Mahua',
        'key_script': 'ᱥᱟᱨᱡᱚᱢ ᱫᱟᱨᱮ',
        'phonetic': 'सारजोम दारे (साल का पेड़)',
        'student_prompt_sat': 'ᱥᱟᱨᱡᱚᱢ ᱫᱟᱨᱮ — ᱡᱷᱟᱨᱠᱷᱚᱸᱰ ᱨᱮᱱᱟᱜ ᱢᱟᱨᱟᱝ ᱵᱤᱨ ᱫᱟᱨᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱵᱚ ᱡᱷᱟᱨᱠᱷᱚᱸᱰ ᱨᱮᱱᱟᱜ ᱵᱤᱨ ᱨᱮ ᱡᱚᱛᱚ ᱠᱷᱚᱱ ᱢᱟᱨᱟᱝ ᱟᱨ ᱢᱚᱡᱽ ᱫᱟᱨᱮ ᱫᱚ ᱥᱟᱨᱡᱚᱢ ᱫᱟᱨᱮ ᱠᱟᱱᱟ! ᱥᱟᱨᱡᱚᱢ ᱥᱟᱠᱟᱢ ᱟᱨ ᱵᱟᱦᱟ ᱛᱮ ᱵᱟᱦᱟ ᱯᱚᱨᱚᱵᱽ ᱵᱚᱱ ᱢᱟᱱᱟᱣᱟ, ᱟᱨ ᱢᱟᱛᱠᱚᱢ ᱨᱮᱱᱟᱜ ᱢᱤᱴᱷᱟᱹ ᱥᱤᱵᱤᱞ ᱦᱚᱸ ᱵᱚᱱ ᱡᱚᱢᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, हमारे झारखंड के जंगलों में साल का पेड़ सबसे ऊँचा और सुंदर होता है! साल के पेड़ को संथाली में सारजोम दारे कहते हैं! और महुआ को मातकोम कहते हैं!',
        'teacher_narration_bilingual': 'ᱥᱟᱨᱡᱚᱢ ᱫᱟᱨᱮ — ᱡᱷᱟᱨᱠᱷᱚᱸᱰ ᱨᱮᱱᱟᱜ ᱢᱟᱨᱟᱝ ᱵᱤᱨ ᱫᱟᱨᱮ! यानी साल का पेड़ हमारे जंगलों का राजा है!',
        'teacher_prompt': 'साल के पत्ते दिखाते हुए कहें: "झारखंड के जंगलों की शान है ᱥᱟᱨᱡᱚᱢ (Sarjom) यानी साल का पेड़!"',
        'quiz_question': 'Q. झारखंड के राजकीय वृक्ष (साल के पेड़) को क्या कहते हैं?',
        'quiz_question_sat': 'ᱡᱷᱟᱨᱠᱷᱚᱸᱰ ᱨᱮᱱᱟᱜ ᱢᱟᱨᱟᱝ ᱵᱤᱨ ᱫᱟᱨᱮ ᱚᱠᱟ ᱠᱟᱱᱟ?',
        'quiz_options': [
          {'text': 'ᱥᱟᱨᱡᱚᱢ (Sarjom)', 'correct': true, 'spoken_sat': 'ᱥᱟᱨᱡᱚᱢ ᱫᱟᱨᱮ (Sarjom - साल का पेड़)', 'spoken_hi': 'सारजोम (साल का पेड़)'},
          {'text': 'ᱢᱟᱛᱠᱚᱢ (Matkom)', 'correct': false, 'spoken_sat': 'ᱢᱟᱛᱠᱚᱢ (Matkom - महुआ)', 'spoken_hi': 'मातकोम (महुआ)'},
          {'text': 'ᱩᱞ ᱫᱟᱨᱮ (Ul Dare)', 'correct': false, 'spoken_sat': 'ᱩᱞ ᱫᱟᱨᱮ (Ul Dare - आम)', 'spoken_hi': 'उल दारे'},
        ],
      };
    } else if (id == 'g1_evs_03') {
      return {
        'visual': '🧼  💧  🤲',
        'visual_label': 'Clean Water & Handwashing',
        'key_script': 'ᱛᱤ ᱟᱹᱨᱩᱵ ᱟᱨ ᱥᱟᱯᱷᱟ ᱫᱟᱜ',
        'phonetic': 'ती अरुब आर साफा दाग',
        'student_prompt_sat': 'ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱥᱟᱵᱩᱱ ᱛᱮ ᱛᱤ ᱟᱹᱨᱩᱵ ᱢᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱥᱟᱵᱩᱱ ᱟᱨ ᱥᱟᱯᱷᱟ ᱫᱟᱜ ᱛᱮ ᱛᱤ ᱟᱹᱨᱩᱵ ᱟᱹᱰᱤ ᱞᱟᱹᱠᱛᱤ ᱠᱟᱱᱟ! ᱛᱤ ᱟᱹᱨᱩᱵ ᱞᱮᱠᱷᱟᱱ ᱨᱩᱣᱟᱹ-ᱦᱟᱹᱥᱩ ᱵᱟᱭ ᱦᱤᱡᱩᱜ-ᱟ ᱟᱨ ᱟᱵᱚ ᱱᱤᱨᱚᱲ ᱵᱚᱱ ᱛᱟᱦᱮᱸᱱᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, खाना खाने से पहले साबुन से हाथ धोना बहुत जरूरी है, ताकि कीटाणु दूर रहें! हाथ धोने को संथाली में ती अरुब कहते हैं!',
        'teacher_narration_bilingual': 'ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱥᱟᱵᱩᱱ ᱛᱮ ᱛᱤ ᱟᱹᱨᱩᱵ ᱢᱮ! यानी भोजन से पहले हाथ धोना बहुत जरूरी है!',
        'teacher_prompt': 'साबुन से हाथ मलते हुए बच्चों को दिखाएं: "खाना खाने से पहले हाथ धोना (ᱛᱤ ᱟᱹᱨᱩᱵ) बहुत ज़रूरी है।"',
        'quiz_question': 'Q. मध्याह्न भोजन (MDM) से पहले क्या करना ज़रूरी है?',
        'quiz_question_sat': 'ᱡᱚᱢ ᱢᱟᱬᱟᱝ ᱨᱮ ᱪᱮᱫ ᱠᱟᱹᱢᱤ ᱞᱟᱹᱠᱛᱤ ᱠᱟᱱᱟ?',
        'quiz_options': [
          {'text': '🧼 साबुन से हाथ धोना (ᱛᱤ ᱟᱹᱨᱩᱵ)', 'correct': true, 'spoken_sat': 'ᱛᱤ ᱟᱹᱨᱩᱵ (Ti arub - हाथ धोना)', 'spoken_hi': 'साबुन से हाथ धोना'},
          {'text': 'सीधे खाना शुरू करना', 'correct': false, 'spoken_sat': 'ᱮᱠᱟᱞ ᱜᱮ ᱡᱚᱢ', 'spoken_hi': 'सीधे खाना'},
          {'text': 'कंकड़ से खेलना', 'correct': false, 'spoken_sat': 'ᱫᱷᱤᱨᱤ ᱛᱮ ᱮᱱᱮᱡ', 'spoken_hi': 'कंकड़ से खेलना'},
        ],
      };
    } else if (id == 'g2_math_01') {
      return {
        'visual': '🍎🍎🍎  ➕  🍎🍎  =  5️⃣',
        'visual_label': '3 Apples + 2 Apples = 5 Apples',
        'key_script': 'ᱯᱮ + ᱵᱟᱨ = ᱢᱚᱬᱮ (५)',
        'phonetic': 'पे + बार = मोणे (३ + २ = ५)',
        'student_prompt_sat': 'ᱯᱮ ᱟᱨ ᱵᱟᱨ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱦᱩᱭᱩᱜ-ᱟ ᱢᱚᱬᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱸᱡᱚᱢ ᱯᱮ! ᱡᱚᱠᱷᱚᱱ ᱡᱟᱦᱟᱸᱱᱟᱜ ᱨᱮ ᱟᱨᱦᱚᱸ ᱵᱚᱱ ᱢᱮᱥᱟᱭᱟ, ᱚᱱᱟ ᱫᱚ ᱡᱚᱲ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ᱾ ᱡᱮᱞᱮᱠᱟ ᱟᱢ ᱴᱷᱮᱱ ᱯᱮᱭᱟ ᱥᱮᱣ ᱢᱮᱱᱟᱜ-ᱟ, ᱟᱨ ᱵᱟᱨᱭᱟ ᱥᱮᱣ ᱟᱨᱦᱚᱸᱢ ᱧᱟᱢ ᱠᱮᱫᱟ! ᱫᱮᱞᱟ ᱵᱚᱱ ᱞᱮᱠᱷᱟᱭᱟ — ᱢᱤᱫ, ᱵᱟᱨ, ᱯᱮ, ᱯᱩᱱ, ᱢᱚᱬᱮ! ᱯᱮ ᱟᱨ ᱵᱟᱨ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱦᱩᱭᱮᱱᱟ ᱢᱚᱬᱮ! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱢᱮᱱ ᱯᱮ: ᱯᱮ ᱟᱨ ᱵᱟᱨ, ᱢᱚᱬᱮ!',
        'teacher_narration_hi': 'प्यारे बच्चों, ध्यान से समझिए! जब हम किसी चीज़ में और मिलाते हैं, तो उसे जोड़ कहते हैं। जैसे आपके पास ३ सेब हैं, और २ सेब और मिल गए। तो आइए गिनते हैं: एक, दो, तीन, चार, पाँच! यानी ३ में २ जोड़ेंगे तो ५ बनेगा! संथाली में बोलें: पे आर बार, मोणे!',
        'teacher_narration_bilingual': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ, ᱯᱮᱭᱟ ᱥᱮᱣ ᱟᱨ ᱵᱟᱨᱭᱟ ᱥᱮᱣ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱦᱩᱭᱩᱜ-ᱟ ᱢᱚᱬᱮᱭᱟ ᱥᱮᱣ! यानी बच्चों, जब हम ३ सेब में २ सेब मिलाते हैं, तो मिलकर ५ सेब बनते हैं!',
        'teacher_prompt': '३ पत्ते बाएं हाथ में और २ पत्ते दाएं हाथ में रखकर मिलाएं: "३ + २ = ५ (ᱯᱮ + ᱵᱟᱨ = ᱢᱚᱬᱮ)!"',
        'quiz_question': 'Q. ३ पत्ते और २ पत्ते मिलकर कुल कितने पत्ते होंगे?',
        'quiz_question_sat': 'ᱯᱮ ᱟᱨ ᱵᱟᱨ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱛᱤᱱᱟᱹᱜ ᱦᱩᱭᱩᱜ-ᱟ?',
        'quiz_options': [
          {'text': '४ (ᱯᱩᱱ)', 'correct': false, 'spoken_sat': 'ᱯᱩᱱ (Pun - 4)', 'spoken_hi': 'चार'},
          {'text': '५ (पाँच / ᱢᱚᱬᱮ)', 'correct': true, 'spoken_sat': 'ᱢᱚᱬᱮ (Mone - 5)', 'spoken_hi': 'पाँच'},
          {'text': '६ (ᱛᱩᱨᱩᱭ)', 'correct': false, 'spoken_sat': 'ᱛᱩᱨᱩᱭ (Turuy - 6)', 'spoken_hi': 'छह'},
        ],
      };
    } else if (id == 'g2_math_02') {
      return {
        'visual': '🖐️  ➖  ✌️  =  3️⃣',
        'visual_label': '5 Birds - 2 Flew Away = 3 Left',
        'key_script': 'ᱢᱚᱬᱮ - ᱵᱟᱨ = ᱯᱮ (३)',
        'phonetic': 'मोणे - बार = पे (५ - २ = ३)',
        'student_prompt_sat': 'ᱢᱚᱬᱮ ᱠᱷᱚᱱ ᱵᱟᱨ ᱪᱟᱞᱟᱣ ᱮᱱ ᱠᱷᱟᱱ ᱥᱟᱨᱮᱲ ᱮᱱᱟ ᱯᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱡᱚᱠᱷᱚᱱ ᱡᱟᱦᱟᱸᱱᱟᱜ ᱠᱷᱚᱱ ᱵᱚᱱ ᱵᱷᱮᱜᱟᱨ ᱠᱟᱜ-ᱟ, ᱚᱱᱟ ᱫᱚ ᱜᱷᱟᱴᱟᱣ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ! ᱡᱮᱞᱮᱠᱟ ᱫᱟᱨᱮ ᱰᱟᱹᱨ ᱨᱮ ᱢᱚᱬᱮ ᱜᱚᱴᱟᱝ ᱪᱮᱬᱮ ᱠᱚ ᱫᱩᱲᱩᱵ ᱞᱮᱱᱟ᱾ ᱚᱱᱟ ᱠᱷᱚᱱ ᱵᱟᱨᱭᱟ ᱪᱮᱬᱮ ᱩᱰᱟᱹᱣ ᱮᱱᱟ, ᱛᱚᱵᱮ ᱛᱤᱱᱟᱹᱜ ᱥᱟᱨᱮᱲ ᱮᱱᱟ? ᱢᱚᱬᱮ ᱠᱷᱚᱱ ᱵᱟᱨ ᱪᱟᱞᱟᱣ ᱮᱱ ᱠᱷᱟᱱ ᱯᱮ ᱥᱟᱨᱮᱲ ᱮᱱᱟ! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱢᱮᱱ ᱯᱮ: ᱢᱚᱬᱮ ᱠᱷᱚᱱ ᱵᱟᱨ, ᱯᱮ!',
        'teacher_narration_hi': 'प्यारे बच्चों, जब हम किसी चीज़ को अलग कर देते हैं, तो उसे घटाव कहते हैं! जैसे पेड़ की डाल पर ५ चिड़ियाँ बैठी थीं। उनमें से २ उड़ गईं, तो कितनी बचीं? पाँच में से दो घटाएँगे, तो तीन बचेंगी! संथाली में बोलें: मोणे खोन बार, पे!',
        'teacher_narration_bilingual': 'ᱢᱚᱬᱮ ᱠᱷᱚᱱ ᱵᱟᱨ ᱪᱮᱬᱮ ᱩᱰᱟᱹᱣ ᱮᱱ ᱠᱷᱟᱱ ᱥᱟᱨᱮᱲ ᱮᱱᱟ ᱯᱮ! यानी बच्चों, ५ में से २ घटाने पर ३ बचता है!',
        'teacher_prompt': '५ कंकड़ रखें, २ कंकड़ हटा लें और बच्चों से पूछें: "अब कितने बचे? ५ - २ = ३ (ᱯᱮ)!"',
        'quiz_question': 'Q. ५ चिड़ियों में से २ उड़ गईं, तो पेड़ पर कितनी बचीं?',
        'quiz_question_sat': 'ᱢᱚᱬᱮ ᱠᱷᱚᱱ ᱵᱟᱨ ᱪᱮᱬᱮ ᱩᱰᱟᱹᱣ ᱮᱱ ᱠᱷᱟᱱ ᱛᱤᱱᱟᱹᱜ ᱥᱟᱨᱮᱲ ᱮᱱᱟ?',
        'quiz_options': [
          {'text': '३ (तीन / ᱯᱮ)', 'correct': true, 'spoken_sat': 'ᱯᱮ (Pe - 3)', 'spoken_hi': 'तीन'},
          {'text': '२ (ᱵᱟᱨ)', 'correct': false, 'spoken_sat': 'ᱵᱟᱨ (Bar - 2)', 'spoken_hi': 'दो'},
          {'text': '४ (ᱯᱩᱱ)', 'correct': false, 'spoken_sat': 'ᱯᱩᱱ (Pun - 4)', 'spoken_hi': 'चार'},
        ],
      };
    } else if (id == 'g2_math_03') {
      return {
        'visual': '🪙 💵 🏪',
        'visual_label': 'Village Haat Market & Currency',
        'key_script': '᱕ ᱴᱟᱠᱟ ᱟᱨ ᱑᱐ ᱴᱟᱠᱟ',
        'phonetic': 'मोणे टाका आर गेल टाका (₹5 & ₹10)',
        'student_prompt_sat': 'ᱢᱚᱬᱮ ᱴᱟᱠᱟ ᱟᱨ ᱜᱮᱞ ᱴᱟᱠᱟ — ᱦᱟᱴ ᱨᱮ ᱠᱤᱨᱤᱧ ᱢᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱡᱚᱠᱷᱚᱱ ᱟᱛᱳ ᱨᱮᱱᱟᱜ ᱦᱟᱴ ᱵᱟᱡᱟᱨ ᱵᱚᱱ ᱪᱟᱞᱟᱜ-ᱟ, ᱡᱤᱱᱤᱥ ᱠᱤᱨᱤᱧ ᱞᱟᱹᱜᱤᱫ ᱴᱟᱠᱟ ᱵᱚᱱ ᱮᱢᱟ! ᱡᱩᱫᱤ ᱵᱟᱨ ᱴᱟᱠᱟ ᱨᱮᱱᱟᱜ ᱯᱮᱱᱥᱤᱞ ᱟᱨ ᱯᱮ ᱴᱟᱠᱟ ᱨᱮᱱᱟᱜ ᱨᱚᱵᱚᱲ ᱮᱢ ᱦᱟᱛᱟᱣ ᱠᱮᱫᱟ, ᱛᱚᱵᱮ ᱵᱟᱨ ᱟᱨ ᱯᱮ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱦᱩᱭᱮᱱᱟ ᱢᱚᱬᱮ ᱴᱟᱠᱟ! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱴᱟᱠᱟ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ: ᱢᱚᱬᱮ ᱴᱟᱠᱟ ᱟᱨ ᱜᱮᱞ ᱴᱟᱠᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, जब हम गाँव के हाट बाज़ार जाते हैं, तो चीज़ें खरीदने के लिए रुपये देते हैं। अगर आपने ₹२ की पेंसिल ली और ₹३ की रबर ली, तो २ में ३ जोड़कर कुल ५ रुपये हुए! संथाली में रुपये को टाका कहते हैं, जैसे ५ रुपये को मोणे टाका और १० रुपये को गेल टाका!',
        'teacher_narration_bilingual': 'ᱦᱟᱴ ᱨᱮ ᱠᱤᱨᱤᱧ ᱞᱟᱹᱜᱤᱫ ᱴᱟᱠᱟ ᱞᱟᱹᱠᱛᱤ ᱠᱟᱱᱟ! यानी बच्चों, बाज़ार में सामान खरीदने के लिए हम रुपये यानी टाका का उपयोग करते हैं!',
        'teacher_prompt': 'सिक्के दिखाकर कहें: "हाट में ₹२ की पेंसिल और ₹३ की रबर ली, तो कुल ५ रुपये (ᱢᱚᱬᱮ ᱴᱟᱠᱟ) दिए।"',
        'quiz_question': 'Q. ₹२ की पेंसिल और ₹३ की रबर का कुल मूल्य कितना होगा?',
        'quiz_question_sat': 'ᱵᱟᱨ ᱴᱟᱠᱟ ᱟᱨ ᱯᱮ ᱴᱟᱠᱟ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱛᱤᱱᱟᱹᱜ ᱴᱟᱠᱟ ᱦᱩᱭᱩᱜ-ᱟ?',
        'quiz_options': [
          {'text': '₹४ (ᱯᱩᱱ ᱴᱟᱠᱟ)', 'correct': false, 'spoken_sat': 'ᱯᱩᱱ ᱴᱟᱠᱟ (Pun Taka - ₹4)', 'spoken_hi': 'चार रुपये'},
          {'text': '₹५ (पाँच रुपये / ᱢᱚᱬᱮ ᱴᱟᱠᱟ)', 'correct': true, 'spoken_sat': 'ᱢᱚᱬᱮ ᱴᱟᱠᱟ (Mone Taka - ₹5)', 'spoken_hi': 'पाँच रुपये'},
          {'text': '₹६ (ᱛᱩᱨᱩᱭ ᱴᱟᱠᱟ)', 'correct': false, 'spoken_sat': 'ᱛᱩᱨᱩᱭ ᱴᱟᱠᱟ (Turuy Taka - ₹6)', 'spoken_hi': 'छह रुपये'},
        ],
      };
    } else if (id == 'g2_lang_01') {
      return {
        'visual': '🦊  🍇  🏺',
        'visual_label': 'Clever Fox & Thirsty Crow',
        'key_script': 'ᱪᱟᱞᱟᱠ ᱛᱩᱭᱩ ᱟᱨ ᱠᱟᱣᱟ',
        'phonetic': 'चालाक तुयु आर कावा (लोमड़ी और कौवा)',
        'student_prompt_sat': 'ᱪᱟᱞᱟᱠ ᱛᱩᱭᱩ ᱟᱨ ᱠᱟᱣᱟ — ᱫᱷᱤᱨᱤ ᱛᱮ ᱫᱟᱜ ᱪᱮᱛᱟᱱ ᱮᱱᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱢᱤᱫ ᱫᱷᱟᱣ ᱢᱤᱫ ᱠᱟᱣᱟ ᱟᱹᱰᱤ ᱛᱮᱛᱟᱝ ᱞᱮᱫᱮᱭᱟ! ᱩᱱᱤ ᱫᱚ ᱢᱤᱫ ᱪᱩᱠᱲᱤ ᱨᱮ ᱫᱟᱜ ᱮ ᱧᱮᱞ ᱠᱮᱫᱟ, ᱢᱮᱱᱠᱷᱟᱱ ᱫᱟᱜ ᱫᱚ ᱟᱹᱰᱤ ᱞᱟᱛᱟᱨ ᱨᱮ ᱛᱟᱦᱮᱸ ᱠᱟᱱᱟ᱾ ᱠᱟᱣᱟ ᱫᱚ ᱟᱡᱟᱜ ᱵᱩᱫᱷᱤ ᱛᱮ ᱢᱤᱫ-ᱢᱤᱫ ᱛᱮ ᱫᱷᱤᱨᱤ ᱪᱩᱠᱲᱤ ᱨᱮ ᱜᱤᱰᱤ ᱠᱮᱫᱟ, ᱫᱟᱜ ᱪᱮᱛᱟᱱ ᱨᱟᱠᱟᱵ ᱮᱱᱟ ᱟᱨ ᱩᱱᱤ ᱫᱟᱜ ᱮ ᱧᱩ ᱠᱮᱫᱟ! ᱠᱟᱣᱟ ᱫᱚ ᱪᱟᱞᱟᱠ ᱮ ᱛᱟᱦᱮᱸ ᱠᱟᱱᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, एक बार एक कौवा बहुत प्यासा था! उसने एक घड़ा देखा, लेकिन घड़े में पानी बहुत नीचे था। कौवे ने अपनी सूझबूझ से एक-एक कंकड़ घड़े में डाला, जिससे पानी ऊपर आ गया और उसने पानी पी लिया! संथाली में कौवे को कावा और कंकड़ को दहीरी कहते हैं!',
        'teacher_narration_bilingual': 'ᱪᱟᱞᱟᱠ ᱠᱟᱣᱟ ᱫᱚ ᱫᱷᱤᱨᱤ ᱛᱮ ᱫᱟᱜ ᱪᱮᱛᱟᱱ ᱠᱮᱫᱟ! यानी समझदार कौवे ने कंकड़ डालकर पानी ऊपर पहुँचाया!',
        'teacher_prompt': 'चित्र दिखाकर पूछें: "कौवे ने घड़े में पानी पीने के लिए क्या तरकीब निकाली?"',
        'quiz_question': 'Q. प्यासे कौवे ने घड़े में पानी ऊपर लाने के लिए क्या डाला?',
        'quiz_question_sat': 'ᱠᱟᱣᱟ ᱫᱚ ᱫᱟᱜ ᱪᱮᱛᱟᱱ ᱚᱰᱚᱠ ᱞᱟᱹᱜᱤᱫ ᱪᱮᱫ ᱮ ᱜᱤᱰᱤ ᱠᱮᱫᱟ?',
        'quiz_options': [
          {'text': 'दहीरी (कंकड़ / ᱫᱷᱤᱨᱤ)', 'correct': true, 'spoken_sat': 'ᱫᱷᱤᱨᱤ (Dhiri - कंकड़)', 'spoken_hi': 'कंकड़ (दहीरी)'},
          {'text': 'पत्ते (ᱥᱟᱠᱟᱢ)', 'correct': false, 'spoken_sat': 'ᱥᱟᱠᱟᱢ (Sakam - पत्ते)', 'spoken_hi': 'पत्ते'},
          {'text': 'फूल (ᱵᱟᱦᱟ)', 'correct': false, 'spoken_sat': 'ᱵᱟᱦᱟ (Baha - फूल)', 'spoken_hi': 'फूल'},
        ],
      };
    } else if (id == 'g2_lang_02') {
      return {
        'visual': '🏃  📖  ✍️',
        'visual_label': 'Action Verbs: Read, Write, Sit',
        'key_script': 'ᱯᱟᱲᱦᱟᱣ ᱢᱮ ᱟᱨ ᱚᱞ ᱢᱮ',
        'phonetic': 'पढ़ाव मे आर ओल मे (पढ़ो और लिखो)',
        'student_prompt_sat': 'ᱯᱟᱲᱦᱟᱣ ᱢᱮ ᱟᱨ ᱚᱞ ᱢᱮ — ᱯᱩᱛᱷᱤ ᱯᱟᱲᱦᱟᱣ ᱢᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱥᱲᱟ ᱨᱮ ᱡᱚᱠᱷᱚᱱ ᱫᱤᱫᱤ ᱥᱮ ᱢᱟᱪᱮᱛ ᱮ ᱢᱮᱱᱟ ᱯᱩᱛᱷᱤ ᱯᱟᱲᱦᱟᱣ ᱢᱮ, ᱚᱱᱟ ᱫᱚ ᱯᱟᱲᱦᱟᱣ ᱢᱮ ᱠᱟᱱᱟ! ᱟᱨ ᱡᱚᱠᱷᱚᱱ ᱥᱞᱮᱴ ᱨᱮ ᱚᱞ ᱞᱟᱹᱜᱤᱫ ᱮ ᱢᱮᱱᱟ, ᱚᱱᱟ ᱫᱚ ᱚᱞ ᱢᱮ! ᱯᱟᱲᱦᱟᱣ ᱢᱮ ᱟᱨ ᱚᱞ ᱢᱮ, ᱱᱚᱶᱟ ᱛᱮᱜᱮ ᱟᱵᱚ ᱥᱮᱪᱮᱫ ᱵᱚᱱ ᱦᱟᱢᱮᱴᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, स्कूल में जब दीदी कहती हैं किताब खोलो और पढ़ो, तो संथाली में कहते हैं पुथी पढ़ाव मे! और जब स्लेट या कॉपी पर लिखने को कहें, तो कहते हैं ओल मे! यानी पढ़ना मतलब पढ़ाव मे, और लिखना मतलब ओल मे!',
        'teacher_narration_bilingual': 'ᱯᱩᱛᱷᱤ ᱯᱟᱲᱦᱟᱣ ᱢᱮ ᱟᱨ ᱚᱞ ᱢᱮ! यानी बच्चों, किताब पढ़ो और सुंदर अक्षरों में लिखो!',
        'teacher_prompt': 'क्रिया करके दिखाएं: "किताब खोलकर पढ़ो (ᱯᱟᱲᱦᱟᱣ ᱢᱮ) और स्लेट पर लिखो (ᱚᱞ ᱢᱮ)!"',
        'quiz_question': 'Q. "किताब पढ़ो" के लिए सही संथाली निर्देश क्या है?',
        'quiz_question_sat': 'ᱯᱩᱛᱷᱤ ᱯᱟᱲᱦᱟᱣ ᱢᱮ ᱞᱟᱹᱜᱤᱫ ᱥᱟᱹᱨᱤ ᱠᱟᱛᱷᱟ ᱚᱠᱟ ᱠᱟᱱᱟ?',
        'quiz_options': [
          {'text': 'ᱯᱩᱛᱷᱤ ᱯᱟᱲᱦᱟᱣ ᱢᱮ (Puthi parhao me)', 'correct': true, 'spoken_sat': 'ᱯᱩᱛᱷᱤ ᱯᱟᱲᱦᱟᱣ ᱢᱮ (Puthi parhao me)', 'spoken_hi': 'किताब पढ़ो'},
          {'text': 'ᱫᱟᱹᱲ ᱢᱮ (दौड़ो)', 'correct': false, 'spoken_sat': 'ᱫᱟᱹᱲ ᱢᱮ (Dar me - दौड़ो)', 'spoken_hi': 'दौड़ो'},
          {'text': 'ᱡᱤᱛᱠᱟᱹᱨ (जीतो)', 'correct': false, 'spoken_sat': 'ᱡᱤᱛᱠᱟᱹᱨ (Jitkar - जीतो)', 'spoken_hi': 'जीतो'},
        ],
      };
    } else if (id == 'g2_evs_01') {
      return {
        'visual': '🐄  🐐  🐅',
        'visual_label': 'Cow, Goat & Jungle Tiger',
        'key_script': 'ᱜᱟᱹᱭ, ᱢᱮᱨᱚᱢ ᱟᱨ ᱛᱟᱹᱨᱩᱵ',
        'phonetic': 'गई, मेरोम आर तारुब',
        'student_prompt_sat': 'ᱜᱟᱹᱭ ᱟᱨ ᱢᱮᱨᱚᱢ — ᱜᱟᱹᱭ ᱫᱚ ᱛᱚᱣᱟ ᱮᱢᱚᱜ-ᱟ, ᱛᱟᱹᱨᱩᱵ ᱫᱚ ᱵᱤᱨ ᱨᱮ ᱛᱟᱦᱮᱸᱱᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱵᱚᱣᱟᱜ ᱚᱲᱟᱜ ᱟᱰᱮ-ᱯᱟᱥᱮ ᱡᱟᱦᱟᱸ ᱡᱤᱵᱽ ᱡᱤᱭᱟᱹᱞᱤ ᱠᱚ ᱛᱟᱦᱮᱸᱱᱟ, ᱡᱮᱞᱮᱠᱟ ᱜᱟᱹᱭ ᱟᱨ ᱢᱮᱨᱚᱢ, ᱩᱱᱠᱩ ᱫᱚ ᱟᱹᱥᱩᱞ ᱡᱤᱵᱽ ᱠᱟᱱᱟᱠᱚ! ᱜᱟᱹᱭ ᱫᱚ ᱟᱵᱚ ᱛᱚᱣᱟ ᱮ ᱮᱢᱟᱵᱚᱱᱟ, ᱟᱨ ᱵᱤᱨ ᱨᱮ ᱛᱟᱦᱮᱸᱱᱤᱡ ᱠᱩᱞ ᱫᱚ ᱛᱟᱹᱨᱩᱵ ᱵᱚᱱ ᱢᱮᱛᱟᱭᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, हमारे घर के आस-पास जो जानवर रहते हैं, जैसे गाय और बकरी, वे पालतू होते हैं। गाय को संथाली में गई और बकरी को मेरोम कहते हैं, जो हमें मीठा दूध देती हैं। और जंगल में रहने वाले बाघ को तारुब कहते हैं!',
        'teacher_narration_bilingual': 'ᱜᱟᱹᱭ ᱫᱚ ᱟᱹᱥᱩᱞ ᱡᱤᱵᱽ ᱠᱟᱱᱟᱭ ᱟᱨ ᱛᱟᱹᱨᱩᱵ ᱫᱚ ᱵᱤᱨ ᱨᱮ! यानी गाय पालतू पशु है और बाघ जंगल का राजा है!',
        'teacher_prompt': 'जानवरों के चित्र दिखाएं: "गाय (ᱜᱟᱹᱭ) और बकरी (ᱢᱮᱨᱚᱢ) पालतू हैं, बाघ (ᱛᱟᱹᱨᱩᱵ) जंगल का राजा है।"',
        'quiz_question': 'Q. इनमें से कौन सा पशु पालतू (दूध देने वाला) है?',
        'quiz_question_sat': 'ᱛᱚᱣᱟ ᱮᱢᱚᱜ ᱟᱹᱥᱩᱞ ᱡᱤᱵᱽ ᱚᱠᱚᱭ ᱠᱟᱱᱟᱭ?',
        'quiz_options': [
          {'text': '🐄 गाय (ᱜᱟᱹᱭ / Gai)', 'correct': true, 'spoken_sat': 'ᱜᱟᱹᱭ (Gai - गाय)', 'spoken_hi': 'गाय (गई)'},
          {'text': '🐅 बाघ (ᱛᱟᱹᱨᱩᱵ / Tarub)', 'correct': false, 'spoken_sat': 'ᱛᱟᱹᱨᱩᱵ (Tarub - बाघ)', 'spoken_hi': 'बाघ (तारुब)'},
          {'text': '🐘 जंगली हाथी (ᱦᱟᱹᱛᱤ)', 'correct': false, 'spoken_sat': 'ᱦᱟᱹᱛᱤ (Hati - हाथी)', 'spoken_hi': 'हाथी'},
        ],
      };
    } else if (id == 'g2_evs_02') {
      return {
        'visual': '🌾  👨‍🌾  🩺',
        'visual_label': 'Village Farmer & Community Helpers',
        'key_script': 'ᱪᱟᱥᱤ ᱟᱨ ᱢᱟᱪᱮᱛ',
        'phonetic': 'चासी आर माचेत (किसान और शिक्षक)',
        'student_prompt_sat': 'ᱪᱟᱥᱤ ᱟᱨ ᱢᱟᱪᱮᱛ — ᱪᱟᱥᱤ ᱫᱚ ᱦᱳᱲᱳ ᱮ ᱨᱚᱦᱚᱭᱟ, ᱢᱟᱪᱮᱛ ᱫᱚ ᱥᱮᱪᱮᱫ ᱮ ᱮᱢᱟᱵᱚᱱᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱵᱚ ᱟᱛᱳ ᱨᱮ ᱪᱟᱥᱤ ᱵᱟᱵᱟ ᱠᱷᱮᱛ ᱨᱮ ᱠᱟᱹᱢᱤ ᱠᱟᱛᱮ ᱦᱳᱲᱳ, ᱡᱚᱱᱚᱲᱟ ᱟᱨ ᱩᱛᱩ ᱟᱲᱟᱜ ᱮ ᱪᱟᱥᱟ! ᱟᱨ ᱟᱥᱲᱟ ᱨᱮ ᱡᱟᱦᱟᱸᱭ ᱫᱩᱞᱟᱹᱲ ᱛᱮ ᱥᱮᱪᱮᱫ ᱮ ᱮᱢᱟᱵᱚᱱᱟ, ᱩᱱᱤ ᱫᱚ ᱢᱟᱪᱮᱛ ᱵᱚᱱ ᱢᱮᱛᱟᱭᱟ! ᱪᱟᱥᱤ ᱟᱨ ᱢᱟᱪᱮᱛ ᱫᱚ ᱟᱵᱚᱣᱟᱜ ᱜᱚᱲᱚᱣᱟᱱ ᱠᱟᱱᱟᱠᱚ!',
        'teacher_narration_hi': 'प्यारे बच्चों, हमारे गाँव में किसान खेतों में मेहनत करके धान, मकई और हरी सब्ज़ियाँ उगाते हैं! किसान को संथाली में चासी कहते हैं। और जो आपको स्कूल में प्यार से पढ़ाते हैं, उन शिक्षक को माचेत कहते हैं!',
        'teacher_narration_bilingual': 'ᱪᱟᱥᱤ ᱫᱚ ᱦᱳᱲᱳ ᱮ ᱨᱚᱦᱚᱭᱟ, ᱢᱟᱪᱮᱛ ᱫᱚ ᱥᱮᱪᱮᱫ ᱮ ᱮᱢᱟᱵᱚᱱᱟ! यानी किसान हमें अन्न देते हैं और शिक्षक हमें ज्ञान देते हैं!',
        'teacher_prompt': 'गाँव के मददगारों के चित्र दिखाकर कहें: "किसान (ᱪᱟᱥᱤ) हमें अन्न देते हैं और शिक्षक (ᱢᱟᱪᱮᱛ) ज्ञान देते हैं।"',
        'quiz_question': 'Q. खेत में धान और सब्जियाँ उगाने वाले हमारे मददगार कौन हैं?',
        'quiz_question_sat': 'ᱦᱳᱲᱳ ᱟᱨ ᱩᱛᱩ ᱨᱚᱦᱚᱭ ᱦᱚᱲ ᱚᱠᱚᱭ ᱠᱟᱱᱟᱭ?',
        'quiz_options': [
          {'text': '🌾 किसान (ᱪᱟᱥᱤ / Chasi)', 'correct': true, 'spoken_sat': 'ᱪᱟᱥᱤ (Chasi - किसान)', 'spoken_hi': 'किसान (चासी)'},
          {'text': 'कुम्हार (ᱠᱩᱢᱦᱟᱹᱨ)', 'correct': false, 'spoken_sat': 'ᱠᱩᱢᱦᱟᱹᱨ (Kumhar - कुम्हार)', 'spoken_hi': 'कुम्हार'},
          {'text': 'दुकानदार', 'correct': false, 'spoken_sat': 'ᱫᱳᱠᱟᱱᱫᱟᱨ (Dokandar)', 'spoken_hi': 'दुकानदार'},
        ],
      };
    } else if (id == 'g3_math_01') {
      return {
        'visual': '2️⃣ ➕ 2️⃣ ➕ 2️⃣  =  6️⃣',
        'visual_label': '3 Groups of 2 = 6 (Multiplication)',
        'key_script': '᱓ × ᱒ = ᱖ (ᱛᱩᱨᱩᱭ)',
        'phonetic': 'पे धाव बार = तुरुय (३ × २ = ६)',
        'student_prompt_sat': 'ᱯᱮ ᱫᱷᱟᱣ ᱵᱟᱨ — ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱛᱩᱨᱩᱭ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱜᱩᱬᱟᱹᱱ ᱨᱮᱱᱟᱜ ᱢᱮᱱᱮᱛ ᱫᱚ ᱠᱟᱱᱟ ᱢᱤᱫᱴᱟᱹᱝ ᱞᱮᱠᱷᱟ ᱜᱮ ᱵᱟᱨ-ᱵᱟᱨ ᱢᱮᱥᱟ! ᱡᱮᱞᱮᱠᱟ ᱟᱢ ᱴᱷᱮᱱ ᱵᱟᱨᱭᱟ-ᱵᱟᱨᱭᱟ ᱡᱚ ᱨᱮᱱᱟᱜ ᱯᱮᱭᱟ ᱛᱷᱟᱹᱨᱤ ᱢᱮᱱᱟᱜ-ᱟ᱾ ᱯᱩᱭᱞᱩ ᱨᱮ ᱵᱟᱨ, ᱫᱚᱥᱟᱨ ᱨᱮ ᱵᱟᱨ, ᱟᱨ ᱛᱮᱥᱟᱨ ᱨᱮ ᱵᱟᱨ! ᱵᱟᱨ ᱫᱚ ᱯᱮ ᱫᱷᱟᱣ ᱢᱮᱥᱟ ᱞᱮᱠᱷᱟᱱ: ᱵᱟᱨ, ᱯᱩᱱ, ᱟᱨ ᱛᱩᱨᱩᱭ! ᱯᱮ ᱜᱩᱬᱟᱹᱱ ᱵᱟᱨ ᱦᱩᱭᱩᱜ-ᱟ ᱛᱩᱨᱩᱭ!',
        'teacher_narration_hi': 'प्यारे बच्चों, गुणा का मतलब होता है एक ही संख्या को बार-बार जोड़ना! जैसे मान लीजिए आपके पास २-२ बेर की ३ कटोरियाँ हैं। पहली कटोरी में २, दूसरी में २, तीसरी में २। तो २ को ३ बार जोड़ेंगे: २, ४, और ६! यानी ३ गुणा २ बराबर ६ होता है!',
        'teacher_narration_bilingual': 'ᱯᱮ ᱫᱷᱟᱣ ᱵᱟᱨ ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱦᱩᱭᱩᱜ-ᱟ ᱛᱩᱨᱩᱭ! यानी २ को ३ बार इकट्ठा करने पर कुल ६ बनता है!',
        'teacher_prompt': '२-२ पत्तों के ३ समूह रखें और बच्चों से कहें: "२ को ३ बार जोड़ने पर ६ बनता है (३ × २ = ६)!"',
        'quiz_question': 'Q. २ के ३ समूह (३ × २) में कुल कितनी संख्या होगी?',
        'quiz_question_sat': 'ᱯᱮ ᱫᱷᱟᱣ ᱵᱟᱨ (᱓ × ᱒) ᱢᱮᱥᱟ ᱠᱟᱛᱮ ᱛᱤᱱᱟᱹᱜ ᱦᱩᱭᱩᱜ-ᱟ?',
        'quiz_options': [
          {'text': '५ (ᱢᱚᱬᱮ)', 'correct': false, 'spoken_sat': 'ᱢᱚᱬᱮ (Mone - 5)', 'spoken_hi': 'पाँच'},
          {'text': '६ (छह / ᱛᱩᱨᱩᱭ)', 'correct': true, 'spoken_sat': 'ᱛᱩᱨᱩᱭ (Turuy - 6)', 'spoken_hi': 'छह'},
          {'text': '८ (ᱤᱨᱟᱹᱞ)', 'correct': false, 'spoken_sat': 'ᱤᱨᱟᱹᱞ (Iral - 8)', 'spoken_hi': 'आठ'},
        ],
      };
    } else if (id == 'g3_math_02') {
      return {
        'visual': '⏰  🕒  📅',
        'visual_label': 'Clock & 7 Days of Week',
        'key_script': 'ᱯᱮ ᱴᱟᱲᱟᱝ (३ बजे)',
        'phonetic': 'पे ताड़ांग (३ बजे)',
        'student_prompt_sat': 'ᱯᱮ ᱴᱟᱲᱟᱝ — ᱱᱤᱛᱚᱜ ᱯᱮ ᱴᱟᱲᱟᱝ ᱵᱟᱡᱟᱣ ᱮᱱᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱜᱷᱩᱲᱤ ᱨᱮ ᱵᱟᱨᱭᱟ ᱠᱟᱹᱴᱩᱵ ᱛᱟᱦᱮᱸᱱᱟ᱾ ᱦᱩᱰᱤᱧ ᱠᱟᱹᱴᱩᱵ ᱫᱚ ᱴᱟᱲᱟᱝ ᱮ ᱩᱫᱩᱜᱟ ᱟᱨ ᱢᱟᱨᱟᱝ ᱠᱟᱹᱴᱩᱵ ᱫᱚ ᱢᱤᱱᱤᱴ! ᱡᱚᱠᱷᱚᱱ ᱦᱩᱰᱤᱧ ᱠᱟᱹᱴᱩᱵ ᱯᱮ ᱨᱮ ᱟᱨ ᱢᱟᱨᱟᱝ ᱠᱟᱹᱴᱩᱵ ᱜᱮᱞ ᱵᱟᱨ ᱨᱮ ᱛᱟᱦᱮᱸᱱᱟ, ᱩᱱ ᱫᱚ ᱯᱮ ᱴᱟᱲᱟᱝ ᱵᱟᱡᱟᱣ ᱮᱱᱟ ᱵᱚᱱ ᱢᱮᱛᱟᱜ-ᱟ! ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ: ᱯᱮ ᱴᱟᱲᱟᱝ!',
        'teacher_narration_hi': 'प्यारे बच्चों, दीवार घड़ी में दो मुख्य सुइयाँ होती हैं। छोटी सुई घंटे बताती है और बड़ी सुई मिनट! जब छोटी सुई ३ पर हो और बड़ी सुई १२ पर हो, तो उसे ३ बजना कहते हैं! संथाली में इसे पे ताड़ांग कहते हैं!',
        'teacher_narration_bilingual': 'ᱱᱤᱛᱚᱜ ᱯᱮ ᱴᱟᱲᱟᱝ ᱵᱟᱡᱟᱣ ᱮᱱᱟ! यानी बच्चों, अभी दोपहर के ३ बजे हैं!',
        'teacher_prompt': 'घड़ी की सुइयां दिखाते हुए कहें: "छोटी सुई ३ पर और बड़ी सुई १२ पर है, यानी अभी ३ बजे (ᱯᱮ ᱴᱟᱲᱟᱝ) हैं।"',
        'quiz_question': 'Q. छोटी सुई ३ पर और बड़ी सुई १२ पर हो तो कितने बजे हैं?',
        'quiz_question_sat': 'ᱯᱮ ᱴᱟᱲᱟᱝ ᱵᱟᱡᱟᱣ ᱞᱟᱹᱜᱤᱫ ᱚᱠᱟ ᱥᱟᱹᱨᱤ ᱠᱟᱱᱟ?',
        'quiz_options': [
          {'text': '३ बजे (ᱯᱮ ᱴᱟᱲᱟᱝ / Pe Tarang)', 'correct': true, 'spoken_sat': 'ᱯᱮ ᱴᱟᱲᱟᱝ (Pe Tarang - 3 बजे)', 'spoken_hi': 'तीन बजे'},
          {'text': '१२ बजे (ᱜᱮᱞ ᱵᱟᱨ ᱴᱟᱲᱟᱝ)', 'correct': false, 'spoken_sat': 'ᱜᱮᱞ ᱵᱟᱨ ᱴᱟᱲᱟᱝ (Gel Bar Tarang)', 'spoken_hi': 'बारह बजे'},
          {'text': '६ बजे (ᱛᱩᱨᱩᱭ ᱴᱟᱲᱟᱝ)', 'correct': false, 'spoken_sat': 'ᱛᱩᱨᱩᱭ ᱴᱟᱲᱟᱝ (Turuy Tarang)', 'spoken_hi': 'छह बजे'},
        ],
      };
    } else if (id == 'g3_lang_01') {
      return {
        'visual': '📜  🐘  🐦',
        'visual_label': 'Elephant & Sparrow Folktale',
        'key_script': 'ᱦᱟᱹᱛᱤ ᱟᱨ ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ',
        'phonetic': 'हाती आर टीठी चेंणे',
        'student_prompt_sat': 'ᱦᱟᱹᱛᱤ ᱟᱨ ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ — ᱵᱟᱱᱟᱨ ᱜᱟᱛᱮ ᱠᱟᱱᱟᱠᱤᱱ, ᱢᱤᱫᱴᱟᱹᱝ ᱜᱮ ᱵᱤᱨ ᱨᱮ ᱠᱤᱱ ᱛᱟᱦᱮᱸᱱᱟ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱱᱚᱶᱟ ᱫᱚ ᱢᱤᱫ ᱢᱟᱨᱟᱝ ᱦᱟᱹᱛᱤ ᱟᱨ ᱦᱩᱰᱤᱧ ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ ᱨᱮᱱᱟᱜ ᱠᱟᱹᱦᱱᱤ ᱠᱟᱱᱟ! ᱦᱟᱹᱛᱤ ᱫᱚ ᱟᱹᱰᱤ ᱢᱟᱨᱟᱝ ᱮ ᱛᱟᱦᱮᱸ ᱠᱟᱱᱟ, ᱢᱮᱱᱠᱷᱟᱱ ᱡᱚᱠᱷᱚᱱ ᱟᱱᱟᱴ ᱦᱮᱡ ᱮᱱᱟ, ᱦᱩᱰᱤᱧ ᱪᱮᱬᱮ ᱟᱡᱟᱜ ᱫᱤᱞ ᱛᱮ ᱦᱟᱹᱛᱤ ᱮ ᱵᱟᱧᱪᱟᱣ ᱠᱮᱫᱮᱭᱟ! ᱥᱟᱹᱨᱤ ᱜᱟᱛᱮ ᱨᱮ ᱚᱠᱚᱭ ᱦᱚᱸ ᱦᱩᱰᱤᱧ ᱥᱮ ᱢᱟᱨᱟᱝ ᱵᱟᱹᱱᱩᱜ ᱠᱚᱣᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, यह कहानी है एक विशाल हाथी और एक नन्हीं गौरैया की! आकार में हाथी भले ही बहुत बड़ा था, पर जब मुश्किल आई तो नन्हीं गौरैया ने अपनी हिम्मत से हाथी की जान बचाई। सच्ची दोस्ती में कोई छोटा या बड़ा नहीं होता! संथाली में हाथी को हाती और चिड़िया को चेंणे कहते हैं!',
        'teacher_narration_bilingual': 'ᱦᱟᱹᱛᱤ ᱟᱨ ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ ᱨᱮᱱᱟᱜ ᱥᱟᱹᱨᱤ ᱜᱟᱛᱮ ᱠᱟᱹᱦᱱᱤ! यानी सच्चे दोस्त हर मुश्किल में एक-दूसरे का साथ निभाते हैं!',
        'teacher_prompt': 'कहानी का अनुच्छेद पढ़ें: "एक विशाल जंगल में हाथी और गौरैया रहते थे। संकट के समय दोनों ने एक-दूसरे की मदद की।"',
        'quiz_question': 'Q. लोककथा में हाथी का सच्चा और साहसी मित्र कौन था?',
        'quiz_question_sat': 'ᱦᱟᱹᱛᱤ ᱨᱤᱱᱤᱡ ᱥᱟᱹᱨᱤ ᱜᱟᱛᱮ ᱚᱠᱚᱭ ᱠᱟᱱᱟᱭ?',
        'quiz_options': [
          {'text': '🐦 गौरैया (ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ / Tithi Chenye)', 'correct': true, 'spoken_sat': 'ᱴᱤᱴᱦᱤ ᱪᱮᱬᱮ (Tithi Chenye - गौरैया)', 'spoken_hi': 'गौरैया'},
          {'text': 'लोमड़ी (ᱛᱩᱭᱩ)', 'correct': false, 'spoken_sat': 'ᱛᱩᱭᱩ (Tuyu - लोमड़ी)', 'spoken_hi': 'लोमड़ी'},
          {'text': 'भालू (ᱵᱟᱱᱟ)', 'correct': false, 'spoken_sat': 'ᱵᱟᱱᱟ (Bana - भालू)', 'spoken_hi': 'भालू'},
        ],
      };
    } else if (id == 'g3_evs_01') {
      return {
        'visual': '🌊  🏞️  🚰',
        'visual_label': 'River, Pond & Water Conservation',
        'key_script': 'ᱫᱟᱜ ᱜᱮ ᱡᱤᱣᱤ (जल ही जीवन है)',
        'phonetic': 'दाग गे जीवी (जल ही जीवन है)',
        'student_prompt_sat': 'ᱫᱟᱜ ᱜᱮ ᱡᱤᱣᱤ — ᱫᱟᱜ ᱫᱚ ᱡᱚᱜᱟᱣ ᱢᱮ, ᱜᱟᱰᱟ ᱟᱨ ᱯᱩᱠᱷᱩᱨ ᱨᱮ ᱫᱟᱜ ᱫᱚᱦᱚᱭ ᱢᱮ!',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱫᱟᱜ ᱵᱮᱜᱚᱨ ᱚᱠᱚᱭ ᱦᱚᱸ ᱵᱟᱠᱚ ᱵᱟᱧᱪᱟᱣ ᱫᱟᱲᱮᱭᱟᱜ-ᱟ, ᱚᱱᱟᱛᱮ ᱵᱚᱱ ᱢᱮᱱᱟ — ᱫᱟᱜ ᱜᱮ ᱡᱤᱣᱤ! ᱫᱟᱜ ᱡᱟᱹᱲᱤ ᱨᱮᱱᱟᱜ ᱫᱟᱜ ᱫᱚ ᱯᱩᱠᱷᱩᱨ ᱟᱨ ᱠᱷᱮᱛ ᱨᱮ ᱵᱚᱱ ᱡᱚᱜᱟᱣ ᱫᱚᱦᱚᱭᱟ, ᱡᱮᱢᱚᱱ ᱫᱟᱜ ᱨᱮᱱᱟᱜ ᱟᱱᱟᱴ ᱟᱞᱚ ᱦᱩᱭᱩᱜ ᱢᱟ! ᱫᱟᱜ ᱫᱚ ᱟᱵᱚᱣᱟᱜ ᱡᱤᱣᱤ ᱠᱟᱱᱟ!',
        'teacher_narration_hi': 'प्यारे बच्चों, पानी के बिना कोई भी जीवित नहीं रह सकता, इसीलिए कहते हैं - जल ही जीवन है! बारिश के पानी को हमें तालाबों और खेतों में रोकना चाहिए ताकि गर्मियों में पानी की कमी न हो। संथाली में कहते हैं: दाग गे जीवी, यानी पानी ही हमारा जीवन है!',
        'teacher_narration_bilingual': 'ᱫᱟᱜ ᱜᱮ ᱡᱤᱣᱤ — ᱫᱟᱜ ᱫᱚ ᱡᱚᱜᱟᱣ ᱢᱮ! यानी बच्चों, पानी की एक-एक बूँद बहुत अनमोल है, इसे बचा कर रखें!',
        'teacher_prompt': 'नदी और तालाब का चित्र दिखाते हुए कहें: "बारिश के पानी को रोकना और सहेजना हमारे जीवन के लिए अत्यंत महत्वपूर्ण है।"',
        'quiz_question': 'Q. बारिश के पानी को सहेजने और बचाने को क्या कहते हैं?',
        'quiz_question_sat': 'ᱫᱟᱜ ᱡᱚᱜᱟᱣ ᱞᱟᱹᱜᱤᱫ ᱪᱮᱫ ᱠᱟᱹᱢᱤ ᱦᱩᱭᱩᱜ-ᱟ?',
        'quiz_options': [
          {'text': '💧 जल संरक्षण (ᱫᱟᱜ ᱡᱚᱜᱟᱣ)', 'correct': true, 'spoken_sat': 'ᱫᱟᱜ ᱡᱚᱜᱟᱣ (Daag jogaw - जल संरक्षण)', 'spoken_hi': 'जल संरक्षण'},
          {'text': 'पानी बहाना', 'correct': false, 'spoken_sat': 'ᱫᱟᱜ ᱵᱟᱹᱜᱤ', 'spoken_hi': 'पानी बहाना'},
          {'text': 'तालाब सुखाना', 'correct': false, 'spoken_sat': 'ᱯᱩᱠᱷᱩᱨ ᱨᱚᱦᱚᱲ', 'spoken_hi': 'तालाब सुखाना'},
        ],
      };
    } else {
      return {
        'visual': '🌳 🌺 📚',
        'visual_label': 'Classroom Learning',
        'key_script': widget.lesson.titleSat,
        'phonetic': widget.lesson.titleHi,
        'student_prompt_sat': '${widget.lesson.titleSat} — ᱱᱚᱶᱟ ᱫᱚ ᱢᱟᱪᱮᱛ ᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚᱣᱟᱜ ᱯᱟᱴᱷ ᱠᱟᱱᱟ᱾',
        'teacher_narration_sat': 'ᱯᱮᱲᱟ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱛᱮᱦᱮᱧ ᱫᱚ ᱟᱹᱰᱤ ᱨᱟᱹᱥᱠᱟᱹ ᱟᱱ ᱯᱟᱴᱷ ᱵᱚᱱ ᱪᱮᱫᱟ: ${widget.lesson.titleSat}! ᱥᱟᱱᱟᱢ ᱜᱤᱫᱽᱨᱟᱹ ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱸᱡᱚᱢ ᱯᱮ ᱟᱨ ᱤᱧ ᱥᱟᱶ ᱢᱤᱫ ᱛᱮ ᱫᱚᱦᱲᱟᱭ ᱯᱮ!',
        'teacher_narration_hi': 'प्यारे बच्चों, आज हम बहुत ही रोचक पाठ सीखने जा रहे हैं: ${widget.lesson.titleHi}! सब बच्चे ध्यान से सुनेंगे और मेरे साथ मिलकर दोहराएँगे!',
        'teacher_narration_bilingual': '${widget.lesson.titleSat} — ᱱᱚᱶᱟ ᱯᱟᱴᱷ ᱫᱚ ᱢᱟᱪᱮᱛ ᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ ᱞᱟᱹᱜᱤᱫ ᱠᱟᱱᱟ! यानी सब बच्चे प्यार से इस पाठ को सीखेंगे!',
        'teacher_prompt': 'स्थानीय शब्दों और ध्वनियों के साथ बच्चों को मातृभाषा और हिंदी दोनों में दोहराने के लिए प्रेरित करें।',
        'quiz_question': 'Q. क्या सभी बच्चों ने पाठ को ध्यान से सुना?',
        'quiz_question_sat': 'ᱥᱟᱱᱟᱢ ᱜᱤᱫᱽᱨᱟᱹ ᱪᱮᱫ ᱱᱚᱶᱟ ᱯᱟᱴᱷ ᱯᱮ ᱟᱸᱡᱚᱢ ᱠᱮᱫᱟ?',
        'quiz_options': [
          {'text': '👍 हाँ, समझ आ गया (हेँ, बुझाव केदा)', 'correct': true, 'spoken_sat': 'ᱦᱮᱸ, ᱵᱩᱡᱷᱟᱹᱣ ᱠᱮᱫᱟ (हाँ, समझ आ गया)', 'spoken_hi': 'हाँ समझ आ गया'},
          {'text': '🔄 एक बार फिर दोहराएँ', 'correct': false, 'spoken_sat': 'ᱟᱨ ᱢᱤᱫ ᱫᱷᱟᱣ ᱢᱮᱱ ᱢᱮ', 'spoken_hi': 'एक बार फिर दोहराएँ'},
        ],
      };
    }
  }

  void _repeatWithClass(String text) {
    final phrase = _audioMode == LessonAudioMode.santhali
        ? 'ᱟᱹᱰᱤ ᱱᱟᱯᱟᱭ! ᱡᱚᱛᱚ ᱜᱤᱫᱽᱨᱟᱹ ᱢᱤᱫ ᱛᱮ ᱢᱮᱱ ᱯᱮ: $text'
        : (_audioMode == LessonAudioMode.bilingual
            ? 'ᱟᱹᱰᱤ ᱱᱟᱯᱟᱭ! सब बच्चे साथ बोलें: $text'
            : 'शाबाश! सब बच्चे साथ बोलें: $text');
    AudioTtsService.instance.speakClean(phrase, id: 'repeat_${widget.lesson.id}');
    setState(() {
      _playerStars += 1;
    });
    widget.onStarEarned();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🌟 बहुत अच्छा! सब बच्चे साथ बोले! (+1 Star ⭐ कुल सत्र स्टार्स: $_playerStars)',
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

  Future<void> _completeLesson() async {
    setState(() => _isSaving = true);
    widget.onLessonCompleted();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🎉 बधाई! "${widget.lesson.titleHi}" की NIPUN दक्षता पूर्ण हुई!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getLessonPedagogyData();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_lesson, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'कक्षा पाठ: ${widget.lesson.titleHi}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            NaturalAudioButton(
                              textToSpeak: _getSpokenText(
                                sat: widget.lesson.titleSat,
                                hi: 'कक्षा पाठ: ${widget.lesson.titleHi}, ${widget.lesson.grade}',
                                dual: '${widget.lesson.titleSat} • यानी ${widget.lesson.titleHi}',
                              ),
                              speakId: 'player_header_${widget.lesson.id}',
                              isCompact: true,
                              color: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              tooltip: 'पाठ का नाम सुनें',
                            ),
                          ],
                        ),
                        Text(
                          'Ol Chiki: ${widget.lesson.titleSat} • ${widget.lesson.grade}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: AudioTtsService.instance.currentPlayingIdNotifier,
                    builder: (context, playingId, _) {
                      if (playingId == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          onPressed: () => AudioTtsService.instance.stop(),
                          icon: const Icon(Icons.stop_circle_rounded, size: 16, color: Colors.white),
                          label: const Text(
                            'रोकें (Stop)',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.black87, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$_playerStars Stars',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // MTB-MLE Classroom Audio Language Mode Selector Bar
            _buildAudioModeBar(),

            // GRR 3-Step Tab Indicator Bar
            Container(
              color: AppColors.primaryContainer.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  _buildStepTab(0, '1. I Do', 'शिक्षक समझाए'),
                  const Icon(Icons.arrow_right, size: 18, color: AppColors.textSecondary),
                  _buildStepTab(1, '2. We Do', 'साथ दोहराएँ'),
                  const Icon(Icons.arrow_right, size: 18, color: AppColors.textSecondary),
                  _buildStepTab(2, '3. You Do', 'दक्षता जाँच'),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildCurrentStepView(data),
              ),
            ),

            // Sticky Active Audio Status Bar with Stop Button
            ValueListenableBuilder<String?>(
              valueListenable: AudioTtsService.instance.currentPlayingIdNotifier,
              builder: (context, playingId, _) {
                if (playingId == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.red.shade200),
                      bottom: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.graphic_eq_rounded, color: Colors.red, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'ऑडियो चल रहा है... (Audio Playing)',
                          style: TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 1,
                        ),
                        onPressed: () => AudioTtsService.instance.stop(),
                        icon: const Icon(Icons.stop_rounded, size: 18),
                        label: const Text(
                          'ऑडियो रोकें (Stop)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Footer Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: () => setState(() => _currentStep--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('पिछला कदम'),
                    )
                  else
                    const SizedBox.shrink(),
                  if (_currentStep < 2)
                    AppButton(
                      label: _currentStep == 0 ? 'अगला: साथ दोहराएँ ➔' : 'अगला: दक्षता जाँच ➔',
                      icon: Icons.arrow_forward,
                      onPressed: () => setState(() => _currentStep++),
                    )
                  else
                    AppButton(
                      label: _isSaving ? 'सहेज रहे हैं...' : 'दक्षता पूर्ण दर्ज करें ✓',
                      icon: Icons.check_circle,
                      variant: AppButtonVariant.primary,
                      onPressed: _isSaving ? null : _completeLesson,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioModeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7), // Warm pedagogical cream tone
        border: Border(bottom: BorderSide(color: Colors.amber.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.record_voice_over_rounded, size: 16, color: Colors.amber.shade900),
          const SizedBox(width: 6),
          Text(
            'ऑडियो भाषा:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAudioModePill(
                    mode: LessonAudioMode.santhali,
                    label: '🌿 संथाली (छात्र)',
                    tooltip: 'छात्रों की मातृभाषा: संथाली में सुनें',
                  ),
                  const SizedBox(width: 6),
                  _buildAudioModePill(
                    mode: LessonAudioMode.bilingual,
                    label: '🔄 द्विभाषी (सेतु)',
                    tooltip: 'संथाली + हिन्दी द्विभाषी सेतु',
                  ),
                  const SizedBox(width: 6),
                  _buildAudioModePill(
                    mode: LessonAudioMode.hindi,
                    label: '🇮🇳 हिन्दी (शिक्षक)',
                    tooltip: 'शिक्षक मार्गदर्शन: हिन्दी में सुनें',
                  ),
                  const SizedBox(width: 8),
                  Container(height: 14, width: 1, color: Colors.amber.shade300),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'दीदी की सौम्य आवाज़ सुनें (Tap to test voice)',
                    child: InkWell(
                      onTap: () {
                        AudioTtsService.instance.previewTeacherVoice();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🌸 दीदी की सौम्य भारतीय आवाज़ (Warm Indian Female Voice active)'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF48FB1)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face_3_rounded, size: 14, color: Color(0xFFC2185B)),
                            SizedBox(width: 4),
                            Text(
                              'दीदी (आवाज़)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF880E4F),
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.volume_up_rounded, size: 12, color: Color(0xFFC2185B)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioModePill({
    required LessonAudioMode mode,
    required String label,
    required String tooltip,
  }) {
    final isSelected = _audioMode == mode;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _audioMode = mode;
          });
          AudioTtsService.instance.stop();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : Colors.amber.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : Colors.brown.shade800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTab(int stepIndex, String title, String subtitle) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentStep = stepIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : (isDone ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isActive ? Colors.white : (isDone ? AppColors.primary : AppColors.textSecondary),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.white70 : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(Map<String, dynamic> data) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Intro(data);
      case 1:
        return _buildStep2Choral(data);
      case 2:
      default:
        return _buildStep3Quiz(data);
    }
  }

  /// Step 1: I Do (Concept Bridge)
  Widget _buildStep1Intro(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const StatusBadge(label: 'चरण १: शिक्षक की प्रस्तुति (I Do)', color: AppColors.primary),
            const Spacer(),
            const StatusBadge(label: 'मातृभाषा सेतु', color: AppColors.secondary),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Visual Presentation Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade300, width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                data['visual'] as String,
                style: const TextStyle(fontSize: 48),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['visual_label'] as String,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900),
                  ),
                  const SizedBox(width: 6),
                  NaturalAudioButton(
                    textToSpeak: _getSpokenText(
                      sat: '${data['key_script']}, ${data['phonetic']}',
                      hi: data['visual_label'] as String,
                      dual: '${data['key_script']} • यानी ${data['visual_label']}',
                    ),
                    speakId: 'step1_label_${widget.lesson.id}',
                    isCompact: true,
                    tooltip: 'चित्र विवरण सुनें',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                data['key_script'] as String,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Text(
                  'शिक्षक उच्चारण: ${data['phonetic']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber.shade900),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              NaturalAudioButton(
                textToSpeak: _getSpokenText(
                  sat: data['teacher_narration_sat'] as String? ?? data['student_prompt_sat'] as String? ?? '${data['key_script']}, ${data['phonetic']}',
                  hi: data['teacher_narration_hi'] as String? ?? '${data['visual_label']} — ${data['phonetic']}',
                  dual: data['teacher_narration_bilingual'] as String? ?? '${data['student_prompt_sat'] ?? data['key_script']} • यानी ${data['visual_label']}',
                ),
                speakId: 'step1_key_${widget.lesson.id}',
                label: _audioMode == LessonAudioMode.santhali
                    ? 'ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱢᱟᱪᱮᱛ ᱵᱮᱠᱷᱟ (Santhali Explanation)'
                    : (_audioMode == LessonAudioMode.bilingual
                        ? 'द्विभाषी व्याख्या सुनें (Bilingual Audio)'
                        : 'दीदी की तरह समझें (Teacher Explanation)'),
                backgroundColor: AppColors.primary,
                iconSize: 20,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Teacher's Verbal Prompt Script
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'शिक्षक के लिए सुझाव (Teacher Pedagogical Guide):',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            NaturalAudioButton(
              textToSpeak: _getSpokenText(
                sat: data['teacher_narration_sat'] as String? ?? data['student_prompt_sat'] as String? ?? data['key_script'] as String,
                hi: data['teacher_narration_hi'] as String? ?? 'शिक्षक निर्देश: ${data['teacher_prompt']}',
                dual: data['teacher_narration_bilingual'] as String? ?? '${data['student_prompt_sat'] ?? data['key_script']} • ${data['teacher_prompt']}',
              ),
              speakId: 'step1_prompt_${widget.lesson.id}',
              isCompact: true,
              tooltip: _audioMode == LessonAudioMode.santhali ? 'ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱢᱟᱪᱮᱛ ᱵᱮᱠᱷᱟ ᱟᱸᱡᱚᱢ ᱢᱮ' : 'कक्षा व्याख्या सुनें',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['teacher_narration_sat'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.record_voice_over, size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱢᱟᱪᱮᱛ ᱵᱮᱠᱷᱟ (Santhali Storytelling):',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['teacher_narration_sat'] as String,
                  style: const TextStyle(fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const Divider(height: 16),
              ],
              if (data['teacher_narration_hi'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'हिंदी में कक्षा व्याख्या (Hindi Teacher Narrative):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['teacher_narration_hi'] as String,
                  style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
                ),
                const Divider(height: 16),
              ],
              if (data['student_prompt_sat'] != null && data['student_prompt_sat'] != data['teacher_narration_sat']) ...[
                Row(
                  children: [
                    const Icon(Icons.campaign, size: 16, color: Colors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ᱥᱟᱱᱛᱟᱲᱤ ᱠᱟᱛᱷᱟ (Short Spoken Prompt):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['student_prompt_sat'] as String,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Divider(height: 16),
              ],
              Text(
                data['teacher_prompt'] as String,
                style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 2: We Do (Classroom Choral Repetition)
  Widget _buildStep2Choral(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const StatusBadge(label: 'चरण २: सब मिलकर बोलें (We Do)', color: AppColors.tagScience),
            const Spacer(),
            Text(
              '⭐ $_playerStars Stars Earned',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Giant Classroom Facing Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                '🖥️ कक्षा में बच्चों को दिखाएँ (Classroom Facing)',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                data['visual'] as String,
                style: const TextStyle(fontSize: 56),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                data['key_script'] as String,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'सब बच्चे साथ बोलें: ${data['phonetic']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    NaturalAudioButton(
                      textToSpeak: AudioTtsService.instance.getChoralPrompt(
                        _audioMode,
                        data['key_script'] as String? ?? data['phonetic'] as String,
                        data['phonetic'] as String,
                      ),
                      speakId: 'step2_choral_${widget.lesson.id}',
                      isCompact: true,
                      tooltip: _audioMode == LessonAudioMode.santhali ? 'संथाली उच्चारण सुनें' : 'उच्चारण सुनें',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => _repeatWithClass(data['phonetic'] as String),
                icon: const Icon(Icons.star, size: 22),
                label: const Text(
                  'बच्चों के साथ दोहराएँ (+1 Star ⭐)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.record_voice_over, color: Colors.blue, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'टिप: शिक्षक पहले खुद बोलें, फिर सभी बच्चों को एक स्वर में ताली बजाकर दोहराने को कहें। जितने बार बच्चे बोलेंगे, उतने स्टार्स मिलेंगे!',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ),
              NaturalAudioButton(
                textToSpeak: _getSpokenText(
                  sat: 'ᱡᱚᱛᱚ ᱜᱤᱫᱽᱨᱟᱹ ᱢᱤᱫ ᱛᱮ ᱢᱮᱱ ᱯᱮ ᱟᱨ ᱛᱷᱟᱠᱟᱹᱭ ᱯᱮ: ${data['phonetic']}',
                  hi: 'कक्षा टिप: शिक्षक पहले खुद बोलें, फिर सभी बच्चों को एक स्वर में ताली बजाकर दोहराने को कहें।',
                ),
                speakId: 'step2_tip_${widget.lesson.id}',
                isCompact: true,
                color: Colors.blue.shade700,
                tooltip: 'कक्षा टिप सुनें',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 3: You Do (Quick FLN Mastery Check)
  Widget _buildStep3Quiz(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> options = (data['quiz_options'] as List).cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const StatusBadge(label: 'चरण ३: दक्षता जाँच (You Do)', color: AppColors.tagMath),
            const Spacer(),
            StatusBadge(
              label: _quizChecked && _quizCorrect ? 'दक्षता पूर्ण ✓' : 'अभ्यास कार्य',
              color: _quizChecked && _quizCorrect ? AppColors.success : AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['quiz_question'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        if (data['quiz_question_sat'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'संथाली: ${data['quiz_question_sat']}',
                            style: TextStyle(fontSize: 13, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  NaturalAudioButton(
                    textToSpeak: _getSpokenText(
                      sat: data['quiz_question_sat'] as String? ?? data['quiz_question'] as String,
                      hi: 'प्रश्न: ${data['quiz_question']}',
                      dual: '${data['quiz_question_sat'] ?? data['quiz_question']} • ${data['quiz_question']}',
                    ),
                    speakId: 'quiz_q_${widget.lesson.id}',
                    isCompact: true,
                    tooltip: _audioMode == LessonAudioMode.santhali ? 'संथाली प्रश्न सुनें (Listen Santhali)' : 'प्रश्न सुनें (Listen Question)',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              ...List.generate(options.length, (idx) {
                final opt = options[idx];
                final isSelected = _selectedQuizIndex == idx;
                final isCorrect = opt['correct'] as bool;

                Color borderColor = AppColors.outlineVariant;
                Color bgColor = Colors.white;

                if (_quizChecked) {
                  if (isCorrect) {
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withValues(alpha: 0.12);
                  } else if (isSelected && !isCorrect) {
                    borderColor = Colors.red;
                    bgColor = Colors.red.withValues(alpha: 0.1);
                  }
                } else if (isSelected) {
                  borderColor = AppColors.primary;
                  bgColor = AppColors.primaryContainer.withValues(alpha: 0.3);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedQuizIndex = idx;
                        _quizChecked = true;
                      });
                      if (isCorrect) {
                        AudioTtsService.instance.speakClean(
                          AudioTtsService.instance.getQuizPraise(_audioMode),
                          id: 'quiz_correct_${widget.lesson.id}',
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _quizChecked && isCorrect
                                ? Icons.check_circle
                                : (_quizChecked && isSelected ? Icons.cancel : (isSelected ? Icons.radio_button_checked : Icons.radio_button_off)),
                            color: _quizChecked && isCorrect ? AppColors.success : (_quizChecked && isSelected ? Colors.red : AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt['text'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected || (_quizChecked && isCorrect) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          NaturalAudioButton(
                            textToSpeak: _getSpokenText(
                              sat: opt['spoken_sat'] as String? ?? opt['text'] as String,
                              hi: 'विकल्प: ${opt['spoken_hi'] ?? opt['text']}',
                              dual: '${opt['spoken_sat'] ?? opt['text']} • यानी ${opt['spoken_hi'] ?? opt['text']}',
                            ),
                            speakId: 'quiz_opt_${widget.lesson.id}_$idx',
                            isCompact: true,
                            tooltip: 'विकल्प सुनें (Listen Choice)',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        if (_quizChecked && _quizCorrect) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.success, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎉 शाबाश! निपुण दक्षता सिद्ध हुई!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success),
                      ),
                      Text(
                        'नीचे "दक्षता पूर्ण दर्ज करें" बटन दबाकर इस उपलब्धि को ऑफलाइन डेटाबेस में सहेजें।',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool get _quizCorrect => _selectedQuizIndex != null && (_getLessonPedagogyData()['quiz_options'] as List)[_selectedQuizIndex!]['correct'] == true;
}
