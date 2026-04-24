import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/scaffold_key.dart';
import '../../../shared/models/user_model.dart';

class HomeHeader extends ConsumerWidget {
  final UserModel? user;
  const HomeHeader({super.key, this.user});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // ── Avatar — opens drawer via global scaffold key ──
          GestureDetector(
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: Stack(
              children: [
                Container(
                  width: AppSpacing.avatarMd,
                  height: AppSpacing.avatarMd,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user?.initials ?? 'CL',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Small menu indicator dot
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.background,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      size: 8,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ── Greeting ───────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  user?.firstName.isNotEmpty == true
                      ? user!.firstName
                      : 'Welcome',
                  style: AppTypography.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Notification bell ──────────────────────────
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push(AppRoutes.notifications),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  size: AppSpacing.iconLg,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coral,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
