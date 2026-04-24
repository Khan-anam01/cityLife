import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;
  final bool isDark;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: AppSpacing.screenPadding +
                          AppSpacing.iconMd +
                          AppSpacing.md,
                      color: isDark ? AppColors.darkBorder : AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;
  final Widget? trailing;
  final bool showArrow;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.value,
    this.color,
    this.trailing,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: effectiveColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: effectiveColor,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: AppTypography.bodySmall.copyWith(
                  color: textSecondary,
                ),
              ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ] else if (showArrow || value == null && trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
