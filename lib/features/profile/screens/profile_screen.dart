import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/community/providers/community_provider.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    // ── Live follow counts ──────────────────────────────
    final followerCount =
        user != null ? ref.watch(followerCountProvider(user.id)) : null;
    final followingCount =
        user != null ? ref.watch(followingCountProvider(user.id)) : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ─────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.darkSurface, AppColors.darkBackground]
                      : [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.base,
                    AppSpacing.screenPadding,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(AppRoutes.editProfile),
                            icon: Icon(Icons.edit_rounded,
                                size: 16,
                                color:
                                    isDark ? AppColors.accent : Colors.white70),
                            label: Text(
                              'Edit',
                              style: AppTypography.labelMedium.copyWith(
                                color:
                                    isDark ? AppColors.accent : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: AppSpacing.avatarXl,
                            height: AppSpacing.avatarXl,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? AppColors.darkSurfaceElevated
                                  : Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.accent.withOpacity(0.4)
                                    : Colors.white.withOpacity(0.6),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user?.initials ?? 'CL',
                                style: AppTypography.displaySmall.copyWith(
                                  color:
                                      isDark ? AppColors.accent : Colors.white,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                          ),
                          if (user?.isVerified == true)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBackground
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Text(
                        user?.displayName ?? 'City Life User',
                        style: AppTypography.headlineLarge.copyWith(
                          color:
                              isDark ? AppColors.darkTextPrimary : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.accent.withOpacity(0.15)
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.accent.withOpacity(0.3)
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          user?.role.name.toUpperCase() ?? 'USER',
                          style: AppTypography.overline.copyWith(
                            color: isDark ? AppColors.accent : Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Followers / Following row ───────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FollowStat(
                            label: 'Followers',
                            value: followerCount?.when(
                                  data: (n) => '$n',
                                  loading: () => '—',
                                  error: (_, __) => '0',
                                ) ??
                                '—',
                            isDark: isDark,
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxl),
                            color: isDark
                                ? AppColors.accent.withOpacity(0.3)
                                : Colors.white.withOpacity(0.35),
                          ),
                          _FollowStat(
                            label: 'Following',
                            value: followingCount?.when(
                                  data: (n) => '$n',
                                  loading: () => '—',
                                  error: (_, __) => '0',
                                ) ??
                                '—',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats row ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.xl,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ProfileStatCard(
                      label: 'Reports',
                      value: '0',
                      icon: Icons.report_problem_outlined,
                      color: AppColors.moduleReport,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ProfileStatCard(
                      label: 'Posts',
                      value: '0',
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppColors.moduleSocial,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ProfileStatCard(
                      label: 'Saved',
                      value: '0',
                      icon: Icons.bookmark_outline_rounded,
                      color: AppColors.accent,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Settings sections ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.base),
                  SettingsSection(
                    title: 'Account',
                    isDark: isDark,
                    items: [
                      SettingsItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () => context.push(AppRoutes.editProfile),
                        isDark: isDark,
                      ),
                      SettingsItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        onTap: () {},
                        isDark: isDark,
                      ),
                      SettingsItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: user?.phone ?? 'Not set',
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  SettingsSection(
                    title: 'Preferences',
                    isDark: isDark,
                    items: [
                      SettingsItem(
                        icon: isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        label: 'Dark Mode',
                        isDark: isDark,
                        trailing: Switch.adaptive(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (_) => ref
                              .read(themeModeProvider.notifier)
                              .toggleTheme(),
                          activeColor: AppColors.accent,
                        ),
                        onTap: () =>
                            ref.read(themeModeProvider.notifier).toggleTheme(),
                      ),
                      SettingsItem(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        value: 'English',
                        onTap: () {},
                        isDark: isDark,
                      ),
                      SettingsItem(
                        icon: Icons.location_on_outlined,
                        label: 'Default Location',
                        value: 'Nairobi',
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  SettingsSection(
                    title: 'Notifications',
                    isDark: isDark,
                    items: [
                      SettingsItem(
                        icon: Icons.notifications_outlined,
                        label: 'Push Notifications',
                        isDark: isDark,
                        trailing: Switch.adaptive(
                            value: true,
                            onChanged: (_) {},
                            activeColor: AppColors.accent),
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: Icons.campaign_outlined,
                        label: 'City Announcements',
                        isDark: isDark,
                        trailing: Switch.adaptive(
                            value: true,
                            onChanged: (_) {},
                            activeColor: AppColors.accent),
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: Icons.event_outlined,
                        label: 'Event Reminders',
                        isDark: isDark,
                        trailing: Switch.adaptive(
                            value: false,
                            onChanged: (_) {},
                            activeColor: AppColors.accent),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  SettingsSection(
                    title: 'My Activity',
                    isDark: isDark,
                    items: [
                      SettingsItem(
                        icon: Icons.report_problem_outlined,
                        label: 'My Reports',
                        onTap: () => context.push('/my-reports'),
                        isDark: isDark,
                        showArrow: true,
                      ),
                      SettingsItem(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Saved Items',
                        onTap: () {},
                        isDark: isDark,
                        showArrow: true,
                      ),
                      SettingsItem(
                        icon: Icons.work_outline_rounded,
                        label: 'Job Applications',
                        onTap: () {},
                        isDark: isDark,
                        showArrow: true,
                      ),
                      SettingsItem(
                        icon: Icons.event_outlined,
                        label: 'My Events',
                        onTap: () {},
                        isDark: isDark,
                        showArrow: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  SettingsSection(
                    title: 'Support',
                    isDark: isDark,
                    items: [
                      SettingsItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ',
                        onTap: () {},
                        isDark: isDark,
                        showArrow: true,
                      ),
                      SettingsItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {},
                        isDark: isDark,
                        showArrow: true,
                      ),
                      SettingsItem(
                        icon: Icons.description_outlined,
                        label: 'Terms of Service',
                        onTap: () {},
                        isDark: isDark,
                        showArrow: true,
                      ),
                      SettingsItem(
                        icon: Icons.info_outline_rounded,
                        label: 'App Version',
                        value: '1.0.0',
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  SettingsSection(
                    title: 'Account Actions',
                    isDark: isDark,
                    items: [
                      SettingsItem(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        color: AppColors.error,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text(
                                  'Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sign Out',
                                      style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await ref.read(authProvider.notifier).signOut();
                            context.go(AppRoutes.login);
                          }
                        },
                        isDark: isDark,
                      ),
                      SettingsItem(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete Account',
                        color: AppColors.error,
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.massive),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inline follow stat widget (sits inside the gradient header) ──
class _FollowStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _FollowStat(
      {required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.accent : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : Colors.white70,
          ),
        ),
      ],
    );
  }
}
