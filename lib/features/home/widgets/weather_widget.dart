import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/weather_provider.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: weatherAsync.when(
        loading: () => const _WeatherSkeleton(),
        error: (_, __) =>
            _WeatherError(onRetry: () => ref.invalidate(weatherProvider)),
        data: (weather) => _WeatherCard(weather: weather),
      ),
    );
  }
}

// ── Live weather card ────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final WeatherData weather;
  const _WeatherCard({required this.weather});

  List<Color> get _gradientColors {
    if (!weather.isDay)
      return [const Color(0xFF1A1A3E), const Color(0xFF2D2D6B)];
    final code = weather.weatherCode;
    if (code == 0 || code == 1)
      return [const Color(0xFF1976D2), const Color(0xFF0D47A1)];
    if (code == 2 || code == 3)
      return [const Color(0xFF546E7A), const Color(0xFF37474F)];
    if (code <= 69) return [const Color(0xFF1565C0), const Color(0xFF0D3B6E)];
    if (code <= 79) return [const Color(0xFF4FC3F7), const Color(0xFF0277BD)];
    if (code <= 99) return [const Color(0xFF37474F), const Color(0xFF1A237E)];
    return [AppColors.primary, const Color(0xFF1A4A7A)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: _gradientColors.first.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: location, temp, condition
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        weather.cityName,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 52,
                        height: 1.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'C',
                        style: AppTypography.headlineSmall
                            .copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                Text(
                  weather.condition,
                  style:
                      AppTypography.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  'Feels like ${weather.feelsLike.round()}°C',
                  style:
                      AppTypography.bodySmall.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),

          // Right: emoji + stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(weather.emoji, style: const TextStyle(fontSize: 54)),
              const SizedBox(height: AppSpacing.sm),
              _WeatherStat(
                icon: Icons.water_drop_outlined,
                label: '${weather.humidity}%',
                hint: 'Humidity',
              ),
              const SizedBox(height: 4),
              _WeatherStat(
                icon: Icons.air_rounded,
                label: '${weather.windSpeed.round()} km/h',
                hint: 'Wind',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ─────────────────────────────────────
class _WeatherSkeleton extends StatefulWidget {
  const _WeatherSkeleton();
  @override
  State<_WeatherSkeleton> createState() => _WeatherSkeletonState();
}

class _WeatherSkeletonState extends State<_WeatherSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(const Color(0xFF1976D2), const Color(0xFF0D47A1),
                  _anim.value)!,
              const Color(0xFF0D47A1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Bar(width: 120, opacity: _anim.value),
                  const SizedBox(height: 8),
                  _Bar(width: 80, height: 44, opacity: _anim.value),
                  const SizedBox(height: 6),
                  _Bar(width: 100, opacity: _anim.value),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Bar(width: 52, height: 52, opacity: _anim.value, radius: 8),
                const SizedBox(height: 8),
                _Bar(width: 70, opacity: _anim.value),
                const SizedBox(height: 4),
                _Bar(width: 70, opacity: _anim.value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  final double radius;
  const _Bar(
      {required this.width,
      required this.opacity,
      this.height = 14,
      this.radius = 6});
  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

// ── Error state ──────────────────────────────────────────
class _WeatherError extends StatelessWidget {
  final VoidCallback onRetry;
  const _WeatherError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF546E7A), Color(0xFF37474F)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white54, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weather unavailable',
                    style:
                        AppTypography.bodyMedium.copyWith(color: Colors.white)),
                Text('Check your connection',
                    style: AppTypography.bodySmall
                        .copyWith(color: Colors.white54)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat pill ─────────────────────────────────────────────
class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  const _WeatherStat(
      {required this.icon, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: 12),
        const SizedBox(width: 4),
        Text(label,
            style: AppTypography.labelSmall.copyWith(color: Colors.white)),
      ],
    );
  }
}
