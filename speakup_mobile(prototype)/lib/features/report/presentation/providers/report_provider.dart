import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/report_remote_data_source.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/models/report_model.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return ReportRemoteDataSource(supabaseClient);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remote = ref.read(reportRemoteDataSourceProvider);
  return ReportRepository(remote);
});

class ReportsNotifier extends AsyncNotifier<PaginatedReports> {
  int _currentPage = 1;
  String? _search;
  String? _status;
  String? _category;
  String? _sort;

  @override
  Future<PaginatedReports> build() async {
    final repository = ref.read(reportRepositoryProvider);
    return await repository.getReports(page: _currentPage);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || _currentPage >= current.lastPage) return;
    _currentPage++;
    final repository = ref.read(reportRepositoryProvider);
    final next = await repository.getReports(
      search: _search,
      status: _status,
      category: _category,
      sort: _sort,
      page: _currentPage,
    );
    state = AsyncData(PaginatedReports(
      data: [...current.data, ...next.data],
      currentPage: next.currentPage,
      lastPage: next.lastPage,
      total: next.total,
      perPage: next.perPage,
    ));
  }

  Future<void> refresh() async {
    _currentPage = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reportRepositoryProvider);
      return await repository.getReports(
        search: _search,
        status: _status,
        category: _category,
        sort: _sort,
        page: 1,
      );
    });
  }

  Future<void> filter({String? search, String? status, String? category, String? sort}) async {
    _search = search;
    _status = status;
    _category = category;
    _sort = sort;
    _currentPage = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reportRepositoryProvider);
      return await repository.getReports(
        search: search,
        status: status,
        category: category,
        sort: sort,
        page: 1,
      );
    });
  }
}

final reportsProvider = AsyncNotifierProvider<ReportsNotifier, PaginatedReports>(() {
  return ReportsNotifier();
});

final reportsListProvider = FutureProvider.autoDispose<List<ReportModel>>((ref) async {
  final reportsAsync = ref.watch(reportsProvider);
  return reportsAsync.whenOrNull(data: (paginated) => paginated.data) ?? [];
});

final reportDetailProvider = FutureProvider.autoDispose.family<ReportModel?, String>((ref, id) async {
  final repository = ref.read(reportRepositoryProvider);
  try {
    return await repository.getReportById(id);
  } catch (_) {
    return null;
  }
});

class ReportSearchNotifier extends Notifier<List<ReportModel>> {
  Timer? _debounce;

  @override
  List<ReportModel> build() {
    return [];
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        state = [];
        return;
      }
      try {
        final repository = ref.read(reportRepositoryProvider);
        final result = await repository.getReports(search: query);
        state = result.data;
      } catch (_) {
        state = [];
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = [];
  }
}

final reportSearchProvider = NotifierProvider<ReportSearchNotifier, List<ReportModel>>(() {
  return ReportSearchNotifier();
});

class CreateReportNotifier extends AsyncNotifier<ReportModel?> {
  @override
  FutureOr<ReportModel?> build() {
    return null;
  }

  Future<ReportModel?> create(Map<String, dynamic> data, {List<XFile>? files}) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(reportRepositoryProvider);
      final created = await repository.createReport(data, files: files);
      ref.invalidate(reportsProvider);
      state = AsyncData(created);
      return created;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final createReportProvider = AsyncNotifierProvider<CreateReportNotifier, ReportModel?>(() {
  return CreateReportNotifier();
});
