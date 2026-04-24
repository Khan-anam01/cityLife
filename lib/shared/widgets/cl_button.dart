import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

enum CLButtonVariant { primary, secondary, outline, ghost }

class CLButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CLButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const CLButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CLButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(isDark),
    );
  }

  Widget _buildButton(bool isDark) {
    switch (variant) {
      case CLButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.accent : AppColors.primary,
            foregroundColor: isDark ? AppColors.primary : AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
          child: _buildChild(
            isDark ? AppColors.primary : AppColors.white,
          ),
        );

      case CLButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent.withOpacity(0.12),
            foregroundColor: AppColors.accent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
          child: _buildChild(AppColors.accent),
        );

      case CLButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppColors.accent : AppColors.primary,
            side: BorderSide(
              color: isDark ? AppColors.accent : AppColors.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
          child: _buildChild(
            isDark ? AppColors.accent : AppColors.primary,
          ),
        );

      case CLButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(
            isDark ? AppColors.accent : AppColors.primary,
          ),
        );
    }
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.buttonText.copyWith(color: color)),
        ],
      );
    }

    return Text(
      label,
      style: AppTypography.buttonText.copyWith(color: color),
    );
  }
}
