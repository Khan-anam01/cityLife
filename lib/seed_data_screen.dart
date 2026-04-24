import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../../features/news/models/news_model.dart';
import '../../features/events/models/event_model.dart';
import '../../core/database/database_helper.dart';

class SeedDataScreen extends ConsumerWidget {
  const SeedDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = FirestoreService();

    Future<void> seedAllData() async {
      try {
        final dbHelper = DatabaseHelper.instance;
        final db = await dbHelper.database;

        // ── Seed News ─────────────────────────────────────
        final newsMaps = await db.query('news');
        final newsList = newsMaps.map((map) => NewsModel.fromMap(map)).toList();

        await firestoreService.addNewsBatch(newsList);
        print('✅ Seeded ${newsList.length} News items');

        // ── Seed Events ───────────────────────────────────
        final eventsMaps = await db.query('events');
        final eventsList =
            eventsMaps.map((map) => EventModel.fromMap(map)).toList();

        await firestoreService.addEventsBatch(eventsList);
        print('✅ Seeded ${eventsList.length} Events');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 All data seeded to Firestore successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('❌ Seeding failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Seed Data to Firestore')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: seedAllData,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Seed All News & Events to Firestore'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
