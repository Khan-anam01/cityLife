import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/news_repository.dart';
import '../models/news_model.dart';

final newsCategoryProvider = StateProvider<String>((ref) => 'All');
final newsSearchProvider = StateProvider<String>((ref) => '');

final newsProvider =
    StateNotifierProvider<NewsNotifier, AsyncValue<List<NewsModel>>>(
  (ref) => NewsNotifier(ref),
);

class NewsNotifier extends StateNotifier<AsyncValue<List<NewsModel>>> {
  NewsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    await NewsRepository.instance.seedNews();
    await load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final category = ref.read(newsCategoryProvider);
      final search = ref.read(newsSearchProvider).trim();
      List<NewsModel> articles;
      if (search.isNotEmpty) {
        articles = await NewsRepository.instance.search(search);
      } else {
        articles = await NewsRepository.instance.getAll(
          category: category == 'All' ? null : category,
        );
      }
      state = AsyncValue.data(articles);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final newsCategoriesProvider = Provider<List<String>>((ref) => [
      'All',
      'Transport',
      'Health',
      'Technology',
      'Education',
      'Business',
      'Environment',
      'Security',
      'Sports',
      'Politics',
    ]);
