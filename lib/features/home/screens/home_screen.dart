import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/weather_widget.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/featured_events_section.dart';
import '../widgets/news_preview_section.dart';
import '../widgets/emergency_sos_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── App Bar ─────────────────────────────
              SliverToBoxAdapter(
                child: HomeHeader(user: user),
              ),

              // ── Emergency SOS Banner ─────────────────
              const SliverToBoxAdapter(
                child: EmergencySOSBanner(),
              ),

              // ── Weather Widget ───────────────────────
              const SliverToBoxAdapter(
                child: WeatherWidget(),
              ),

              // ── Quick Actions ────────────────────────
              const SliverToBoxAdapter(
                child: QuickActionsGrid(),
              ),

              // ── Featured Events ──────────────────────
              const SliverToBoxAdapter(
                child: FeaturedEventsSection(),
              ),

              // ── News Preview ─────────────────────────
              const SliverToBoxAdapter(
                child: NewsSectionPreview(),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.massive),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
