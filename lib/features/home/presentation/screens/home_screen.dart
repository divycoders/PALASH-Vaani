import 'package:flutter/material.dart';
import '../../../../core/services/audio_tts_service.dart';
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

  Future<void> _playPhrase(BuildContext context, String devPhonetic, String title, String script) async {
    await AudioTtsService.instance.speak(devPhonetic, languageCode: 'hi-IN');
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🔊 $title: $script ($devPhonetic)',
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
  }

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
                                label: 'Hindi ⇄ Santhali • Ho • Mundari',
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
                const SizedBox(height: AppSpacing.md),
                const Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusBadge(label: '5 NIPUN FLN Lessons', color: AppColors.tagMath, icon: Icons.menu_book),
                    StatusBadge(label: 'Sub-3s Voice Bridge', color: AppColors.secondary, icon: Icons.bolt),
                    StatusBadge(label: 'Offline PDF Worksheets', color: AppColors.primary, icon: Icons.print),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Dynamic Kids Quiz Hero Card
          InkWell(
            onTap: () => onNavigateToTab?.call(4),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3C72).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🧠', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'NEW • असीमित प्रश्न',
                                    style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Text('⭐ +2 Stars / प्रश्न', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'दैनिक बाल प्रश्नोत्तरी (Kids Dynamic Quiz)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FLN गणित, संथाली भाषा व EVS के नए प्रश्न हर बार खेल-खेल में सीखें!',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('क्विज़ शुरू करें (Start Quiz)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () => onNavigateToTab?.call(4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 1-Tap Daily Classroom Moments (Zero-Typing Quick Hub)
          Row(
            children: [
              Expanded(
                child: Text(
                  '⚡ 1-Tap Classroom Moments (कक्षा बातचीत)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () => onNavigateToTab?.call(2),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('All Routine', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickMomentCard(
                  context: context,
                  emoji: '🌅',
                  title: 'नमस्ते बच्चों',
                  phonetic: 'जोहार गिद्रा',
                  script: 'ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ',
                  color: Colors.amber.shade800,
                  bgColor: Colors.amber.shade50,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickMomentCard(
                  context: context,
                  emoji: '🪑',
                  title: 'बैठ जाओ',
                  phonetic: 'दुड़ुब मे',
                  script: 'ᱫᱩᱲᱩᱵ ᱢᱮ',
                  color: Colors.teal.shade800,
                  bgColor: Colors.teal.shade50,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickMomentCard(
                  context: context,
                  emoji: '🧼',
                  title: 'हाथ धो लो',
                  phonetic: 'ती अरुब मे',
                  script: 'ᱛᱤ ᱟᱹᱨᱩᱵ ᱢᱮ',
                  color: Colors.blue.shade800,
                  bgColor: Colors.blue.shade50,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickMomentCard(
                  context: context,
                  emoji: '🍲',
                  title: 'खाना खा लो',
                  phonetic: 'दाका जोम मे',
                  script: 'ᱫᱟᱠᱟ ᱡᱚᱢ ᱢᱮ',
                  color: Colors.deepOrange.shade800,
                  bgColor: Colors.deepOrange.shade50,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickMomentCard(
                  context: context,
                  emoji: '📖',
                  title: 'किताब खोलो',
                  phonetic: 'आमाग पुथि खुलाय मे',
                  script: 'ᱟᱢᱟᱜ ᱯᱩᱛᱷᱤ ᱠᱷᱩᱞᱟᱹᱭ ᱢᱮ',
                  color: Colors.indigo.shade800,
                  bgColor: Colors.indigo.shade50,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickMomentCard(
                  context: context,
                  emoji: '🏃‍♂️',
                  title: 'बाहर जाओ',
                  phonetic: 'जोतो गिद्रा बाहरे चालाग पे',
                  script: 'ᱡᱚᱛᱚ ᱜᱤᱫᱽᱨᱟᱹ ᱵᱟᱦᱨᱮ ᱪᱟᱞᱟᱜ ᱯᱮ',
                  color: Colors.purple.shade800,
                  bgColor: Colors.purple.shade50,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickMomentCard(
                  context: context,
                  emoji: '👏',
                  title: 'ताली बजाओ',
                  phonetic: 'थायो मे',
                  script: 'ᱛᱷᱟᱭᱚ ᱢᱮ',
                  color: Colors.green.shade800,
                  bgColor: Colors.green.shade50,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick Action Shortcuts Bar
          AppCard(
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.style,
                    label: 'चित्र शब्दकोश',
                    sub: 'Flashcards',
                    color: AppColors.tagLanguage,
                    onTap: () => onNavigateToTab?.call(5),
                  ),
                ),
                const SizedBox(
                  height: 36,
                  child: VerticalDivider(thickness: 1, width: 1),
                ),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.print,
                    label: 'कार्यपत्रक PDF',
                    sub: 'Worksheets',
                    color: AppColors.tagMath,
                    onTap: () => onNavigateToTab?.call(4),
                  ),
                ),
                const SizedBox(
                  height: 36,
                  child: VerticalDivider(thickness: 1, width: 1),
                ),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.record_voice_over,
                    label: 'कक्षा सहायक',
                    sub: 'Face-to-Face',
                    color: AppColors.secondary,
                    onTap: () => onNavigateToTab?.call(2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Primary Prototype Spotlight (Milestone 3/4 Focus)
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

  Widget _buildQuickMomentCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String phonetic,
    required String script,
    required Color color,
    required Color bgColor,
  }) {
    return InkWell(
      onTap: () => _playPhrase(context, phonetic, title, script),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 145,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                Icon(Icons.volume_up, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              script,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              phonetic,
              style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: color.withValues(alpha: 0.8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(
              sub,
              style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
