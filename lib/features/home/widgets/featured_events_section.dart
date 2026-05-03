import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';

class _MockEvent {
  final String id;
  final String title;
  final String venue;
  final String date;
  final String category;
  final Color color;
  final String emoji;

  const _MockEvent({
    required this.id,
    required this.title,
    required this.venue,
    required this.date,
    required this.category,
    required this.color,
    required this.emoji,
  });
}

class FeaturedEventsSection extends StatelessWidget {
  const FeaturedEventsSection({super.key});

  static const List<_MockEvent> _events = [
    _MockEvent(
      id: 'e1',
      title: 'Nairobi Music Festival',
      venue: 'Uhuru Gardens',
      date: 'Sat, Apr 26',
      category: 'Music',
      color: AppColors.amber,
      emoji: '🎵',
    ),
    _MockEvent(
      id: 'e2',
      title: 'Tech Summit 2026',
      venue: 'KICC, Nairobi',
      date: 'Fri, May 2',
      category: 'Technology',
      color: AppColors.sky,
      emoji: '💻',
    ),
    _MockEvent(
      id: 'e3',
      title: 'City Marathon',
      venue: 'Nyayo Stadium',
      date: 'Sun, May 10',
      category: 'Sports',
      color: AppColors.accent,
      emoji: '🏃',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sectionGap,
            AppSpacing.screenPadding,
            AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Events',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  )),
              GestureDetector(
                onTap: () => context.go(AppRoutes.nearby),
                child: Text(
                  'See all',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            itemCount: _events.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _EventCard(event: _events[index]),
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final _MockEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge + emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: AppTypography.labelSmall.copyWith(
                      color: event.color,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(event.emoji, style: const TextStyle(fontSize: 24)),
              ],
            ),
            const Spacer(),

            // Title
            Text(
              event.title,
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 14,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Venue + Date
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 11,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    event.venue,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 11,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 2),
                Text(
                  event.date,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
