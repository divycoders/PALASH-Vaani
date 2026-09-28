import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/curriculum_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? CurriculumRepository();
    _loadLessons();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter / Selection Header
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject (विषय)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

          const SizedBox(height: AppSpacing.lg),

          // Section Header with SQLite source badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Available Lessons (Local SQLite)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const StatusBadge(
                label: 'SQLite Database',
                icon: Icons.storage,
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

                return AppCard(
                  onTap: () => _openLessonDetails(lesson),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: lesson.isCompleted
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.tagMath.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Text(
                      indexString,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: lesson.isCompleted ? AppColors.success : AppColors.tagMath,
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
                      Text(
                        'Objective: ${lesson.objectiveHi}',
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          StatusBadge(
                            label: lesson.verificationStatus,
                            color: AppColors.warning,
                            icon: Icons.info_outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
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
                            onPressed: () => _openLessonDetails(lesson),
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
    );
  }
}
