import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter / Selection Header Placeholder
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: 'Grade 1',
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
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: 'Mathematics',
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
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Primary Prototype Lesson
          Text(
            'Available Lessons (Local SQLite Curriculum)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),

          AppCard(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.tagMath.withValues(alpha: 0.1),
                borderRadius: AppSpacing.roundedSm,
              ),
              child: const Text(
                '01',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.tagMath,
                ),
              ),
            ),
            title: 'Counting 1–10 (गिनती १ से १०)',
            subtitle: 'Ol Chiki: ᱞᱮᱠᱷᱟ ᱑-᱑᱐ • Mathematics • 4 Activities',
            trailing: const StatusBadge(
              label: 'Milestone 3 Target',
              color: AppColors.tagMath,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Objective: Students will learn to recognize, pronounce, and write numbers 1 to 10 in both Hindi and Santhali (Ol Chiki script).',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusBadge.prototype(),
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Local SQLite Curriculum will be wired in Milestone 3 & 4'),
                          ),
                        );
                      },
                    ),
                    AppButton(
                      label: 'Start Lesson',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Interactive lesson flow unlocks in Milestone 4'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Upcoming planned curriculum items
          Opacity(
            opacity: 0.65,
            child: AppCard(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: const Text('02', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              title: 'Shapes and Spaces (आकृतियाँ और स्थान)',
              subtitle: 'Mathematics • Upcoming Unit',
              trailing: const StatusBadge(
                label: 'Planned',
                color: Colors.grey,
              ),
              child: const Text(
                'Foundational geometry introducing circles, squares, triangles, and spatial positions.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
