import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const List<_QuickAction> _actions = [
    _QuickAction(
      label: 'Hospitals',
      icon: Icons.local_hospital_rounded,
      color: AppColors.moduleHospital,
      route: AppRoutes.explore,
    ),
    _QuickAction(
      label: 'Schools',
      icon: Icons.school_rounded,
      color: AppColors.moduleSchool,
      route: AppRoutes.explore,
    ),
    _QuickAction(
      label: 'Transport',
      icon: Icons.directions_bus_rounded,
      color: AppColors.moduleTransport,
      route: AppRoutes.explore,
    ),
    _QuickAction(
      label: 'Police',
      icon: Icons.local_police_rounded,
      color: AppColors.modulePolice,
      route: AppRoutes.explore,
    ),
    _QuickAction(
      label: 'Events',
      icon: Icons.event_rounded,
      color: AppColors.moduleEvents,
      route: AppRoutes.nearby,
    ),
    _QuickAction(
      label: 'Jobs',
      icon: Icons.work_rounded,
      color: AppColors.moduleJobs,
      route: AppRoutes.services,
    ),
    _QuickAction(
      label: 'Report',
      icon: Icons.report_problem_rounded,
      color: AppColors.moduleReport,
      route: AppRoutes.reportIssue,
    ),
    _QuickAction(
      label: 'Community',
      icon: Icons.people_rounded,
      color: AppColors.moduleSocial,
      route: AppRoutes.community,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Access',
              style: AppTypography.headlineSmall.copyWith(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              )),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.85,
            ),
            itemCount: _actions.length,
            itemBuilder: (context, index) {
              final action = _actions[index];
              return _QuickActionItem(action: action, isDark: isDark);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final _QuickAction action;
  final bool isDark;

  const _QuickActionItem({required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(action.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: action.color.withOpacity(isDark ? 0.3 : 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: AppSpacing.iconMd,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            action.label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
