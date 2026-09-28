import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Small visual status badge or tag chip.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
    this.isOutlined = false,
  });

  factory StatusBadge.prototype() {
    return const StatusBadge(
      label: 'Prototype / Pending Native Verification',
      color: AppColors.warning,
      icon: Icons.info_outline,
    );
  }

  factory StatusBadge.offline() {
    return const StatusBadge(
      label: 'Offline Mode Active',
      color: AppColors.offline,
      icon: Icons.cloud_off,
    );
  }

  factory StatusBadge.verified() {
    return const StatusBadge(
      label: 'Verified Content',
      color: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final effectiveTextColor = textColor ?? effectiveColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : effectiveColor.withValues(alpha: 0.15),
        border: Border.all(
          color: effectiveColor,
          width: 1.0,
        ),
        borderRadius: AppSpacing.roundedPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: effectiveTextColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: effectiveTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
