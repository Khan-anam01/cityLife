import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/community_provider.dart';
import '../models/group_model.dart';

class GroupsTab extends ConsumerWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final county = ref.watch(selectedCountyProvider);
    final groupsAsync =
        ref.watch(groupsProvider(county == 'All' ? null : county));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return groupsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => Center(
          child:
              Text('Could not load groups', style: AppTypography.bodyMedium)),
      data: (groups) => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.massive,
        ),
        children: [
          // Create group button
          GestureDetector(
            onTap: () => _showCreateGroup(context),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(
                  color: isDark
                      ? AppColors.accent.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.accent.withOpacity(0.15)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: isDark ? AppColors.accent : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Create a new group',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          Text(
            county == 'All' ? 'All Groups' : 'Groups in $county',
            style: AppTypography.headlineSmall.copyWith(color: textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),

          ...groups.map((g) => _GroupCard(
              group: g,
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary)),

          if (groups.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  const Text('👥', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppSpacing.md),
                  Text('No groups yet', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Create the first group in this area!',
                    style:
                        AppTypography.bodySmall.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateGroup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Group — coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _GroupCard({
    required this.group,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                group.name.substring(0, 1),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: AppTypography.labelLarge
                            .copyWith(color: textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (group.isPrivate)
                      Icon(Icons.lock_outline_rounded,
                          size: 14, color: textSecondary),
                  ],
                ),
                if (group.description != null)
                  Text(
                    group.description!,
                    style:
                        AppTypography.bodySmall.copyWith(color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 12, color: textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${group.memberCount} members',
                      style:
                          AppTypography.caption.copyWith(color: textSecondary),
                    ),
                    if (group.county != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.accent),
                      const SizedBox(width: 2),
                      Text(
                        group.county!,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.accent),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 6),
              backgroundColor: isDark
                  ? AppColors.accent.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Join',
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.accent : AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
