import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart'; // Optional: for local sync
import '../../features/news/models/news_model.dart';
import '../../features/events/models/event_model.dart';
import '../../shared/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get newsCollection => _db.collection('news');
  CollectionReference get eventsCollection => _db.collection('events');
  CollectionReference get usersCollection => _db.collection('users');

  // ── Users ──────────────────────────────────────────────

  /// Creates a new user document in Firestore. Called after registration.
  Future<void> createUser(UserModel user) async {
    await usersCollection.doc(user.id).set(user.toFirestore());
  }

  /// Fetches a user document by UID. Returns null if not found.
  Future<UserModel?> getUser(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Updates specific fields on a user document.
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await usersCollection.doc(uid).update({
      ...fields,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Real-time stream of a single user document.
  Stream<UserModel?> userStream(String uid) {
    return usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // Add a single News item
  Future<void> addNews(NewsModel news) async {
    await newsCollection.doc(news.id).set(news.toFirestore());
  }

  // Add multiple News (batch for seed data)
  Future<void> addNewsBatch(List<NewsModel> newsList) async {
    final batch = _db.batch();
    for (var news in newsList) {
      final docRef = newsCollection.doc(news.id);
      batch.set(docRef, news.toFirestore());
    }
    await batch.commit();
  }

  // Same for Events
  Future<void> addEvent(EventModel event) async {
    await eventsCollection.doc(event.id).set(event.toFirestore());
  }

  Future<void> addEventsBatch(List<EventModel> eventsList) async {
    final batch = _db.batch();
    for (var event in eventsList) {
      final docRef = eventsCollection.doc(event.id);
      batch.set(docRef, event.toFirestore());
    }
    await batch.commit();
  }

  // Real-time listeners (for screens)
  Stream<List<NewsModel>> getNewsStream() {
    return newsCollection
        .orderBy('published_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NewsModel.fromFirestore(doc)).toList());
  }

  Stream<List<EventModel>> getEventsStream() {
    return eventsCollection
        .where('start_date', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('start_date')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // One-time fetch
  Future<List<NewsModel>> getNews() async {
    final snapshot =
        await newsCollection.orderBy('published_at', descending: true).get();
    return snapshot.docs.map((doc) => NewsModel.fromFirestore(doc)).toList();
  }
}
