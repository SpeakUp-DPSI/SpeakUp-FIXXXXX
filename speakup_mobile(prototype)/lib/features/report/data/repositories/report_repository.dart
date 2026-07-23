import '../datasources/report_remote_data_source.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report_model.dart';

class ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepository(this.remoteDataSource);

  Future<PaginatedReports> getReports({String? search, String? status, String? category, String? sort, int page = 1}) async {
    return await remoteDataSource.getReports(search: search, status: status, category: category, sort: sort, page: page);
  }

  Future<ReportModel> getReportById(String id) async {
    return await remoteDataSource.getReportById(id);
  }

  Future<ReportModel> createReport(Map<String, dynamic> data, {List<XFile>? files}) {
    return remoteDataSource.createReport(data, files: files);
  }

  Future<void> updateStatus(String reportId, String status, {String? notes}) {
    return remoteDataSource.updateStatus(reportId, status, notes: notes);
  }
}
