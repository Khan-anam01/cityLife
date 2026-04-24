import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel article;
  const NewsDetailScreen({super.key, required this.article});

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
      case 'Security':
        return AppColors.modulePolice;
      case 'Sports':
        return AppColors.amber;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _categoryColor(article.category);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero section ──────────────────────────
            Container(
              height: 8,
              color: color,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(article.categoryEmoji,
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          article.category ?? 'News',
                          style: AppTypography.labelMedium
                              .copyWith(color: color, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    article.title,
                    style: AppTypography.displaySmall
                        .copyWith(color: textPrimary, height: 1.3),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Meta row
                  Row(
                    children: [
                      if (article.author != null) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.15),
                          ),
                          child: Center(
                            child: Text(
                              article.author!.substring(0, 1),
                              style: AppTypography.labelSmall
                                  .copyWith(color: color),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(article.author!,
                                  style: AppTypography.labelMedium.copyWith(
                                      color: textPrimary, fontSize: 12)),
                              Text(article.timeAgo,
                                  style: AppTypography.caption
                                      .copyWith(color: textSecondary)),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 13, color: textSecondary),
                          const SizedBox(width: 3),
                          Text('${article.views}',
                              style: AppTypography.caption
                                  .copyWith(color: textSecondary)),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.favorite_outline_rounded,
                              size: 13, color: textSecondary),
                          const SizedBox(width: 3),
                          Text('${article.likes}',
                              style: AppTypography.caption
                                  .copyWith(color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Divider
                  Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Summary (lead paragraph)
                  if (article.summary != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.06),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: color.withOpacity(0.15)),
                      ),
                      child: Text(
                        article.summary!,
                        style: AppTypography.bodyLarge.copyWith(
                          color: textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Body — split into paragraphs
                  ...article.body.split('\n\n').map((paragraph) {
                    if (paragraph.trim().isEmpty) {
                      return const SizedBox(height: AppSpacing.md);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.base),
                      child: Text(
                        paragraph.trim(),
                        style: AppTypography.bodyLarge.copyWith(
                          color: textPrimary,
                          height: 1.75,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.xl),

                  // Tags
                  if (article.tags.isNotEmpty) ...[
                    Divider(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: article.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceElevated
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: AppTypography.caption.copyWith(
                                    color: textSecondary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.massive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
