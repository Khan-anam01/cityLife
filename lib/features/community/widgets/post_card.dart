import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/post_model.dart';
import '../providers/community_provider.dart';
import 'follow_button.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  final bool useFollowingFeed;

  const PostCard({
    super.key,
    required this.post,
    this.useFollowingFeed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final color = _avatarColor(post.userId);

    return InkWell(
      onTap: () => context.push('/post/${post.id}', extra: post),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tappable Avatar → User Profile ──────
            GestureDetector(
              onTap: () => context.push(
                '/user/${post.userId}',
                extra: {
                  'userId': post.userId,
                  'userName': post.userName,
                  'userInitials': post.userInitials,
                },
              ),
              child: Container(
                width: AppSpacing.avatarMd,
                height: AppSpacing.avatarMd,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.6)],
                  ),
                ),
                child: Center(
                  child: Text(
                    post.userInitials ?? '?',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Content ────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row + follow button + options
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(
                            '/user/${post.userId}',
                            extra: {
                              'userId': post.userId,
                              'userName': post.userName,
                              'userInitials': post.userInitials,
                            },
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.userName ?? 'Anonymous',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: textPrimary,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '· ${post.timeAgo}',
                                style: AppTypography.bodySmall
                                    .copyWith(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FollowButton(
                        targetUserId: post.userId,
                        targetUserName: post.userName ?? '',
                        compact: true,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => _showOptions(context, ref),
                        child: Icon(Icons.more_horiz_rounded,
                            size: 18, color: textSecondary),
                      ),
                    ],
                  ),

                  // County/Constituency tag
                  if (post.county != null || post.constituency != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 2, bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 11,
                              color: isDark
                                  ? AppColors.accent
                                  : AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            [
                              if (post.constituency != null) post.constituency,
                              if (post.county != null) post.county,
                            ].join(', '),
                            style: AppTypography.caption.copyWith(
                              color:
                                  isDark ? AppColors.accent : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Post content
                  Text(
                    post.content,
                    style: AppTypography.bodyMedium
                        .copyWith(color: textPrimary, height: 1.5),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Action bar ──────────────────
                  Row(
                    children: [
                      _ActionBtn(
                        icon: Icons.chat_bubble_outline_rounded,
                        count: post.commentsCount,
                        color: textSecondary,
                        onTap: () =>
                            context.push('/post/${post.id}', extra: post),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      _ActionBtn(
                        icon: Icons.repeat_rounded,
                        count: post.reposts,
                        color:
                            post.isReposted ? AppColors.success : textSecondary,
                        onTap: () {},
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      _ActionBtn(
                        icon: post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        count: post.likes,
                        color: post.isLiked ? AppColors.coral : textSecondary,
                        onTap: () {
                          ref
                              .read(postActionsProvider.notifier)
                              .toggleLike(post.id, post.isLiked);
                        },
                      ),
                      const Spacer(),
                      Icon(Icons.ios_share_rounded,
                          size: 16, color: textSecondary),
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

  void _showOptions(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // View profile shortcut
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('View profile'),
            onTap: () {
              Navigator.pop(context);
              context.push(
                '/user/${post.userId}',
                extra: {
                  'userId': post.userId,
                  'userName': post.userName,
                  'userInitials': post.userInitials,
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline_rounded),
            title: const Text('Save post'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Report post'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            title: const Text('Delete post',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              ref.read(postActionsProvider.notifier).deletePost(post.id);
            },
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }

  Color _avatarColor(String userId) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.amber,
      AppColors.lavender,
      AppColors.coral,
      AppColors.sky,
      AppColors.moduleHospital,
    ];
    final index = userId.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            count > 0 ? '$count' : '',
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
