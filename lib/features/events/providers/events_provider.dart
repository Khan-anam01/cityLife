import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/events_repository.dart';
import '../models/event_model.dart';

// ── Filter state ───────────────────────────────────────
final eventCategoryProvider = StateProvider<String?>((ref) => null);
final eventSearchProvider = StateProvider<String>((ref) => '');

// ── RSVP'd event IDs (local session state) ────────────
final rsvpProvider = StateNotifierProvider<RSVPNotifier, Set<String>>(
  (ref) => RSVPNotifier(),
);

class RSVPNotifier extends StateNotifier<Set<String>> {
  RSVPNotifier() : super({});

  void toggle(String eventId) {
    if (state.contains(eventId)) {
      state = {...state}..remove(eventId);
    } else {
      state = {...state, eventId};
    }
  }

  bool isRSVPd(String eventId) => state.contains(eventId);
}

// ── All events ─────────────────────────────────────────
final allEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  await EventsRepository.instance.seedEvents();
  return EventsRepository.instance.getUpcoming();
});

// ── Filtered events ────────────────────────────────────
final filteredEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final all = ref.watch(allEventsProvider);
  final category = ref.watch(eventCategoryProvider);
  final search = ref.watch(eventSearchProvider).trim().toLowerCase();

  return all.whenData((events) {
    var filtered = events;

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((e) => e.category == category).toList();
    }

    if (search.isNotEmpty) {
      filtered = filtered
          .where((e) =>
              e.title.toLowerCase().contains(search) ||
              e.venue.toLowerCase().contains(search) ||
              (e.category?.toLowerCase().contains(search) ?? false))
          .toList();
    }

    return filtered;
  });
});

// ── Event categories ───────────────────────────────────
final eventCategoriesProvider = Provider<List<Map<String, dynamic>>>((ref) => [
      {'id': null, 'label': 'All', 'emoji': '🗓️'},
      {'id': 'Music', 'label': 'Music', 'emoji': '🎵'},
      {'id': 'Technology', 'label': 'Tech', 'emoji': '💻'},
      {'id': 'Sports', 'label': 'Sports', 'emoji': '🏃'},
      {'id': 'Food', 'label': 'Food', 'emoji': '🍽️'},
      {'id': 'Arts', 'label': 'Arts', 'emoji': '🎨'},
      {'id': 'Business', 'label': 'Business', 'emoji': '💼'},
      {'id': 'Community', 'label': 'Community', 'emoji': '🤝'},
      {'id': 'Education', 'label': 'Education', 'emoji': '📚'},
    ]);
