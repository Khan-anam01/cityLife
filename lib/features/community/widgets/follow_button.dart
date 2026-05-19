import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';

/// Pill-shaped Follow / Unfollow button.
/// Reads and owns follow state internally via [followNotifierProvider].
class FollowButton extends ConsumerWidget {
  final String targetUserId;
  final String targetUserName;
  final bool compact;

  const FollowButton({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null || currentUser.id == targetUserId) {
      return const SizedBox.shrink();
    }

    final args = (currentUserId: currentUser.id, targetUserId: targetUserId);
    final followState = ref.watch(followNotifierProvider(args));
    final notifier = ref.read(followNotifierProvider(args).notifier);

    return followState.when(
      loading: () => _Shell(
        isFollowing: false,
        loading: true,
        compact: compact,
        onTap: null,
        onLongPress: null,
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (isFollowing) => _Shell(
        isFollowing: isFollowing,
        loading: false,
        compact: compact,
        onTap: () async {
          if (isFollowing) {
            // Show confirmation bottom sheet before unfollowing
            final confirmed = await _confirmUnfollow(context, targetUserName);
            if (confirmed == true) notifier.toggle();
          } else {
            notifier.toggle();
          }
        },
        onLongPress: isFollowing
            ? () async {
                final confirmed =
                    await _confirmUnfollow(context, targetUserName);
                if (confirmed == true) notifier.toggle();
              }
            : null,
      ),
    );
  }

  Future<bool?> _confirmUnfollow(BuildContext context, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unfollow $name?',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Their posts will no longer appear in your Following feed.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Unfollow'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Button shell ─────────────────────────────────────────
class _Shell extends StatelessWidget {
  final bool isFollowing;
  final bool loading;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _Shell({
    required this.isFollowing,
    required this.loading,
    required this.compact,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = compact ? 26.0 : 32.0;
    final hPad = compact ? AppSpacing.sm : AppSpacing.md;
    final fontSize = compact ? 11.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isFollowing
              ? Colors.transparent
              : (isDark ? AppColors.accent : AppColors.primary),
          border: isFollowing
              ? Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                )
              : null,
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: fontSize,
                  height: fontSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFollowing) ...[
                      Icon(
                        Icons.check_rounded,
                        size: fontSize + 1,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: AppTypography.labelMedium.copyWith(
                        fontSize: fontSize,
                        color: isFollowing
                            ? (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)
                            : (isDark ? AppColors.primary : Colors.white),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
