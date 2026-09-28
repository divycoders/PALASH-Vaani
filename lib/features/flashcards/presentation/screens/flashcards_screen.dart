import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'Numbers';

  final List<String> _categories = [
    'Numbers',
    'Animals',
    'Fruits',
    'Colors',
    'Shapes',
    'Classroom',
  ];

  final List<Map<String, String>> _numberCards = [
    {
      'visual': '1️⃣',
      'hindi': 'एक (1)',
      'santhali': 'ᱢᱤᱫ (᱑)',
      'latin': 'Mid',
      'desc': 'One • Cardinal Number 1',
    },
    {
      'visual': '2️⃣',
      'hindi': 'दो (2)',
      'santhali': 'ᱵᱟᱨ (᱒)',
      'latin': 'Bar',
      'desc': 'Two • Cardinal Number 2',
    },
    {
      'visual': '3️⃣',
      'hindi': 'तीन (3)',
      'santhali': 'ᱯᱮ (᱓)',
      'latin': 'Pe',
      'desc': 'Three • Cardinal Number 3',
    },
    {
      'visual': '4️⃣',
      'hindi': 'चार (4)',
      'santhali': 'ᱯᱩᱱ (᱔)',
      'latin': 'Pun',
      'desc': 'Four • Cardinal Number 4',
    },
    {
      'visual': '5️⃣',
      'hindi': 'पाँच (5)',
      'santhali': 'ᱢᱚᱬᱮ (᱕)',
      'latin': 'Mone',
      'desc': 'Five • Cardinal Number 5',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentCard = _numberCards[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selector Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Flashcard Display
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      'Card ${_currentIndex + 1} of ${_numberCards.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                    StatusBadge.prototype(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Visual Representation
                Container(
                  width: 110,
                  height: 110,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    currentCard['visual']!,
                    style: const TextStyle(fontSize: 52),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Ol Chiki Display
                Text(
                  currentCard['santhali']!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pronunciation: ${currentCard['latin']!}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const Divider(height: 32),

                // Hindi Equivalent
                Text(
                  currentCard['hindi']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  currentCard['desc']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Audio and Flip actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                      label: 'Listen Audio',
                      icon: Icons.volume_up,
                      variant: AppButtonVariant.outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Offline audio flashcards arrive in Milestone 16')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Navigation Controls (Previous / Next)
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Previous',
                  icon: Icons.arrow_back,
                  variant: AppButtonVariant.secondary,
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Next',
                  icon: Icons.arrow_forward,
                  variant: AppButtonVariant.primary,
                  onPressed: _currentIndex < _numberCards.length - 1
                      ? () => setState(() => _currentIndex++)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
