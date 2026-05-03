import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/amenity_model.dart';
import '../providers/amenities_provider.dart';

class AmenityMapView extends ConsumerStatefulWidget {
  const AmenityMapView({super.key});

  @override
  ConsumerState<AmenityMapView> createState() => _AmenityMapViewState();
}

class _AmenityMapViewState extends ConsumerState<AmenityMapView> {
  GoogleMapController? _mapController;
  AmenityModel? _selectedAmenity;
  LatLng _center = const LatLng(-1.2864, 36.8172); // Nairobi default
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _center = LatLng(pos.latitude, pos.longitude);
          _locationLoaded = true;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_center, 14),
        );
      }
    } catch (_) {}
  }

  Set<Marker> _buildMarkers(List<AmenityModel> amenities) {
    return amenities
        .where((a) => a.latitude != null && a.longitude != null)
        .map(
          (a) => Marker(
            markerId: MarkerId(a.id),
            position: LatLng(a.latitude!, a.longitude!),
            infoWindow: InfoWindow(
              title: a.name,
              snippet: a.address ?? a.categoryLabel,
            ),
            onTap: () => setState(() => _selectedAmenity = a),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredAmenitiesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return filtered.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(
        child: Text(
          'Could not load amenities',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ),
      data: (amenities) => Stack(
        children: [
          // ── Google Map ─────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 13,
            ),
            cloudMapId: "d9b24a12aac2fec4d7a87909",
            markers: _buildMarkers(amenities),
            onMapCreated: (controller) {
              _mapController = controller;
              // Center on user location once map is ready
              if (_locationLoaded) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_center, 14),
                );
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) => setState(() => _selectedAmenity = null),
          ),

          // ── My Location FAB ────────────────────────
          Positioned(
            bottom: _selectedAmenity != null ? 200 : 24,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'location_btn',
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              elevation: 2,
              onPressed: () async {
                await _getUserLocation();
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(_center, 15),
                  );
                }
              },
              child: Icon(
                Icons.my_location_rounded,
                color: isDark ? AppColors.accent : AppColors.primary,
                size: 20,
              ),
            ),
          ),

          // ── Count badge ────────────────────────────
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '${amenities.where((a) => a.latitude != null).length} places on map',
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          // ── Selected Amenity Bottom Card ───────────
          if (_selectedAmenity != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SelectedAmenityCard(
                amenity: _selectedAmenity!,
                isDark: isDark,
                onClose: () => setState(() => _selectedAmenity = null),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Selected amenity card ──────────────────────────────
class _SelectedAmenityCard extends StatelessWidget {
  final AmenityModel amenity;
  final bool isDark;
  final VoidCallback onClose;

  const _SelectedAmenityCard({
    required this.amenity,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  amenity.name,
                  style:
                      AppTypography.headlineMedium.copyWith(color: textPrimary),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (amenity.address != null) ...[
            const SizedBox(height: 2),
            Text(
              amenity.address!,
              style: AppTypography.bodySmall.copyWith(color: textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                '${amenity.rating.toStringAsFixed(1)} · ${amenity.ratingCount} reviews',
                style: AppTypography.labelMedium
                    .copyWith(fontSize: 12, color: textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: amenity.isOpen
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  amenity.isOpen ? 'Open Now' : 'Closed',
                  style: AppTypography.labelSmall.copyWith(
                    color: amenity.isOpen ? AppColors.success : AppColors.error,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (amenity.latitude == null) return;
                    final uri = Uri.parse(
                      'https://maps.google.com/?q=${amenity.latitude},${amenity.longitude}',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (amenity.phone != null && amenity.phone!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${amenity.phone}');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? AppColors.accent : AppColors.primary,
                    side: BorderSide(
                      color: isDark ? AppColors.accent : AppColors.primary,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
