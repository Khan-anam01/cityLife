import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/jobs_provider.dart';
import '../widgets/job_card.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jobsState = ref.watch(allJobsProvider);
    final categories = ref.watch(jobCategoriesProvider);
    final types = ref.watch(jobTypesProvider);
    final selectedCategory = ref.watch(jobCategoryProvider);
    final selectedType = ref.watch(jobTypeProvider);
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
                  Text('Jobs',
                      style: AppTypography.displaySmall
                          .copyWith(color: textPrimary)),
                  Text('Find your next opportunity',
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
                  ref.read(jobSearchProvider.notifier).state = v;
                  ref.read(allJobsProvider.notifier).load();
                },
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies, skills...',
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
                            ref.read(jobSearchProvider.notifier).state = '';
                            ref.read(allJobsProvider.notifier).load();
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
                      ref.read(jobCategoryProvider.notifier).state = cat;
                      ref.read(allJobsProvider.notifier).load();
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
            const SizedBox(height: AppSpacing.xs),

            // ── Type filter ───────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                itemCount: types.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final type = types[i];
                  final isSelected = selectedType == type;
                  final label = type == 'All'
                      ? 'All Types'
                      : type[0].toUpperCase() + type.substring(1);
                  return GestureDetector(
                    onTap: () {
                      ref.read(jobTypeProvider.notifier).state = type;
                      ref.read(allJobsProvider.notifier).load();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11,
                          color: isSelected ? AppColors.accent : textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Jobs list ─────────────────────────────
            Expanded(
              child: jobsState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (e, _) => Center(
                  child: Text('Could not load jobs',
                      style: AppTypography.bodyMedium
                          .copyWith(color: textPrimary)),
                ),
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💼', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: AppSpacing.md),
                          Text('No jobs found',
                              style: AppTypography.headlineSmall
                                  .copyWith(color: textPrimary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Try a different search or category',
                              style: AppTypography.bodySmall
                                  .copyWith(color: textSecondary)),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding),
                        child: Text(
                          '${jobs.length} ${jobs.length == 1 ? 'job' : 'jobs'} found',
                          style: AppTypography.bodySmall
                              .copyWith(color: textSecondary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenPadding,
                            0,
                            AppSpacing.screenPadding,
                            AppSpacing.massive,
                          ),
                          itemCount: jobs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) => JobCard(job: jobs[i]),
                        ),
                      ),
                    ],
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
