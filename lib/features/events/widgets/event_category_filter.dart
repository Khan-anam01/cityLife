import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/events_provider.dart';

class EventCategoryFilter extends ConsumerWidget {
  const EventCategoryFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(eventCategoriesProvider);
    final selected = ref.watch(eventCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat['id'];

          return GestureDetector(
            onTap: () => ref.read(eventCategoryProvider.notifier).state =
                cat['id'] as String?,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.accent : AppColors.primary)
                    : (isDark ? AppColors.darkSurface : AppColors.surface),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.accent : AppColors.primary)
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat['emoji'] as String,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    cat['label'] as String,
                    style: AppTypography.labelMedium.copyWith(
                      fontSize: 12,
                      color: isSelected
                          ? (isDark ? AppColors.primary : Colors.white)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
