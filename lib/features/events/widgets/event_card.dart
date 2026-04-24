import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';

class EventCard extends ConsumerWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  Color _categoryColor(String? cat) {
    switch (cat) {
      case 'Music':
        return AppColors.amber;
      case 'Technology':
        return AppColors.sky;
      case 'Sports':
        return AppColors.accent;
      case 'Food':
        return AppColors.moduleRestaurant;
      case 'Arts':
        return AppColors.lavender;
      case 'Business':
        return AppColors.primary;
      case 'Community':
        return AppColors.moduleSocial;
      case 'Education':
        return AppColors.moduleSchool;
      default:
        return AppColors.primary;
    }
  }

  String _categoryEmoji(String? cat) {
    switch (cat) {
      case 'Music':
        return '🎵';
      case 'Technology':
        return '💻';
      case 'Sports':
        return '🏃';
      case 'Food':
        return '🍽️';
      case 'Arts':
        return '🎨';
      case 'Business':
        return '💼';
      case 'Community':
        return '🤝';
      case 'Education':
        return '📚';
      default:
        return '🗓️';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRSVPd = ref.watch(rsvpProvider).contains(event.id);
    final color = _categoryColor(event.category);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}', extra: event),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Color header banner ─────────────────
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.cardRadiusLg),
                  topRight: Radius.circular(AppSpacing.cardRadiusLg),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Free badge row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _categoryEmoji(event.category),
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.category ?? 'Event',
                              style: AppTypography.labelSmall.copyWith(
                                color: color,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: event.isFree
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.priceLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: event.isFree
                                ? AppColors.success
                                : AppColors.amber,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Attendees count
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 13,
                            color: textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${event.attendees}',
                            style: AppTypography.caption.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Title
                  Text(
                    event.title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      color: textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Date & Venue row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.calendar_today_outlined,
                          label:
                              '${event.formattedDate} · ${event.formattedTime}',
                          color: color,
                          textColor: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: event.venue,
                          color: AppColors.textTertiary,
                          textColor: textSecondary,
                        ),
                      ),
                    ],
                  ),

                  if (event.organizer != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _InfoChip(
                      icon: Icons.person_outline_rounded,
                      label: 'By ${event.organizer}',
                      color: AppColors.textTertiary,
                      textColor: textSecondary,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // RSVP + Details buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              ref.read(rsvpProvider.notifier).toggle(event.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 40,
                            decoration: BoxDecoration(
                              color: isRSVPd ? color : color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: color.withOpacity(isRSVPd ? 1 : 0.3),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isRSVPd
                                        ? Icons.check_circle_rounded
                                        : Icons.add_circle_outline_rounded,
                                    size: 16,
                                    color: isRSVPd ? Colors.white : color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isRSVPd ? 'RSVP\'d' : 'RSVP',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: isRSVPd ? Colors.white : color,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => context.push(
                          '/event/${event.id}',
                          extra: event,
                        ),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Center(
                            child: Text(
                              'Details',
                              style: AppTypography.labelLarge.copyWith(
                                fontSize: 13,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
