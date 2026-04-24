import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/event_category_filter.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = ref.watch(filteredEventsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Events', style: AppTypography.displaySmall),
                  Text(
                    'Discover what\'s happening in your city',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.xs,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    ref.read(eventSearchProvider.notifier).state = v,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textTertiary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              size: 18, color: AppColors.textTertiary),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(eventSearchProvider.notifier).state = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.accent : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // ── Category filter ───────────────────────
            const EventCategoryFilter(),
            const SizedBox(height: AppSpacing.sm),

            // ── Events list ───────────────────────────
            Expanded(
              child: filtered.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (e, _) => Center(
                  child: Text('Could not load events',
                      style: AppTypography.bodyMedium),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📅', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: AppSpacing.md),
                          Text('No events found',
                              style: AppTypography.headlineSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Check back later for upcoming events',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      AppSpacing.massive,
                    ),
                    itemCount: events.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => EventCard(event: events[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
