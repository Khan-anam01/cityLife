import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/reports_repository.dart';
import '../models/report_model.dart';
import '../../auth/providers/auth_provider.dart';

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<List<ReportModel>>>(
  (ref) => ReportsNotifier(ref),
);

class ReportsNotifier extends StateNotifier<AsyncValue<List<ReportModel>>> {
  ReportsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(currentUserProvider);
      List<ReportModel> reports;
      if (user != null) {
        reports = await ReportsRepository.instance.getUserReports(user.id);
      } else {
        reports = await ReportsRepository.instance.getAllReports();
      }
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submit(ReportModel report) async {
    await ReportsRepository.instance.createReport(report);
    await load();
  }

  Future<void> delete(String id) async {
    await ReportsRepository.instance.deleteReport(id);
    state =
        state.whenData((reports) => reports.where((r) => r.id != id).toList());
  }
}
