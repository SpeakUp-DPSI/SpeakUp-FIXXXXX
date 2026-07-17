import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/validation_model.dart';

class ValidationRemoteDataSource {
  final SupabaseClient supabaseClient;

  ValidationRemoteDataSource(this.supabaseClient);

  Future<List<ValidationModel>> getValidationsByReport(String reportId) async {
    try {
      final response = await supabaseClient
          .from('validations')
          .select('*, validator:profiles!validations_validator_id_fkey(*)')
          .eq('report_id', reportId)
          .order('created_at', ascending: false);
          
      final list = response as List;
      return list.map((json) => ValidationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ValidationModel> createValidation(String reportId, Map<String, dynamic> data) async {
    try {
      final insertData = {
        ...data,
        'report_id': reportId,
      };
      final response = await supabaseClient
          .from('validations')
          .insert(insertData)
          .select('*, validator:profiles!validations_validator_id_fkey(*)')
          .single();
          
      return ValidationModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
