import 'package:flutter/material.dart';
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
  int _selectedMode = 0; // 0: Teacher (Hindi -> Santhali), 1: Student (Santhali -> Hindi)
  String _activeIntent = 'OPEN_BOOK';

  final List<Map<String, String>> _sampleIntents = [
    {
      'intent': 'GREETING',
      'hindi': 'नमस्ते बच्चों',
      'santhali': 'ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ',
      'latin': 'Johar gidra',
    },
    {
      'intent': 'OPEN_BOOK',
      'hindi': 'अपनी किताब खोलो',
      'santhali': 'ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ',
      'latin': 'Amag puthi khulạe me',
    },
    {
      'intent': 'LOOK_HERE',
      'hindi': 'यहाँ देखो',
      'santhali': 'ᱱᱚᱸᱰᱮ ᱧᱮᱞ ᱢᱮ',
      'latin': 'Nonde nel me',
    },
    {
      'intent': 'LISTEN',
      'hindi': 'ध्यान से सुनो',
      'santhali': 'ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ',
      'latin': 'Dheyan te anjom me',
    },
    {
      'intent': 'REPEAT',
      'hindi': 'मेरे बाद दोहराओ',
      'santhali': 'ᱤᱧ ᱛᱟᱭᱚᱢ ᱨᱚᱲ ᱢᱮ',
      'latin': 'Iny tayom rod me',
    },
    {
      'intent': 'COUNT',
      'hindi': 'एक साथ गिनो',
      'santhali': 'ᱢᱤᱫ ᱥᱟᱶᱛᱮ ᱞᱮᱠᱷᱟᱭ ᱯᱮ',
      'latin': 'Mid sawte lekhay pe',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeData = _sampleIntents.firstWhere(
      (item) => item['intent'] == _activeIntent,
      orElse: () => _sampleIntents.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Direction Selector
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Teacher: Hindi ➔ Santhali',
                    icon: Icons.person,
                    variant: _selectedMode == 0 ? AppButtonVariant.primary : AppButtonVariant.text,
                    onPressed: () => setState(() => _selectedMode = 0),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Student: Santhali ➔ Hindi',
                    icon: Icons.groups,
                    variant: _selectedMode == 1 ? AppButtonVariant.primary : AppButtonVariant.text,
                    onPressed: () => setState(() => _selectedMode = 1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Live Assistant Interaction Simulation Box
          AppCard(
            backgroundColor: AppColors.surface,
            borderColor: AppColors.secondary.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(AppSpacing.lg),
            leading: CircleAvatar(
              backgroundColor: AppColors.secondaryContainer,
              child: const Icon(Icons.record_voice_over, color: AppColors.secondary),
            ),
            title: 'Live Classroom Voice Pipeline',
            subtitle: 'Offline Intent Matching & Audio Playback',
            trailing: const StatusBadge(
              label: 'Milestones 5–7 & 13',
              color: AppColors.secondary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speech Input display
                Container(
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
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: const [
                          Text(
                            'Teacher Speech (Hindi):',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          StatusBadge(label: 'Intent: Verified', color: AppColors.secondary),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        activeData['hindi']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Vernacular Translation Output
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: const [
                          Text(
                            'Santhali (Ol Chiki Script):',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          StatusBadge(label: 'Ol Chiki', color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        activeData['santhali']!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Latin: ${activeData['latin']!}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppButton(
                      label: 'Simulate Voice Input',
                      icon: Icons.mic,
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ASR & Intent Engine will activate in Milestones 6, 11 & 13'),
                          ),
                        );
                      },
                    ),
                    AppButton(
                      label: 'Play Audio',
                      icon: Icons.volume_up,
                      variant: AppButtonVariant.outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Local Classroom Audio player will be wired in Milestone 7'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Quick Intent Triggers
          Text(
            'Common Classroom Phrases (Quick Triggers)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Tap any phrase to test intent preview. Real audio and SQLite intent mapping connect in Milestone 5.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _sampleIntents.map((item) {
              final isSelected = item['intent'] == _activeIntent;
              return ChoiceChip(
                label: Text('${item['hindi']} • ${item['intent']}'),
                selected: isSelected,
                selectedColor: AppColors.primaryContainer,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _activeIntent = item['intent']!);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
