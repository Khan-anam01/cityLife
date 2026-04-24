import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/amenity_model.dart';

class AmenityCard extends StatelessWidget {
  final AmenityModel amenity;
  const AmenityCard({super.key, required this.amenity});

  Color get _categoryColor {
    switch (amenity.category) {
      case 'hospital':
        return AppColors.moduleHospital;
      case 'school':
        return AppColors.moduleSchool;
      case 'restaurant':
        return AppColors.moduleRestaurant;
      case 'police':
        return AppColors.primary;
      case 'bank':
        return AppColors.accent;
      case 'pharmacy':
        return AppColors.lavender;
      case 'park':
        return AppColors.success;
      case 'transport':
        return AppColors.moduleTransport;
      default:
        return AppColors.primary;
    }
  }

  String get _categoryEmoji {
    switch (amenity.category) {
      case 'hospital':
        return '🏥';
      case 'school':
        return '🎓';
      case 'restaurant':
        return '🍽️';
      case 'police':
        return '👮';
      case 'bank':
        return '🏦';
      case 'pharmacy':
        return '💊';
      case 'park':
        return '🌳';
      case 'transport':
        return '🚌';
      default:
        return '📍';
    }
  }

  Future<void> _call() async {
    if (amenity.phone == null || amenity.phone!.isEmpty) return;
    final uri = Uri.parse('tel:${amenity.phone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMaps() async {
    if (amenity.latitude == null || amenity.longitude == null) return;
    final uri = Uri.parse(
      'https://maps.google.com/?q=${amenity.latitude},${amenity.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _categoryColor;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextSecondary : AppColors.textTertiary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // ── Main content ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category emoji box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      _categoryEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              amenity.name,
                              style: AppTypography.headlineSmall.copyWith(
                                fontSize: 14,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: amenity.isOpen
                                  ? AppColors.success.withOpacity(0.12)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              amenity.isOpen ? 'Open' : 'Closed',
                              style: AppTypography.labelSmall.copyWith(
                                color: amenity.isOpen
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          amenity.categoryLabel,
                          style: AppTypography.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Address
                      if (amenity.address != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: textTertiary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                amenity.address!,
                                style: AppTypography.caption.copyWith(
                                  color: textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      // Hours
                      if (amenity.hours != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: textTertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              amenity.hours!,
                              style: AppTypography.caption.copyWith(
                                color: textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Rating
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          amenity.rating.toStringAsFixed(1),
                          style: AppTypography.labelMedium.copyWith(
                            fontSize: 12,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${amenity.ratingCount}',
                      style: AppTypography.caption.copyWith(
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action buttons ────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor),
              ),
            ),
            child: Row(
              children: [
                if (amenity.phone != null && amenity.phone!.isNotEmpty)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.phone_outlined,
                      label: 'Call',
                      onTap: _call,
                      color: AppColors.success,
                      isFirst: true,
                      borderColor: borderColor,
                    ),
                  ),
                if (amenity.latitude != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.directions_rounded,
                      label: 'Directions',
                      onTap: _openMaps,
                      color: AppColors.sky,
                      isFirst: amenity.phone == null || amenity.phone!.isEmpty,
                      borderColor: borderColor,
                    ),
                  ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.bookmark_outline_rounded,
                    label: 'Save',
                    onTap: () {},
                    color: AppColors.lavender,
                    isFirst: false,
                    borderColor: borderColor,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isFirst;
  final Color borderColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.isFirst,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: isFirst
              ? null
              : Border(
                  left: BorderSide(color: borderColor),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
