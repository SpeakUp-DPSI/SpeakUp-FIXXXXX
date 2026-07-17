import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mediation_model.dart';

class MediationRemoteDataSource {
  final SupabaseClient supabaseClient;

  MediationRemoteDataSource(this.supabaseClient);

  Future<List<MediationModel>> getMediationsByReport(String reportId) async {
    try {
      final response = await supabaseClient
          .from('mediations')
          .select('*, mediator:profiles!mediations_mediator_id_fkey(*), report:reports!mediations_report_id_fkey(*), participants:mediation_participants(*)')
          .eq('report_id', reportId)
          .order('created_at', ascending: false);
          
      final list = response as List;
      return list.map((json) => MediationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<MediationModel> getMediationById(String id) async {
    try {
      final response = await supabaseClient
          .from('mediations')
          .select('*, mediator:profiles!mediations_mediator_id_fkey(*), report:reports!mediations_report_id_fkey(*), participants:mediation_participants(*)')
          .eq('id', id)
          .single();
          
      return MediationModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<MediationModel> createMediation(String reportId, Map<String, dynamic> data) async {
    try {
      final insertData = {
        ...data,
        'report_id': reportId,
      };
      
      final response = await supabaseClient
          .from('mediations')
          .insert(insertData)
          .select('*, mediator:profiles!mediations_mediator_id_fkey(*), report:reports!mediations_report_id_fkey(*), participants:mediation_participants(*)')
          .single();
          
      return MediationModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<MediationModel> updateMediationStatus(String id, Map<String, dynamic> data) async {
    try {
      final response = await supabaseClient
          .from('mediations')
          .update(data)
          .eq('id', id)
          .select('*, mediator:profiles!mediations_mediator_id_fkey(*), report:reports!mediations_report_id_fkey(*), participants:mediation_participants(*)')
          .single();
          
      return MediationModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> contactParticipant(String id) async {
    try {
      await supabaseClient.rpc('contact_participant', params: {'mediation_id': id});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<MediationModel>> getMyMediations() async {
    try {
      final response = await supabaseClient.rpc('get_my_mediations');
          
      final list = response as List;
      return list.map((json) => MediationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateParticipantStatus(String id, String status) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      await supabaseClient
          .from('mediation_participants')
          .update({'status': status})
          .match({'mediation_id': id, 'user_id': userId});
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
