import 'package:flutter/material.dart';
import '../../../../core/services/audio_tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/quiz_question_generator.dart';
import '../../models/quiz_question_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String _selectedCategory = 'all';
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _totalStars = 0;
  int _streak = 0;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _loadNewQuizBatch();
  }

  @override
  void dispose() {
    AudioTtsService.instance.stop();
    super.dispose();
  }

  void _loadNewQuizBatch() {
    setState(() {
      _questions = QuizQuestionGenerator.instance.generateQuiz(
        count: 5,
        category: _selectedCategory,
      );
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
    });
  }

  void _onCategoryChanged(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
    });
    _loadNewQuizBatch();
  }

  Future<void> _playCurrentQuestionAudio() async {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    final q = _questions[_currentIndex];
    setState(() {
      _isPlayingAudio = true;
    });
    await AudioTtsService.instance.speak(q.spokenAudioPrompt, languageCode: 'hi-IN');
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
      });
    }
  }

  void _onOptionSelected(int index) {
    if (_isAnswered || _questions.isEmpty) return;

    final q = _questions[_currentIndex];
    final selectedOpt = q.options[index];

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (selectedOpt.isCorrect) {
        _totalStars += 2;
        _streak++;
      } else {
        _streak = 0;
      }
    });

    if (selectedOpt.isCorrect) {
      AudioTtsService.instance.speak('बहुत अच्छा! सही जवाब!', languageCode: 'hi-IN');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🌟 बहुत बढ़िया! सही जवाब! (+2 Stars ⭐) Streak: $_streak 🔥',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      AudioTtsService.instance.speak('कोई बात नहीं, सही उत्तर सीखें!', languageCode: 'hi-IN');
    }
  }

  void _goToNextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      _showQuizCompletionDialog();
    }
  }

  void _showQuizCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              const Text(
                'शाबाश प्यारे बच्चों!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                'आपने क्विज़ पूरा किया और कुल ⭐ $_totalStars Stars जीते!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'FLN बाल विजेता (NIPUN Champ)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _loadNewQuizBatch();
                      },
                      child: const Text('🔄 नया क्विज़ खेलें', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category Switcher Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('all', '🌟 सभी विषय (All)', Icons.stars_rounded),
                  const SizedBox(width: 8),
                  _buildCategoryChip('maths', '🔢 FLN गणित (Maths)', Icons.calculate_outlined),
                  const SizedBox(width: 8),
                  _buildCategoryChip('language', '🔤 संथाली भाषा (Language)', Icons.translate_rounded),
                  const SizedBox(width: 8),
                  _buildCategoryChip('evs', '🌿 पर्यावरण (EVS)', Icons.nature_people_outlined),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // 2. Score & Progress Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 22),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '⭐ $_totalStars Stars',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_streak > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '$_streak',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'प्रश्न ${_currentIndex + 1}/${_questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // 3. Question Presentation Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderColor: AppColors.primaryLight.withValues(alpha: 0.3),
              child: Column(
                children: [
                  // Giant Visual Emblem
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        currentQuestion.visualSymbol,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Ol Chiki / Native Script Banner
                  if (currentQuestion.titleSat != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentQuestion.titleSat!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),

                  // Hindi Question Title
                  Text(
                    currentQuestion.titleHi,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Teacher Spoken Narration Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlayingAudio ? Colors.amber : AppColors.primary,
                      foregroundColor: _isPlayingAudio ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(_isPlayingAudio ? Icons.volume_up : Icons.record_voice_over, size: 20),
                    label: Text(
                      _isPlayingAudio ? 'बोल रहा हूँ...' : '🔊 प्रश्न सुनें (Teacher Narration)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: _playCurrentQuestionAudio,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // 4. Interactive 4-Option Grid
            ...List.generate(currentQuestion.options.length, (idx) {
              final opt = currentQuestion.options[idx];
              final isChosen = _selectedOptionIndex == idx;
              final showCorrect = _isAnswered && opt.isCorrect;
              final showWrong = _isAnswered && isChosen && !opt.isCorrect;

              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Color textColor = AppColors.textPrimary;

              if (showCorrect) {
                bgColor = const Color(0xFFE8F5E9); // Light emerald green
                borderColor = const Color(0xFF2E7D32); // Emerald border
                textColor = const Color(0xFF1B5E20);
              } else if (showWrong) {
                bgColor = const Color(0xFFFFEBEE); // Soft red
                borderColor = const Color(0xFFC62828);
                textColor = const Color(0xFFB71C1C);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  onTap: () => _onOptionSelected(idx),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: (showCorrect || showWrong) ? 2 : 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Circle Indicator
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: showCorrect
                                ? Colors.green
                                : showWrong
                                    ? Colors.red
                                    : Colors.grey.shade100,
                          ),
                          child: showCorrect
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : showWrong
                                  ? const Icon(Icons.close, color: Colors.white, size: 18)
                                  : Text(
                                      String.fromCharCode(65 + idx),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                        ),

                        const SizedBox(width: 12),

                        // Option Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              if (opt.scriptText != null || opt.phonetic != null) ...[
                                const SizedBox(height: 2),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    if (opt.scriptText != null)
                                      Text(
                                        opt.scriptText!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    if (opt.phonetic != null)
                                      Text(
                                        '(${opt.phonetic})',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        if (opt.visual != null)
                          Text(opt.visual!, style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // 5. Pedagogical Feedback Card (Appears after answer)
            if (_isAnswered) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Colors.blue, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡 शिक्षक व्याख्या (Explanation):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentQuestion.explanation,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // 6. Action Controls: Next Question / Refresh Quiz
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAnswered ? AppColors.primary : Colors.grey.shade300,
                      foregroundColor: _isAnswered ? Colors.white : Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(
                      _currentIndex + 1 < _questions.length ? Icons.arrow_forward_rounded : Icons.check_circle_outline,
                      size: 20,
                    ),
                    label: Text(
                      _currentIndex + 1 < _questions.length ? 'अगला प्रश्न (Next)' : 'क्विज़ पूरा करें (Finish)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: _isAnswered ? _goToNextQuestion : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('🔄 नया सेट', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: _loadNewQuizBatch,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String catId, String label, IconData icon) {
    final isSelected = _selectedCategory == catId;
    return InkWell(
      onTap: () => _onCategoryChanged(catId),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryDark : Colors.grey.shade300),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
