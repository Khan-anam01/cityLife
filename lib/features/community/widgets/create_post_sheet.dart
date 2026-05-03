import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/post_model.dart';
import '../providers/community_provider.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isPosting = true);

    final user = ref.read(currentUserProvider);
    final county = ref.read(selectedCountyProvider);
    final post = PostModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.id ?? 'anonymous',
      userName: user?.displayName ?? 'Anonymous',
      userInitials: user?.initials ?? 'A',
      content: text,
      county: county == 'All' ? null : county,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(postActionsProvider.notifier).createPost(post);
    setState(() => _isPosting = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final county = ref.watch(selectedCountyProvider);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Header row
              Row(
                children: [
                  Text(
                    'New Post',
                    style: AppTypography.headlineMedium.copyWith(
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // County tag
                  if (county != 'All')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.accent.withOpacity(0.15)
                            : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color:
                                isDark ? AppColors.accent : AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            county,
                            style: AppTypography.labelSmall.copyWith(
                              color:
                                  isDark ? AppColors.accent : AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.avatarMd,
                    height: AppSpacing.avatarMd,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Center(
                      child: Text(
                        user?.initials ?? 'U',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLines: 6,
                      minLines: 3,
                      style: AppTypography.bodyLarge.copyWith(
                        color: textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's happening in your city?",
                        hintStyle: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Bottom action bar
              Row(
                children: [
                  Icon(Icons.image_outlined,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                      size: 22),
                  const SizedBox(width: AppSpacing.base),
                  Icon(Icons.location_on_outlined,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                      size: 22),
                  const Spacer(),
                  SizedBox(
                    width: 80,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _post,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.accent : AppColors.primary,
                        foregroundColor:
                            isDark ? AppColors.primary : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Post',
                              style: AppTypography.labelLarge.copyWith(
                                color:
                                    isDark ? AppColors.primary : Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
