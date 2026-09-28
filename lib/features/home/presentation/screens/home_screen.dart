import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Welcome Banner
          AppCard(
            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.4),
            borderColor: AppColors.primaryLight.withValues(alpha: 0.5),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppSpacing.roundedMd,
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'पलाश-वाणी | PALASH-Vaani',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Mother Tongue-Based Primary Pedagogy Assistant',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              StatusBadge.offline(),
                              const StatusBadge(
                                label: 'Hindi ⇄ Santhali (Ol Chiki)',
                                color: AppColors.tagLanguage,
                                icon: Icons.translate,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Empowering primary educators in multilingual tribal classrooms through localized curriculum, verified speech intents, and offline translation.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Primary Prototype Spotlight (Milestone 3/4 Preview)
          Text(
            'Featured Lesson (Milestone 3/4 Focus)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            leading: CircleAvatar(
              backgroundColor: AppColors.tagMath.withValues(alpha: 0.15),
              child: const Icon(Icons.calculate, color: AppColors.tagMath),
            ),
            title: 'Grade 1 Mathematics: Counting 1–10',
            subtitle: 'कक्षा १ गणित: गिनती १ से १० • ᱞᱮᱠᱷᱟ ᱑-᱑᱐',
            trailing: const StatusBadge(
              label: 'Grade 1',
              color: AppColors.tagMath,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foundational numeracy concept introducing cardinal numbers in Hindi and Santhali (Ol Chiki script).',
                  style: TextStyle(fontSize: 13.5, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge.prototype(),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      label: 'Open Lesson',
                      icon: Icons.play_arrow,
                      onPressed: () => onNavigateToTab?.call(1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Module Navigation Grid
          Text(
            'Prototype Modules',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= AppSpacing.tabletBreakpoint ? 3 : 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: [
              _buildModuleCard(
                title: 'Lessons',
                hindi: 'पाठ्यक्रम',
                description: 'Local SQLite curriculum & lesson plans',
                icon: Icons.menu_book,
                color: AppColors.primary,
                tabIndex: 1,
              ),
              _buildModuleCard(
                title: 'Live Classroom',
                hindi: 'कक्षा सहायक',
                description: 'Intent matching & speech interaction',
                icon: Icons.record_voice_over,
                color: AppColors.secondary,
                tabIndex: 2,
              ),
              _buildModuleCard(
                title: 'Translator',
                hindi: 'द्विभाषी अनुवादक',
                description: 'Hindi ⇄ Santhali translation interface',
                icon: Icons.translate,
                color: AppColors.tertiary,
                tabIndex: 3,
              ),
              _buildModuleCard(
                title: 'Worksheets',
                hindi: 'कार्यपत्रक',
                description: 'Bilingual PDF activity generator',
                icon: Icons.description,
                color: AppColors.tagMath,
                tabIndex: 4,
              ),
              _buildModuleCard(
                title: 'Flashcards',
                hindi: 'फ़्लैशकार्ड',
                description: 'Visual multi-script vocabulary cards',
                icon: Icons.style,
                color: AppColors.tagLanguage,
                tabIndex: 5,
              ),
              _buildModuleCard(
                title: 'Diagnostics',
                hindi: 'सिस्टम स्थिति',
                description: 'Offline checks & hardware telemetry',
                icon: Icons.analytics,
                color: AppColors.offline,
                tabIndex: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String hindi,
    required String description,
    required IconData icon,
    required Color color,
    required int tabIndex,
  }) {
    return AppCard(
      onTap: () => onNavigateToTab?.call(tabIndex),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title ($hindi)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
