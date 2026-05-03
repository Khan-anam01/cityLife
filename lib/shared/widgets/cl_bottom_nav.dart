import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/scaffold_key.dart';
import '../../features/auth/providers/auth_provider.dart';

// ── Nav Item Model ─────────────────────────────────────
class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

// ══════════════════════════════════════════════════════
// MAIN SHELL
// ══════════════════════════════════════════════════════
class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const List<_NavItem> _items = [
    _NavItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded),
    _NavItem(
        label: 'Explore',
        icon: Icons.map_outlined,
        activeIcon: Icons.map_rounded),
    _NavItem(
        label: 'Community',
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded),
    _NavItem(
        label: 'Jobs',
        icon: Icons.work_outline_rounded,
        activeIcon: Icons.work_rounded),
    _NavItem(
        label: 'Events',
        icon: Icons.event_outlined,
        activeIcon: Icons.event_rounded),
  ];

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // Track horizontal drag to detect intentional swipes
  double _dragStartX = 0;
  static const double _swipeThreshold = 80.0; // min px to count as a swipe

  void _goTo(int index) {
    if (index < 0 || index >= MainShell._items.length) return;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onNavTap(int index) => _goTo(index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = widget.navigationShell.currentIndex;

    // Community tab (index 2) has its own horizontal TabBar —
    // disable swipe there to avoid gesture conflicts.
    final swipeEnabled = currentIndex != 2;

    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(),
      body: GestureDetector(
        onHorizontalDragStart:
            swipeEnabled ? (d) => _dragStartX = d.globalPosition.dx : null,
        onHorizontalDragEnd: swipeEnabled
            ? (d) {
                final delta = d.globalPosition.dx - _dragStartX;
                if (delta.abs() < _swipeThreshold) return;
                if (delta < 0) {
                  // Swipe left → next tab
                  _goTo(currentIndex + 1);
                } else {
                  // Swipe right → previous tab
                  _goTo(currentIndex - 1);
                }
              }
            : null,
        // Pass all other gestures through to children
        behavior: HitTestBehavior.translucent,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              children: List.generate(MainShell._items.length, (index) {
                final item = MainShell._items[index];
                final isSelected = currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onNavTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? Container(
                                  key: ValueKey('active_$index'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.accent.withOpacity(0.15)
                                        : AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    item.activeIcon,
                                    size: AppSpacing.bottomNavIconSize,
                                    color: isDark
                                        ? AppColors.accent
                                        : AppColors.primary,
                                  ),
                                )
                              : Icon(
                                  key: ValueKey('inactive_$index'),
                                  item.icon,
                                  size: AppSpacing.bottomNavIconSize,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textTertiary,
                                ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: AppTypography.navLabel.copyWith(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.accent
                                    : AppColors.primary)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// APP DRAWER
// ══════════════════════════════════════════════════════
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ── Profile Header ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.primary.withOpacity(0.03),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with online dot
                  Stack(
                    children: [
                      Container(
                        width: AppSpacing.avatarXl,
                        height: AppSpacing.avatarXl,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.4),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user?.initials ?? 'CL',
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                            border: Border.all(
                              color:
                                  isDark ? AppColors.darkSurface : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user?.displayName ?? 'City Life User',
                    style: AppTypography.headlineMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      user?.role.name.toUpperCase() ?? 'USER',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.accent,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Menu Items ──────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  const _DrawerSection(label: 'Account'),
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bookmark_outline_rounded,
                    label: 'Saved Items',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.history_rounded,
                    label: 'Activity History',
                    onTap: () => Navigator.pop(context),
                  ),

                  const _DrawerSection(label: 'City Services'),
                  _DrawerItem(
                    icon: Icons.report_problem_outlined,
                    label: 'My Reports',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/my-reports');
                    },
                  ),
                  // ── Post a Job (company only) ────────
                  if (user?.role.name == 'company')
                    _DrawerItem(
                      icon: Icons.post_add_rounded,
                      label: 'Post a Job',
                      badge: 'Biz',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/post-job');
                      },
                    ),
                  _DrawerItem(
                    icon: Icons.cloud_upload_rounded,
                    label: 'Seed Demo Data',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/seed'); // This will open SeedDataScreen
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.event_outlined,
                    label: 'My Events',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/my-events');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.newspaper_rounded,
                    label: 'City News',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/news');
                    },
                  ),
                  const _DrawerSection(label: 'Preferences'),
                  // Dark mode toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: 2,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadiusSm,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            size: AppSpacing.iconMd,
                            color: isDark
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Dark Mode',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: themeMode == ThemeMode.dark,
                            onChanged: (_) => ref
                                .read(themeModeProvider.notifier)
                                .toggleTheme(),
                            activeColor: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Sign Out ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
              ),
              child: _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                color: AppColors.error,
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Drawer Section Header ──────────────────────────────
class _DrawerSection extends StatelessWidget {
  final String label;
  const _DrawerSection({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      child: Text(label.toUpperCase(), style: AppTypography.overline),
    );
  }
}

// ── Drawer Menu Item ───────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final String? badge;

  const _DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: 0,
      ),
      leading: Icon(icon, size: AppSpacing.iconMd, color: effectiveColor),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(color: effectiveColor),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
