import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/amenities_repository.dart';
import '../models/amenity_model.dart';

// ── Selected category filter ───────────────────────────
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// ── Search query ───────────────────────────────────────
final amenitySearchProvider = StateProvider<String>((ref) => '');

// ── All amenities (raw from DB) ────────────────────────
final allAmenitiesProvider = FutureProvider<List<AmenityModel>>((ref) async {
  await AmenitiesRepository.instance.seedRichData();
  return AmenitiesRepository.instance.getAll();
});

// ── Filtered amenities (category + search applied) ────
final filteredAmenitiesProvider =
    Provider<AsyncValue<List<AmenityModel>>>((ref) {
  final all = ref.watch(allAmenitiesProvider);
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(amenitySearchProvider).trim().toLowerCase();

  return all.whenData((amenities) {
    var filtered = amenities;

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((a) => a.category == category).toList();
    }

    if (search.isNotEmpty) {
      filtered = filtered
          .where((a) =>
              a.name.toLowerCase().contains(search) ||
              (a.address?.toLowerCase().contains(search) ?? false) ||
              a.category.toLowerCase().contains(search))
          .toList();
    }

    return filtered;
  });
});

// ── Categories list ────────────────────────────────────
final categoriesProvider = Provider<List<Map<String, dynamic>>>((ref) => [
      {'id': null, 'label': 'All', 'icon': '🏙️'},
      {'id': 'hospital', 'label': 'Hospitals', 'icon': '🏥'},
      {'id': 'school', 'label': 'Schools', 'icon': '🎓'},
      {'id': 'restaurant', 'label': 'Restaurants', 'icon': '🍽️'},
      {'id': 'police', 'label': 'Police', 'icon': '👮'},
      {'id': 'bank', 'label': 'Banks', 'icon': '🏦'},
      {'id': 'pharmacy', 'label': 'Pharmacy', 'icon': '💊'},
      {'id': 'park', 'label': 'Parks', 'icon': '🌳'},
      {'id': 'transport', 'label': 'Transport', 'icon': '🚌'},
    ]);
