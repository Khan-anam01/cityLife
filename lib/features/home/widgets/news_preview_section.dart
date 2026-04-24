import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../news/providers/news_provider.dart';
import '../../news/models/news_model.dart';

class NewsSectionPreview extends ConsumerWidget {
  const NewsSectionPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newsState = ref.watch(newsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sectionGap,
            AppSpacing.screenPadding,
            AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('City News', style: AppTypography.headlineSmall),
              GestureDetector(
                onTap: () => context.push('/news'),
                child: Text('See all',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.accent)),
              ),
            ],
          ),
        ),
        newsState.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                  color: AppColors.accent, strokeWidth: 2),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (articles) {
            final preview = articles.take(3).toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: preview.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _NewsPreviewItem(
                article: preview[i],
                isDark: isDark,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NewsPreviewItem extends StatelessWidget {
  final NewsModel article;
  final bool isDark;

  const _NewsPreviewItem({required this.article, required this.isDark});

  Color _categoryColor(String? cat) {
    switch (cat) {
      case 'Transport':
        return AppColors.moduleTransport;
      case 'Health':
        return AppColors.moduleHospital;
      case 'Technology':
        return AppColors.moduleSchool;
      case 'Education':
        return AppColors.lavender;
      case 'Business':
        return AppColors.accent;
      case 'Environment':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(article.category);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => context.push('/news/${article.id}', extra: article),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.category ?? 'News',
                          style: AppTypography.labelSmall
                              .copyWith(color: color, fontSize: 10),
                        ),
                      ),
                      const Spacer(),
                      Text(article.timeAgo,
                          style: AppTypography.caption
                              .copyWith(color: textSecondary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    article.title,
                    style: AppTypography.labelLarge
                        .copyWith(fontSize: 13, color: textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (article.summary != null)
                    Text(
                      article.summary!,
                      style:
                          AppTypography.caption.copyWith(color: textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
