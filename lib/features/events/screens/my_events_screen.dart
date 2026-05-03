import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../repository/events_repository.dart';
import '../widgets/event_card.dart';

// ── Provider: events created by the current user ───────
final myEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return EventsRepository.instance.getByOrganizerId(user.id);
});

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myEvents = ref.watch(myEventsProvider);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Events',
          style: AppTypography.headlineSmall.copyWith(color: textPrimary),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textSecondary, size: 20),
            onPressed: () => ref.invalidate(myEventsProvider),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/create-event');
          // Refresh list when returning from create screen
          ref.invalidate(myEventsProvider);
        },
        backgroundColor: AppColors.amber,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: myEvents.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.amber,
            strokeWidth: 2,
          ),
        ),
        error: (e, _) => _ErrorState(
          error: e.toString(),
          onRetry: () => ref.invalidate(myEventsProvider),
          isDark: isDark,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        data: (events) {
          if (events.isEmpty) {
            return _EmptyState(
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary);
          }

          // Split into upcoming and past
          final now = DateTime.now();
          final upcoming =
              events.where((e) => e.startDate.isAfter(now)).toList();
          final past = events.where((e) => !e.startDate.isAfter(now)).toList();

          return RefreshIndicator(
            color: AppColors.amber,
            onRefresh: () async => ref.invalidate(myEventsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                100, // room for FAB
              ),
              children: [
                // ── Stats row ──────────────────────────
                _StatsRow(
                  total: events.length,
                  upcoming: upcoming.length,
                  past: past.length,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Upcoming events ────────────────────
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Upcoming',
                    count: upcoming.length,
                    color: AppColors.amber,
                    icon: Icons.upcoming_rounded,
                    isDark: isDark,
                    textPrimary: textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...upcoming.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child:
                          _MyEventCard(event: event, isDark: isDark, ref: ref),
                    ),
                  ),
                ],

                // ── Past events ────────────────────────
                if (past.isNotEmpty) ...[
                  if (upcoming.isNotEmpty)
                    const SizedBox(height: AppSpacing.sm),
                  _SectionHeader(
                    label: 'Past',
                    count: past.length,
                    color: textSecondary,
                    icon: Icons.history_rounded,
                    isDark: isDark,
                    textPrimary: textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...past.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Opacity(
                        opacity: 0.65,
                        child: _MyEventCard(
                            event: event, isDark: isDark, ref: ref),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Stats row ────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int total;
  final int upcoming;
  final int past;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _StatsRow({
    required this.total,
    required this.upcoming,
    required this.past,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Stat(
                label: 'Total',
                value: total,
                color: AppColors.primary,
                textPrimary: textPrimary,
                textSecondary: textSecondary),
            VerticalDivider(color: borderColor, thickness: 1, width: 1),
            _Stat(
                label: 'Upcoming',
                value: upcoming,
                color: AppColors.amber,
                textPrimary: textPrimary,
                textSecondary: textSecondary),
            VerticalDivider(color: borderColor, thickness: 1, width: 1),
            _Stat(
                label: 'Past',
                value: past,
                color: textSecondary,
                textPrimary: textPrimary,
                textSecondary: textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color textPrimary;
  final Color textSecondary;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTypography.headlineLarge
                .copyWith(color: color, fontSize: 26),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.bodySmall.copyWith(color: textSecondary)),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isDark;
  final Color textPrimary;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isDark,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.headlineSmall
              .copyWith(color: textPrimary, fontSize: 15),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style:
                AppTypography.labelSmall.copyWith(color: color, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ── My event card (event_card extended with delete action) ─
class _MyEventCard extends ConsumerWidget {
  final EventModel event;
  final bool isDark;
  final WidgetRef ref;

  const _MyEventCard({
    required this.event,
    required this.isDark,
    required this.ref,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Event?', style: AppTypography.headlineMedium),
        content: Text(
          'This will permanently remove "${event.title}". This action cannot be undone.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await EventsRepository.instance.delete(event.id);
      ref.invalidate(myEventsProvider);
      ref.invalidate(allEventsProvider);
    }
  }

  String _categoryEmoji(String? cat) {
    const map = {
      'Music': '🎵',
      'Technology': '💻',
      'Sports': '🏃',
      'Food': '🍽️',
      'Arts': '🎨',
      'Business': '💼',
      'Community': '🤝',
      'Education': '📚',
    };
    return map[cat] ?? '🗓️';
  }

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
    final color = _categoryColor(event.category);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final isUpcoming = event.startDate.isAfter(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Color header with status ─────────────
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isUpcoming ? color : AppColors.textTertiary,
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
                // ── Category + status badges ─────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_categoryEmoji(event.category),
                              style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            event.category ?? 'Event',
                            style: AppTypography.labelSmall
                                .copyWith(color: color, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isUpcoming ? AppColors.success : textSecondary)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isUpcoming ? 'Upcoming' : 'Past',
                        style: AppTypography.labelSmall.copyWith(
                          color: isUpcoming ? AppColors.success : textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                    // Delete button
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            size: 16, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Title ────────────────────────────
                Text(
                  event.title,
                  style: AppTypography.headlineMedium
                      .copyWith(color: textPrimary, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Date & venue ─────────────────────
                _Row(
                    icon: Icons.calendar_today_outlined,
                    label: '${event.formattedDate} · ${event.formattedTime}',
                    color: color,
                    textColor: textSecondary),
                const SizedBox(height: 4),
                _Row(
                    icon: Icons.location_on_outlined,
                    label: event.venue,
                    color: AppColors.textTertiary,
                    textColor: textSecondary),

                if (event.attendees > 0) ...[
                  const SizedBox(height: 4),
                  _Row(
                      icon: Icons.people_outline_rounded,
                      label: '${event.attendees} attending',
                      color: AppColors.textTertiary,
                      textColor: textSecondary),
                ],

                const SizedBox(height: AppSpacing.md),

                // ── View details button ───────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        context.push('/event/${event.id}', extra: event),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('View Details',
                        style: AppTypography.labelLarge
                            .copyWith(fontSize: 13, color: color)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _Row(
      {required this.icon,
      required this.label,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(label,
              style: AppTypography.bodySmall.copyWith(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ── Empty state ──────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _EmptyState(
      {required this.isDark,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withOpacity(0.1),
              ),
              child: const Icon(Icons.event_outlined,
                  color: AppColors.amber, size: 44),
            ),
            const SizedBox(height: 20),
            Text('No Events Yet',
                style:
                    AppTypography.headlineMedium.copyWith(color: textPrimary)),
            const SizedBox(height: 8),
            Text(
              "You haven't created any events. Tap the + button to host your first one.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ──────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _ErrorState(
      {required this.error,
      required this.onRetry,
      required this.isDark,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style:
                    AppTypography.headlineMedium.copyWith(color: textPrimary)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: textSecondary),
                maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
