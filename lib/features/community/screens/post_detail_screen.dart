import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../providers/community_provider.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider);
    final comment = CommentModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      userId: user?.id ?? 'anonymous',
      userName: user?.displayName ?? 'You',
      userInitials: user?.initials ?? 'Y',
      content: text,
      createdAt: DateTime.now(),
    );
    await ref
        .read(commentsProvider(widget.post.id).notifier)
        .addComment(comment);
    _commentController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commentsState = ref.watch(commentsStreamProvider(widget.post.id));
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Post', style: AppTypography.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original post
                  PostCard(post: widget.post),
                  Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.divider,
                    height: 1,
                  ),

                  // Comments header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.md,
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      'Replies',
                      style: AppTypography.headlineSmall.copyWith(
                        color: textPrimary,
                      ),
                    ),
                  ),

                  // Comments list
                  commentsState.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child:
                            CircularProgressIndicator(color: AppColors.accent),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('Could not load replies',
                          style: AppTypography.bodyMedium),
                    ),
                    data: (comments) {
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Center(
                            child: Text(
                              'No replies yet. Be the first!',
                              style: AppTypography.bodyMedium.copyWith(
                                color: textSecondary,
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color:
                              isDark ? AppColors.darkBorder : AppColors.divider,
                        ),
                        itemBuilder: (context, i) =>
                            _CommentTile(comment: comments[i]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Comment input ─────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.base,
              right: AppSpacing.base,
              top: AppSpacing.sm,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + AppSpacing.base,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    maxLines: null,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Reply to this post...',
                      hintStyle: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textTertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.accent : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.accent : AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                comment.userInitials ?? '?',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accent,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName ?? 'Anonymous',
                      style: AppTypography.labelLarge.copyWith(
                        color: textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${comment.timeAgo}',
                      style:
                          AppTypography.caption.copyWith(color: textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.favorite_outline_rounded,
                        size: 14, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      comment.likes > 0 ? '${comment.likes}' : '',
                      style:
                          AppTypography.caption.copyWith(color: textSecondary),
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
}
