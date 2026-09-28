import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class WorksheetsScreen extends StatelessWidget {
  const WorksheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header description
          AppCard(
            leading: const Icon(Icons.description, color: AppColors.tagMath, size: 28),
            title: 'Offline Bilingual Worksheet Generator',
            subtitle: 'द्विभाषी कार्यपत्रक निर्माता • Milestone 15 Target',
            trailing: const StatusBadge(label: 'PDF Export', color: AppColors.tagMath),
            child: const Text(
              'Generates ready-to-print bilingual practice sheets for rural primary schools, completely offline without cloud servers.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Worksheet Configuration Card
          AppCard(
            title: 'Worksheet Configuration',
            subtitle: 'Select learning parameters',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'Grade 1',
                        decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'Grade 1', child: Text('Grade 1')),
                          DropdownMenuItem(value: 'Grade 2', child: Text('Grade 2')),
                        ],
                        onChanged: (v) {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'Math: Counting 1–10',
                        decoration: const InputDecoration(labelText: 'Topic', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'Math: Counting 1–10', child: Text('Counting 1–10')),
                          DropdownMenuItem(value: 'Math: Shapes', child: Text('Basic Shapes')),
                        ],
                        onChanged: (v) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'Beginner',
                        decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'Beginner', child: Text('Beginner (चित्र गिनो)')),
                          DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                        ],
                        onChanged: (v) {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: 'Generate Sheet',
                        icon: Icons.refresh,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Offline PDF generation engine arrives in Milestone 15')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Worksheet Visual Preview Mockup
          Text(
            'Worksheet Preview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),

          AppCard(
            backgroundColor: Colors.white,
            borderColor: AppColors.outlineVariant,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sheet Header
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'पलाश-वाणी प्राथमिक अभ्यास पत्रक | PALASH-Vaani Practice Sheet',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      const Text(
                        'Class 1 Mathematics • Topic: Counting 1–10 (गिनती १-१० • ᱞᱮᱠᱷᱟ ᱑-᱑᱐)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                ),

                const Text(
                  'Instructions / निर्देश / ᱪᱮᱫ ᱞᱮᱠᱟ ᱠᱟᱹᱢᱤᱭᱟ:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  '1. Count the objects and write the number in Hindi and Santhali (Ol Chiki).\n   (वस्तुओं को गिनें और संख्या लिखें / ᱡᱤᱱᱤᱥ ᱠᱚ ᱞᱮᱠᱷᱟᱭ ᱢᱮ ᱟᱨ ᱮᱞ ᱚᱞ ᱢᱮ)',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Question Sample
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: Row(
                    children: [
                      const Text('Q1.', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: AppSpacing.md),
                      const Text('🍎  🍎  🍎', style: TextStyle(fontSize: 24)),
                      const Spacer(),
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outline),
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        alignment: Alignment.center,
                        child: const Text('३ / ᱓', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusBadge.prototype(),
                    AppButton(
                      label: 'Export PDF',
                      icon: Icons.picture_as_pdf,
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Offline PDF generation unlocks in Milestone 15')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
