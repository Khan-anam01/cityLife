import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/amenity_list_view.dart';
import '../widgets/amenity_map_view.dart';
import '../widgets/amenity_search_bar.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore', style: AppTypography.displaySmall),
                        Text(
                          'Find amenities near you',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── List / Map toggle ────────────────
                  SizedBox(
                    width: 88,
                    height: 38,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.cardRadiusSm),
                        border: Border.all(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: false,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: EdgeInsets.zero,
                        indicator: BoxDecoration(
                          color: isDark ? AppColors.accent : AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadiusSm,
                          ),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                        tabs: const [
                          Tab(child: Icon(Icons.list_rounded, size: 18)),
                          Tab(child: Icon(Icons.map_rounded, size: 18)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ───────────────────────────────
            const AmenitySearchBar(),

            // ── Category Filter ──────────────────────────
            const CategoryFilterBar(),

            const SizedBox(height: AppSpacing.sm),

            // ── Content ──────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  AmenityListView(),
                  AmenityMapView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
