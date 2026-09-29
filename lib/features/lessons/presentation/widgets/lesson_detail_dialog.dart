import 'package:flutter/material.dart';
import '../../../../core/services/audio_tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/natural_audio_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/learning_outcome_model.dart';
import '../../data/models/lesson_model.dart';

class LessonDetailDialog extends StatelessWidget {
  final LessonModel lesson;
  final List<LearningOutcomeModel> outcomes;
  final VoidCallback? onToggleComplete;

  const LessonDetailDialog({
    super.key,
    required this.lesson,
    required this.outcomes,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedLg,
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${lesson.titleHi} • ${lesson.titleSat}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            NaturalAudioButton(
                              textToSpeak: 'पाठ: ${lesson.titleHi}. विषय: ${lesson.subject}. ओल चिकी: ${lesson.titleSat}',
                              speakId: 'dialog_header_${lesson.id}',
                              isCompact: true,
                              tooltip: 'पाठ का शीर्षक सुनें',
                            ),
                          ],
                        ),
                        Text(
                          '${lesson.grade} • ${lesson.subject} • ${lesson.titleEn}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      AudioTtsService.instance.stop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prominent verification warning badge
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prototype / Pending Native Verification',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Santhali (Ol Chiki) vocabulary and pedagogy require community linguistic review before classroom deployment.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Learning Objective
                    _buildSectionHeader('Learning Objective / शिक्षण उद्देश्य', Icons.flag_outlined),
                    _buildBilingualBox(
                      hindi: lesson.objectiveHi,
                      santhali: lesson.objectiveSat,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Specific Learning Outcomes from SQLite
                    if (outcomes.isNotEmpty) ...[
                      _buildSectionHeader('Curriculum Outcomes (SQLite)', Icons.check_circle_outline),
                      ...outcomes.map((lo) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.tagMath.withValues(alpha: 0.15),
                                      borderRadius: AppSpacing.roundedSm,
                                    ),
                                    child: Text(lo.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.tagMath)),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(lo.descriptionHi, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        Text(lo.descriptionSat, style: const TextStyle(fontSize: 12, color: AppColors.primaryDark)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Core Lesson Content
                    _buildSectionHeader('Lesson Content / मुख्य पाठ्य सामग्री', Icons.auto_stories_outlined),
                    _buildBilingualBox(
                      hindi: lesson.contentHi,
                      santhali: lesson.contentSat,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Classroom Activity
                    _buildSectionHeader('Classroom Activity / कक्षा गतिविधि', Icons.sports_esports_outlined),
                    _buildBilingualBox(
                      hindi: lesson.activityHi,
                      santhali: lesson.activitySat,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Assessment
                    _buildSectionHeader('Assessment / मूल्यांकन', Icons.quiz_outlined),
                    _buildBilingualBox(
                      hindi: lesson.assessmentHi,
                      santhali: lesson.assessmentSat,
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatusBadge(
                    label: lesson.isCompleted ? 'Completed' : 'Not Started',
                    color: lesson.isCompleted ? AppColors.success : AppColors.offline,
                    icon: lesson.isCompleted ? Icons.check_circle : Icons.schedule,
                  ),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      NaturalAudioButton(
                        textToSpeak: 'पाठ का विवरण: ${lesson.titleHi}. शिक्षण उद्देश्य: ${lesson.objectiveHi}. स्थानीय संदर्भ: ${lesson.contentHi}',
                        speakId: 'dialog_content_${lesson.id}',
                        label: 'पूरा पाठ सुनें',
                        backgroundColor: AppColors.primary,
                        iconSize: 18,
                      ),
                      AppButton(
                        label: lesson.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                        icon: lesson.isCompleted ? Icons.undo : Icons.check,
                        variant: AppButtonVariant.outlined,
                        onPressed: onToggleComplete,
                      ),
                      AppButton(
                        label: 'Close',
                        variant: AppButtonVariant.primary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBilingualBox({required String hindi, required String santhali}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hindi,
            style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ᱚᱞ ᱪᱤᱠᱤ: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark)),
                Expanded(
                  child: Text(
                    santhali,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
