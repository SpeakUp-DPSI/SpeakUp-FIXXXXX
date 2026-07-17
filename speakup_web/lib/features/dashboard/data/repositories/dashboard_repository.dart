import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepository(this.remoteDataSource);

  Future<DashboardStatsModel> getStatistics() async {
    return await remoteDataSource.getStatistics();
  }
}
