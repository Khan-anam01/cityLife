import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/amenities_provider.dart';

class AmenitySearchBar extends ConsumerStatefulWidget {
  const AmenitySearchBar({super.key});

  @override
  ConsumerState<AmenitySearchBar> createState() => _AmenitySearchBarState();
}

class _AmenitySearchBarState extends ConsumerState<AmenitySearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) =>
            ref.read(amenitySearchProvider.notifier).state = value,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search hospitals, schools, restaurants...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: AppSpacing.iconMd,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: AppSpacing.iconSm,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref.read(amenitySearchProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: BorderSide(
              color: isDark ? AppColors.accent : AppColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
