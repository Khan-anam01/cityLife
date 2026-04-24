import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/jobs_repository.dart';
import '../models/job_model.dart';

final jobCategoryProvider = StateProvider<String>((ref) => 'All');
final jobTypeProvider = StateProvider<String>((ref) => 'All');
final jobSearchProvider = StateProvider<String>((ref) => '');

// ── Saved jobs (local session) ─────────────────────────
final savedJobsProvider = StateNotifierProvider<SavedJobsNotifier, Set<String>>(
  (ref) => SavedJobsNotifier(),
);

class SavedJobsNotifier extends StateNotifier<Set<String>> {
  SavedJobsNotifier() : super({});
  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool isSaved(String id) => state.contains(id);
}

// ── All jobs ───────────────────────────────────────────
final allJobsProvider =
    StateNotifierProvider<JobsNotifier, AsyncValue<List<JobModel>>>(
  (ref) => JobsNotifier(ref),
);

class JobsNotifier extends StateNotifier<AsyncValue<List<JobModel>>> {
  JobsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    await JobsRepository.instance.seedJobs();
    await load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final category = ref.read(jobCategoryProvider);
      final type = ref.read(jobTypeProvider);
      final search = ref.read(jobSearchProvider).trim();

      List<JobModel> jobs;
      if (search.isNotEmpty) {
        jobs = await JobsRepository.instance.search(search);
      } else {
        jobs = await JobsRepository.instance.getAll(
          category: category == 'All' ? null : category,
          type: type == 'All' ? null : type,
        );
      }
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ── Categories & types ─────────────────────────────────
final jobCategoriesProvider = Provider<List<String>>((ref) => [
      'All',
      'Technology',
      'Healthcare',
      'Engineering',
      'Education',
      'Marketing',
      'Design',
      'Finance',
      'Media',
      'Other',
    ]);

final jobTypesProvider = Provider<List<String>>((ref) => [
      'All',
      'full-time',
      'part-time',
      'contract',
      'internship',
      'freelance',
    ]);
