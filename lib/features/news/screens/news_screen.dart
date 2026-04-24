import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/news_model.dart';
import '../providers/news_provider.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newsState = ref.watch(newsProvider);
    final categories = ref.watch(newsCategoriesProvider);
    final selectedCategory = ref.watch(newsCategoryProvider);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('City News',
                      style: AppTypography.displaySmall
                          .copyWith(color: textPrimary)),
                  Text('Stay informed about your city',
                      style: AppTypography.bodySmall
                          .copyWith(color: textSecondary)),
                ],
              ),
            ),

            // ── Search ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.xs),
              child: TextField(
                controller: _searchController,
                style: AppTypography.bodyMedium.copyWith(color: textPrimary),
                onChanged: (v) {
                  ref.read(newsSearchProvider.notifier).state = v;
                  ref.read(newsProvider.notifier).load();
                },
                decoration: InputDecoration(
                  hintText: 'Search news...',
                  hintStyle: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textTertiary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              size: 18, color: AppColors.textTertiary),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(newsSearchProvider.notifier).state = '';
                            ref.read(newsProvider.notifier).load();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base, vertical: AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                        color: isDark ? AppColors.accent : AppColors.primary,
                        width: 1.5),
                  ),
                ),
              ),
            ),

            // ── Category filter ───────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      ref.read(newsCategoryProvider.notifier).state = cat;
                      ref.read(newsProvider.notifier).load();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.surface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppColors.accent : AppColors.primary)
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: AppTypography.labelMedium.copyWith(
                          fontSize: 12,
                          color: isSelected
                              ? (isDark ? AppColors.primary : Colors.white)
                              : textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── News list ─────────────────────────────
            Expanded(
              child: newsState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (e, _) => Center(
                  child: Text('Could not load news',
                      style: AppTypography.bodyMedium
                          .copyWith(color: textPrimary)),
                ),
                data: (articles) {
                  if (articles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📰', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: AppSpacing.md),
                          Text('No articles found',
                              style: AppTypography.headlineSmall
                                  .copyWith(color: textPrimary)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () => ref.read(newsProvider.notifier).load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        AppSpacing.massive,
                      ),
                      itemCount: articles.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final article = articles[i];
                        return _NewsCard(
                          article: article,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => context.push('/news/${article.id}',
                              extra: article),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel article;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _NewsCard({
    required this.article,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

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
    final color = _categoryColor(article.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color accent bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.cardRadiusLg),
                  topRight: Radius.circular(AppSpacing.cardRadiusLg),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(article.categoryEmoji,
                                style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              article.category ?? 'News',
                              style: AppTypography.labelSmall
                                  .copyWith(color: color, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(article.timeAgo,
                          style: AppTypography.caption
                              .copyWith(color: textSecondary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Title
                  Text(
                    article.title,
                    style: AppTypography.headlineMedium
                        .copyWith(fontSize: 15, color: textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Summary
                  if (article.summary != null)
                    Text(
                      article.summary!,
                      style: AppTypography.bodySmall
                          .copyWith(color: textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppSpacing.sm),

                  // Footer
                  Row(
                    children: [
                      if (article.author != null) ...[
                        Icon(Icons.person_outline_rounded,
                            size: 12, color: textSecondary),
                        const SizedBox(width: 3),
                        Text(article.author!,
                            style: AppTypography.caption
                                .copyWith(color: textSecondary)),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Icon(Icons.visibility_outlined,
                          size: 12, color: textSecondary),
                      const SizedBox(width: 3),
                      Text('${article.views}',
                          style: AppTypography.caption
                              .copyWith(color: textSecondary)),
                      const SizedBox(width: AppSpacing.md),
                      Icon(Icons.favorite_outline_rounded,
                          size: 12, color: textSecondary),
                      const SizedBox(width: 3),
                      Text('${article.likes}',
                          style: AppTypography.caption
                              .copyWith(color: textSecondary)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: textSecondary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
