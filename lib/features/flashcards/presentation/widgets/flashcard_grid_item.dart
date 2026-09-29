import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/flashcard_item.dart';

class FlashcardGridItem extends StatelessWidget {
  final FlashcardItem card;
  final VoidCallback onTap;
  final VoidCallback onSpeak;

  const FlashcardGridItem({
    super.key,
    required this.card,
    required this.onTap,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: card.accentColor.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top: Visual Emblem with Audio Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: card.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    card.flnCode,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: card.accentColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onSpeak,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: card.accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.volume_up, size: 16, color: card.accentColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Visual Symbol
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: card.accentColor.withValues(alpha: 0.08),
                border: Border.all(color: card.accentColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                card.visualSymbol,
                style: const TextStyle(fontSize: 28),
              ),
            ),

            const SizedBox(height: 6),

            // Santhali Devanagari
            Text(
              card.santhaliDev,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: card.accentColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Hindi Name
            Text(
              card.hindi,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // English Meaning
            Text(
              card.englishMeaning,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
