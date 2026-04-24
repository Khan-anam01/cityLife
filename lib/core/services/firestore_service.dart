import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart'; // Optional: for local sync
import '../../features/news/models/news_model.dart';
import '../../features/events/models/event_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get newsCollection => _db.collection('news');
  CollectionReference get eventsCollection => _db.collection('events');

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
