import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/job_model.dart';
import '../providers/jobs_provider.dart';

class JobDetailScreen extends ConsumerWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isSaved ? AppColors.accent : null,
            ),
            onPressed: () =>
                ref.read(savedJobsProvider.notifier).toggle(job.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Company header ─────────────────────────
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      job.company.substring(0, 1),
                      style: AppTypography.displaySmall.copyWith(
                        color: color,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.company,
                          style: AppTypography.headlineMedium
                              .copyWith(color: textPrimary)),
                      if (job.location != null)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: textSecondary),
                            const SizedBox(width: 3),
                            Text(job.location!,
                                style: AppTypography.bodySmall
                                    .copyWith(color: textSecondary)),
                          ],
                        ),
                      if (job.isRemote)
                        Row(
                          children: [
                            const Icon(Icons.wifi_rounded,
                                size: 13, color: AppColors.success),
                            const SizedBox(width: 3),
                            Text('Remote OK',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Job title ──────────────────────────────
            Text(job.title,
                style: AppTypography.displaySmall.copyWith(color: textPrimary)),
            const SizedBox(height: AppSpacing.md),

            // ── Quick info cards ───────────────────────
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.work_outline_rounded,
                    label: 'Type',
                    value: job.typeLabel,
                    color: color,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.payments_outlined,
                    label: 'Salary',
                    value: job.salary ?? 'Negotiable',
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.access_time_rounded,
                    label: 'Deadline',
                    value: job.deadlineLabel,
                    color: job.isExpired ? AppColors.error : AppColors.amber,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: job.category ?? 'General',
                    color: AppColors.lavender,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Skills ────────────────────────────────
            if (job.skillsList.isNotEmpty) ...[
              Text('Required Skills',
                  style: AppTypography.headlineMedium
                      .copyWith(color: textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: job.skillsList
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(s,
                              style: AppTypography.labelMedium.copyWith(
                                color: color,
                                fontSize: 12,
                              )),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // ── Description ───────────────────────────
            Text('Job Description',
                style:
                    AppTypography.headlineMedium.copyWith(color: textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              job.description,
              style: AppTypography.bodyMedium.copyWith(
                color: textSecondary,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── Apply FAB ──────────────────────────────────
      floatingActionButton: Container(
        width: double.infinity,
        margin:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: FloatingActionButton.extended(
          onPressed: job.isExpired
              ? null
              : () async {
                  if (job.applyUrl != null) {
                    final uri = Uri.parse(job.applyUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Application submitted for ${job.title}!',
                          style: AppTypography.bodySmall
                              .copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(AppSpacing.base),
                      ),
                    );
                  }
                },
          backgroundColor: job.isExpired
              ? (isDark ? AppColors.darkBorder : AppColors.border)
              : (isDark ? AppColors.accent : AppColors.primary),
          foregroundColor: job.isExpired
              ? textSecondary
              : (isDark ? AppColors.primary : Colors.white),
          elevation: 4,
          label: Row(
            children: [
              Icon(
                job.isExpired ? Icons.block_rounded : Icons.send_rounded,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                job.isExpired ? 'Application Closed' : 'Apply for this Job',
                style: AppTypography.buttonText,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              fontSize: 12,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
