import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../models/flashcard_item.dart';

class FlashcardFlipCard extends StatefulWidget {
  final FlashcardItem card;
  final int currentIndex;
  final int totalCount;
  final VoidCallback onSpeakWord;
  final VoidCallback onSpeakTeacherExplanation;
  final VoidCallback onSpeakSentence;
  final VoidCallback onPracticeStar;

  const FlashcardFlipCard({
    super.key,
    required this.card,
    required this.currentIndex,
    required this.totalCount,
    required this.onSpeakWord,
    required this.onSpeakTeacherExplanation,
    required this.onSpeakSentence,
    required this.onPracticeStar,
  });

  @override
  State<FlashcardFlipCard> createState() => _FlashcardFlipCardState();
}

class _FlashcardFlipCardState extends State<FlashcardFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _animation.addListener(() {
      if (_animation.value >= 0.5 && _showFront) {
        setState(() => _showFront = false);
      } else if (_animation.value < 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlashcardFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      // Reset flip when card changes
      if (!_showFront) {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: _showFront
              ? _buildFrontCard(context)
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildBackCard(context),
                ),
        );
      },
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    final card = widget.card;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: card.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.currentIndex + 1} / ${widget.totalCount} • ${card.categoryLabel}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: card.accentColor,
                        ),
                      ),
                    ),
                    StatusBadge(label: card.flnCode, color: card.accentColor),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: _flipCard,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flip_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'पलटें (Flip)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Visual Emblem
          GestureDetector(
            onTap: _flipCard,
            child: Container(
              width: 105,
              height: 105,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    card.accentColor.withValues(alpha: 0.15),
                    card.accentColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: card.accentColor.withValues(alpha: 0.35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: card.accentColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                card.visualSymbol,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Santhali Devanagari Phonetics (Guaranteed 100% crisp typography on all phones)
          Text(
            card.santhaliDev,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: card.accentColor,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 4),

          // Script & Pronunciation Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.record_voice_over, size: 14, color: Colors.orange),
                const SizedBox(width: 5),
                Text(
                  'संथाली: ${card.santhali}  |  उच्चारण: ${card.santhaliLatin}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Hindi Meaning & English
          Text(
            card.hindi,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            card.englishMeaning,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),

          const Divider(height: 24),

          // Action Buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: 'उच्चारण सुनें',
                icon: Icons.volume_up,
                variant: AppButtonVariant.primary,
                onPressed: widget.onSpeakWord,
              ),
              AppButton(
                label: 'शिक्षक व्याख्या',
                icon: Icons.psychology_alt_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: widget.onSpeakTeacherExplanation,
              ),
              AppButton(
                label: 'साथ बोलें (+1 ⭐)',
                icon: Icons.stars_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: widget.onPracticeStar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(BuildContext context) {
    final card = widget.card;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, size: 16, color: card.accentColor),
                  const SizedBox(width: 6),
                  Text(
                    'भाषाई विवरण व प्रयोग',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: card.accentColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _flipCard,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flip_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'मुख्य कार्ड',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Dialects Comparison Grid
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildDialectRow('संथाली (Santhali):', '${card.santhaliDev} (${card.santhaliLatin})', card.accentColor),
                const Divider(height: 10),
                _buildDialectRow('हो भाषा (Ho):', card.ho, AppColors.textPrimary),
                const Divider(height: 10),
                _buildDialectRow('मुंडारी (Mundari):', card.mundari, AppColors.textPrimary),
                const Divider(height: 10),
                _buildDialectRow('मानक हिंदी (Hindi):', card.hindi, AppColors.primaryDark),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Example Classroom Sentence
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.format_quote_rounded, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.exampleSentenceDev,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'हिंदी: ${card.exampleSentenceHi}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20, color: AppColors.primary),
                  tooltip: 'वाक्य सुनें',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onSpeakSentence,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Teacher FLN Tip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'शिक्षक सुझाव: ${card.teacherTip}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade900,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialectRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ),
      ],
    );
  }
}
