import 'package:flutter/material.dart';
import '../../../../core/services/audio_tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/natural_audio_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/curriculum_repository.dart';
import '../widgets/classroom_lesson_player.dart';
import '../widgets/lesson_detail_dialog.dart';

class LessonsScreen extends StatefulWidget {
  final ICurriculumRepository? repository;

  const LessonsScreen({
    super.key,
    this.repository,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late final ICurriculumRepository _repository;
  String _selectedGrade = 'Grade 1';
  String _selectedSubject = 'Mathematics';
  List<LessonModel> _lessons = [];
  bool _isLoading = true;
  int _totalLessonStars = 8;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? CurriculumRepository();
    _loadLessons();
  }

  @override
  void dispose() {
    AudioTtsService.instance.stop();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      final lessons = await _repository.getLessons(
        grade: _selectedGrade,
        subject: _selectedSubject,
      );
      if (mounted) {
        setState(() {
          _lessons = lessons;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Error loading lessons: $e\n$stack');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openLessonDetails(LessonModel lesson) async {
    final outcomes = await _repository.getLearningOutcomes(lesson.id);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => LessonDetailDialog(
          lesson: lesson,
          outcomes: outcomes,
          onToggleComplete: () async {
            final newStatus = !lesson.isCompleted;
            await _repository.toggleLessonCompletion(lesson.id, newStatus);
            await _loadLessons();
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
            }
          },
        ),
      ),
    );
  }

  Future<void> _startClassroomPlayer(LessonModel lesson) async {
    final outcomes = await _repository.getLearningOutcomes(lesson.id);
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ClassroomLessonPlayer(
        lesson: lesson,
        outcomes: outcomes,
        onStarEarned: () {
          setState(() {
            _totalLessonStars += 1;
          });
        },
        onLessonCompleted: () async {
          await _repository.toggleLessonCompletion(lesson.id, true);
          await _loadLessons();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _lessons.where((l) => l.isCompleted).length;
    final progressFraction = _lessons.isEmpty ? 0.0 : completedCount / _lessons.length;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: 84,
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NIPUN Bharat FLN Class Mastery Dashboard (Top Card)
          AppCard(
            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.35),
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'NIPUN FLN Class Mastery',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Text(
                        '⭐ $_totalLessonStars Stars',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'प्रगति: $completedCount/${_lessons.length} पूर्ण',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(progressFraction * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressFraction,
                    minHeight: 6,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressFraction == 1.0 ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Grade & Subject Dropdowns Header Card
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: 'Grade (कक्षा)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Grade 1', child: Text('Grade 1 (कक्षा १)', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Grade 2', child: Text('Grade 2 (कक्षा २)', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Grade 3', child: Text('Grade 3 (कक्षा ३)', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedGrade = val);
                        _loadLessons();
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject (विषय)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics (गणित)', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Language', child: Text('Language (भाषा)', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Environmental', child: Text('EVS (पर्यावरण)', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSubject = val);
                        _loadLessons();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Available Lessons Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Available Lessons (Local SQLite)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                label: '${_lessons.length} पाठ',
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_lessons.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.menu_book, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No lessons found in local SQLite for $_selectedGrade • $_selectedSubject',
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lessons.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                final indexString = (index + 1).toString().padLeft(2, '0');
                final subjectColor = lesson.subject == 'Mathematics'
                    ? AppColors.tagMath
                    : (lesson.subject == 'Language' ? AppColors.tagLanguage : AppColors.tagScience);

                return AppCard(
                  onTap: () => _openLessonDetails(lesson),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderColor: lesson.isCompleted ? AppColors.success.withValues(alpha: 0.5) : null,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: lesson.isCompleted
                          ? AppColors.success.withValues(alpha: 0.15)
                          : subjectColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: lesson.isCompleted ? AppColors.success : subjectColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      indexString,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: lesson.isCompleted ? AppColors.success : subjectColor,
                      ),
                    ),
                  ),
                  title: '${lesson.titleHi} (${lesson.topic})',
                  subtitle: 'Ol Chiki: ${lesson.titleSat} • ${lesson.subject}',
                  trailing: StatusBadge(
                    label: lesson.isCompleted ? 'Completed' : 'Ready',
                    color: lesson.isCompleted ? AppColors.success : AppColors.tagMath,
                    icon: lesson.isCompleted ? Icons.check_circle : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🎯 NIPUN LO: ${lesson.objectiveHi}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          NaturalAudioButton(
                            textToSpeak: 'निपुण दक्षता: ${lesson.objectiveHi}',
                            speakId: 'card_lo_${lesson.id}',
                            isCompact: true,
                            tooltip: 'दक्षता उद्देश्य सुनें',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'स्थानीय संदर्भ: ${lesson.contentHi}',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          NaturalAudioButton(
                            textToSpeak: 'स्थानीय संदर्भ: ${lesson.contentHi}',
                            speakId: 'card_content_${lesson.id}',
                            isCompact: true,
                            tooltip: 'स्थानीय संदर्भ सुनें',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          AppButton(
                            label: 'Lesson Overview',
                            icon: Icons.menu_book,
                            variant: AppButtonVariant.outlined,
                            onPressed: () => _openLessonDetails(lesson),
                          ),
                          AppButton(
                            label: 'Start Lesson',
                            icon: Icons.play_arrow,
                            variant: AppButtonVariant.primary,
                            onPressed: () => _startClassroomPlayer(lesson),
                          ),
                          NaturalAudioButton(
                            textToSpeak: '${lesson.titleSat} • यानी ${lesson.titleHi}',
                            speakId: 'card_speak_${lesson.id}',
                            label: 'पाठ सुनें',
                            iconSize: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    ),
    // Floating Active Audio Control Bar
    Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: AppSpacing.md,
      child: ValueListenableBuilder<String?>(
        valueListenable: AudioTtsService.instance.currentPlayingIdNotifier,
        builder: (context, playingId, _) {
          if (playingId == null) return const SizedBox.shrink();
          return Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            color: Colors.red.shade700,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'ऑडियो चल रहा है... (Audio Playing)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    onPressed: () => AudioTtsService.instance.stop(),
                    icon: const Icon(Icons.stop_circle_rounded, size: 18),
                    label: const Text(
                      'ऑडियो रोकें (Stop)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ],
);
  }
}
