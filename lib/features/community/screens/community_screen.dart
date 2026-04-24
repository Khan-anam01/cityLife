import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/community_provider.dart';
import '../widgets/feed_tab.dart';
import '../widgets/groups_tab.dart';
import '../widgets/messages_tab.dart';
import '../widgets/create_post_sheet.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openSideNav() => _scaffoldKey.currentState?.openEndDrawer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      // ── End drawer — Groups & Messages ──────────────────
      endDrawer: _CommunityDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Community',
                      style: AppTypography.displaySmall,
                    ),
                  ),
                  // County filter
                  _CountyFilterButton(),
                  const SizedBox(width: AppSpacing.sm),
                  // Groups & Messages side nav trigger
                  GestureDetector(
                    onTap: _openSideNav,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.background,
                        border: Border.all(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          // Unread badge (static for now — wire to real count later)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.accent
                                    : AppColors.primary,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBackground
                                      : AppColors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Feed (For You / Following / Constituency) ────
            const Expanded(child: FeedTab()),
          ],
        ),
      ),

      // ── FAB — compose post ───────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const CreatePostSheet(),
        ),
        backgroundColor: isDark ? AppColors.accent : AppColors.primary,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }
}

// ── End Drawer ──────────────────────────────────────────
class _CommunityDrawer extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends ConsumerState<_CommunityDrawer>
    with SingleTickerProviderStateMixin {
  late TabController _drawerTabController;

  @override
  void initState() {
    super.initState();
    _drawerTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _drawerTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final county = ref.watch(selectedCountyProvider);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ── Drawer header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      county == 'All' ? 'Community' : county,
                      style: AppTypography.headlineMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // ── Drawer tab bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: TabBar(
                  controller: _drawerTabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(3),
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.accent : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  labelStyle: AppTypography.labelMedium.copyWith(fontSize: 12),
                  tabs: const [
                    Tab(text: 'Groups'),
                    Tab(text: 'Messages'),
                  ],
                ),
              ),
            ),

            // ── Drawer content ─────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _drawerTabController,
                children: const [
                  GroupsTab(),
                  MessagesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── County filter button (unchanged) ───────────────────
class _CountyFilterButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final county = ref.watch(selectedCountyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counties = ref.watch(countiesProvider);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _CountyPicker(counties: counties),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: county == 'All'
              ? (isDark ? AppColors.darkSurface : AppColors.background)
              : (isDark
                  ? AppColors.accent.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: county == 'All'
                ? (isDark ? AppColors.darkBorder : AppColors.border)
                : (isDark ? AppColors.accent : AppColors.primary),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 14,
              color: county == 'All'
                  ? AppColors.textTertiary
                  : (isDark ? AppColors.accent : AppColors.primary),
            ),
            const SizedBox(width: 4),
            Text(
              county,
              style: AppTypography.labelMedium.copyWith(
                fontSize: 12,
                color: county == 'All'
                    ? (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)
                    : (isDark ? AppColors.accent : AppColors.primary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: county == 'All'
                  ? AppColors.textTertiary
                  : (isDark ? AppColors.accent : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountyPicker extends ConsumerWidget {
  final List<String> counties;
  const _CountyPicker({required this.counties});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCountyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
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
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Text(
            'Filter by County',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: counties.length,
            itemBuilder: (context, i) {
              final county = counties[i];
              final isSelected = selected == county;
              return ListTile(
                title: Text(
                  county,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected
                        ? (isDark ? AppColors.accent : AppColors.primary)
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        size: 18,
                      )
                    : null,
                onTap: () {
                  ref.read(selectedCountyProvider.notifier).state = county;
                  ref.read(postsProvider.notifier).loadPosts();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
