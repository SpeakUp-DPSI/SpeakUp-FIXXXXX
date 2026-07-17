import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/follow_up_model.dart';

class FollowUpRemoteDataSource {
  final SupabaseClient supabaseClient;

  FollowUpRemoteDataSource(this.supabaseClient);

  Future<List<FollowUpModel>> getFollowUpsByReport(String reportId) async {
    try {
      final response = await supabaseClient
          .from('follow_ups')
          .select('*, report:reports!follow_ups_report_id_fkey(*), executor:profiles!follow_ups_executor_id_fkey(*)')
          .eq('report_id', reportId)
          .order('created_at', ascending: false);
          
      final list = response as List;
      return list.map((json) => FollowUpModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<FollowUpModel> createFollowUp(String reportId, Map<String, dynamic> data) async {
    try {
      final insertData = {
        ...data,
        'report_id': reportId,
      };
      final response = await supabaseClient
          .from('follow_ups')
          .insert(insertData)
          .select('*, report:reports!follow_ups_report_id_fkey(*), executor:profiles!follow_ups_executor_id_fkey(*)')
          .single();
          
      return FollowUpModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
