import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRSVPd = ref.watch(rsvpProvider).contains(event.id);
    final color = _categoryColor(event.category);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                  color: textPrimary,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        _getCategoryEmoji(event.category),
                        style: const TextStyle(fontSize: 64),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Price badges
                  Row(
                    children: [
                      _Badge(
                        label: event.category ?? 'Event',
                        color: color,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _Badge(
                        label: event.priceLabel,
                        color:
                            event.isFree ? AppColors.success : AppColors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    event.title,
                    style: AppTypography.displaySmall.copyWith(
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Info cards row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_rounded,
                          title: 'Date',
                          value: event.formattedDate,
                          subtitle: event.formattedTime,
                          color: color,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.people_rounded,
                          title: 'Attending',
                          value: '${event.attendees}',
                          subtitle: event.capacity != null
                              ? 'of ${event.capacity}'
                              : 'people',
                          color: AppColors.moduleSocial,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Venue card
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    title: 'Venue',
                    value: event.venue,
                    color: AppColors.coral,
                    isDark: isDark,
                    onTap: event.latitude != null
                        ? () async {
                            final uri = Uri.parse(
                              'https://maps.google.com/?q=${event.latitude},${event.longitude}',
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (event.organizer != null)
                    _DetailRow(
                      icon: Icons.person_rounded,
                      title: 'Organizer',
                      value: event.organizer!,
                      color: AppColors.sky,
                      isDark: isDark,
                    ),
                  const SizedBox(height: AppSpacing.xl),

                  // Description
                  if (event.description != null) ...[
                    Text(
                      'About this event',
                      style: AppTypography.headlineMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      event.description!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: textSecondary,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Capacity bar
                  if (event.capacity != null) ...[
                    Text(
                      'Capacity',
                      style: AppTypography.headlineSmall.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: event.attendees / event.capacity!,
                        minHeight: 8,
                        backgroundColor:
                            isDark ? AppColors.darkBorder : AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${event.attendees} / ${event.capacity} spots filled',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Bottom padding for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── RSVP FAB ──────────────────────────────────
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => ref.read(rsvpProvider.notifier).toggle(event.id),
          backgroundColor: isRSVPd ? AppColors.success : color,
          foregroundColor: Colors.white,
          elevation: 4,
          label: Row(
            children: [
              Icon(
                isRSVPd
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isRSVPd
                    ? 'You\'re going! Tap to cancel'
                    : 'RSVP for this event',
                style: AppTypography.buttonText,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getCategoryEmoji(String? cat) {
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
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(color: color, fontSize: 12),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
