import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRemoteDataSource {
  final SupabaseClient supabaseClient;

  DashboardRemoteDataSource(this.supabaseClient);

  Future<DashboardStatsModel> getStatistics() async {
    try {
      final response = await supabaseClient.rpc('dashboard_statistics');
      return DashboardStatsModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
