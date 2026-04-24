import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';

/// A pill-shaped Follow / Following button.
/// Pass [targetUserId] and [targetUserName]. The widget resolves
/// the current user and current follow state automatically.
class FollowButton extends ConsumerWidget {
  final String targetUserId;
  final String targetUserName;
  final bool compact; // smaller size for use inside post cards

  const FollowButton({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    // Don't show the button for the current user's own posts
    if (currentUser == null || currentUser.id == targetUserId) {
      return const SizedBox.shrink();
    }

    final isFollowingAsync = ref.watch(isFollowingProvider(targetUserId));

    return isFollowingAsync.when(
      loading: () => _buttonShell(
        context,
        isFollowing: false,
        onTap: null,
        compact: compact,
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (isFollowing) {
        final args = (
          currentUserId: currentUser.id,
          targetUserId: targetUserId,
          initial: isFollowing,
        );
        final notifier = ref.read(followNotifierProvider(args).notifier);
        final followState = ref.watch(followNotifierProvider(args));

        return _buttonShell(
          context,
          isFollowing: followState,
          onTap: notifier.toggle,
          compact: compact,
        );
      },
    );
  }

  Widget _buttonShell(
    BuildContext context, {
    required bool isFollowing,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final height = compact ? 26.0 : 32.0;
    final hPad = compact ? AppSpacing.sm : AppSpacing.md;
    final fontSize = compact ? 11.0 : 12.0;

    if (isFollowing) {
      // "Following" outlined style
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              'Following',
              style: AppTypography.labelMedium.copyWith(
                fontSize: fontSize,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    // "Follow" filled style
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppColors.accent : AppColors.primary,
        ),
        child: Center(
          child: Text(
            'Follow',
            style: AppTypography.labelMedium.copyWith(
              fontSize: fontSize,
              color: isDark ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
