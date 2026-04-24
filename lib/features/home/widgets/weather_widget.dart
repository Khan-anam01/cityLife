import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF1A4A7A)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
        ),
        child: Row(
          children: [
            // Weather info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.accent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Nairobi, Kenya',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24°',
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'C',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Partly Cloudy',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Right side — icon + details
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('⛅', style: TextStyle(fontSize: 52)),
                const SizedBox(height: AppSpacing.sm),
                _WeatherStat(
                  icon: Icons.water_drop_outlined,
                  label: '65%',
                  hint: 'Humidity',
                ),
                const SizedBox(height: 4),
                _WeatherStat(
                  icon: Icons.air_rounded,
                  label: '12 km/h',
                  hint: 'Wind',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;

  const _WeatherStat({
    required this.icon,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
