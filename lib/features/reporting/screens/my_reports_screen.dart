import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';
import '../models/report_model.dart';
import '../providers/reports_provider.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportsState = ref.watch(reportsProvider);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Reports',
            style: AppTypography.headlineMedium.copyWith(color: textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: isDark ? AppColors.accent : AppColors.primary),
            onPressed: () => context.push(AppRoutes.reportIssue),
          ),
        ],
      ),
      body: reportsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('Could not load reports',
              style: AppTypography.bodyMedium.copyWith(color: textPrimary)),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📋', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.md),
                  Text('No reports yet',
                      style: AppTypography.headlineSmall
                          .copyWith(color: textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Help improve your city by reporting issues',
                    style:
                        AppTypography.bodySmall.copyWith(color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(AppRoutes.reportIssue),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Report an Issue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.accent : AppColors.primary,
                        foregroundColor:
                            isDark ? AppColors.primary : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.buttonRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () => ref.read(reportsProvider.notifier).load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: reports.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => _ReportCard(
                  report: reports[i],
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  ref: ref),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.reportIssue),
        backgroundColor: isDark ? AppColors.accent : AppColors.primary,
        foregroundColor: isDark ? AppColors.primary : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Report'),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final WidgetRef ref;

  const _ReportCard({
    required this.report,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.ref,
  });

  Color _statusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.amber;
      case ReportStatus.inProgress:
        return AppColors.sky;
      case ReportStatus.resolved:
        return AppColors.success;
      case ReportStatus.rejected:
        return AppColors.error;
    }
  }

  IconData _statusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ReportStatus.inProgress:
        return Icons.autorenew_rounded;
      case ReportStatus.resolved:
        return Icons.check_circle_rounded;
      case ReportStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(report.status);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statusColor,
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
                // Header row
                Row(
                  children: [
                    Text(report.categoryEmoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        report.title,
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 14,
                          color: textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(report.status),
                              size: 11, color: statusColor),
                          const SizedBox(width: 3),
                          Text(
                            report.statusLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: statusColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.moduleReport.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.categoryLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.moduleReport,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                Text(
                  report.description,
                  style: AppTypography.bodySmall.copyWith(color: textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Footer
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 12, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(report.timeAgo,
                        style: AppTypography.caption
                            .copyWith(color: textSecondary)),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.location_on_outlined,
                        size: 12, color: textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${report.latitude.toStringAsFixed(3)}, '
                      '${report.longitude.toStringAsFixed(3)}',
                      style:
                          AppTypography.caption.copyWith(color: textSecondary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.error.withOpacity(0.7)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(reportsProvider.notifier).delete(report.id);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
