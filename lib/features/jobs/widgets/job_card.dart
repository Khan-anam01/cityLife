import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/job_model.dart';
import '../providers/jobs_provider.dart';

class JobCard extends ConsumerWidget {
  final JobModel job;
  const JobCard({super.key, required this.job});

  Color _categoryColor(String? cat) {
    switch (cat) {
      case 'Technology':
        return AppColors.moduleSchool;
      case 'Healthcare':
        return AppColors.moduleHospital;
      case 'Engineering':
        return AppColors.accent;
      case 'Education':
        return AppColors.lavender;
      case 'Marketing':
        return AppColors.amber;
      case 'Design':
        return AppColors.moduleSocial;
      case 'Finance':
        return AppColors.success;
      case 'Media':
        return AppColors.sky;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaved = ref.watch(savedJobsProvider).contains(job.id);
    final color = _categoryColor(job.category);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return GestureDetector(
      onTap: () => context.push('/job/${job.id}', extra: job),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top color bar ─────────────────────────
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
                  // Company logo + save button
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Center(
                          child: Text(
                            job.company.substring(0, 1),
                            style: AppTypography.headlineMedium.copyWith(
                              color: color,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.company,
                              style: AppTypography.labelMedium.copyWith(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (job.isRemote)
                              Row(
                                children: [
                                  Icon(Icons.wifi_rounded,
                                      size: 11, color: AppColors.success),
                                  const SizedBox(width: 3),
                                  Text('Remote',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Save button
                      GestureDetector(
                        onTap: () =>
                            ref.read(savedJobsProvider.notifier).toggle(job.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSaved
                                ? AppColors.accent.withOpacity(0.12)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 20,
                            color: isSaved ? AppColors.accent : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Job title
                  Text(
                    job.title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Tags row
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _Tag(
                        label: job.typeLabel,
                        color: color,
                      ),
                      if (job.category != null)
                        _Tag(
                          label: job.category!,
                          color: textSecondary,
                          outlined: true,
                          isDark: isDark,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Location + Salary
                  Row(
                    children: [
                      if (job.location != null) ...[
                        Icon(Icons.location_on_outlined,
                            size: 13, color: textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            job.location!,
                            style: AppTypography.bodySmall
                                .copyWith(color: textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (job.salary != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.payments_outlined,
                            size: 13, color: AppColors.success),
                        const SizedBox(width: 3),
                        Text(
                          job.salary!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Skills preview
                  if (job.skillsList.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: job.skillsList
                          .take(3)
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceElevated
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(s,
                                    style: AppTypography.caption.copyWith(
                                      color: textSecondary,
                                    )),
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // Deadline + Apply button
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: job.isExpired ? AppColors.error : textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.deadlineLabel,
                        style: AppTypography.caption.copyWith(
                          color:
                              job.isExpired ? AppColors.error : textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/job/${job.id}', extra: job),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.accent : AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Apply Now',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark ? AppColors.primary : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
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

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final bool isDark;

  const _Tag({
    required this.label,
    required this.color,
    this.outlined = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: outlined
              ? (isDark ? AppColors.darkBorder : AppColors.border)
              : color.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: outlined ? color : color,
          fontSize: 11,
        ),
      ),
    );
  }
}
