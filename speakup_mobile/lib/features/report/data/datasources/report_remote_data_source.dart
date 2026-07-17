import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/report_model.dart';

class PaginatedReports {
  final List<ReportModel> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedReports({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });
}

class ReportRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportRemoteDataSource(this.supabaseClient);

  Future<PaginatedReports> getReports({String? search, String? status, String? category, String? sort, int page = 1}) async {
    try {
      final perPage = 10;
      final from = (page - 1) * perPage;
      final to = from + perPage - 1;

      var query = supabaseClient.from('reports').select('''
        *,
        reporter:profiles!reports_reporter_id_fkey(*),
        participants:report_participants(*),
        evidence(*)
      ''');

      if (search != null && search.isNotEmpty) {
        query = query.ilike('title', '%$search%');
      }
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      var orderedQuery = sort == 'oldest' 
          ? query.order('created_at', ascending: true)
          : query.order('created_at', ascending: false);

      final response = await orderedQuery.range(from, to).count(CountOption.exact);

      final total = response.count ?? 0;
      final data = response.data;

      final lastPage = (total / perPage).ceil();

      return PaginatedReports(
        data: data.map((json) => ReportModel.fromJson(json)).toList(),
        currentPage: page,
        lastPage: lastPage == 0 ? 1 : lastPage,
        total: total,
        perPage: perPage,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ReportModel> getReportById(String id) async {
    try {
      final response = await supabaseClient.from('reports').select('''
        *,
        reporter:profiles!reports_reporter_id_fkey(*),
        participants:report_participants(*),
        evidence(*),
        status_histories:report_status_histories(*)
      ''').eq('id', id).single();
      
      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ReportModel> createReport(Map<String, dynamic> data, {List<XFile>? files}) async {
    try {
      final participants = data.remove('participants') as List<dynamic>?;
      
      final reportResponse = await supabaseClient.from('reports').insert(data).select().single();
      final reportId = reportResponse['id'];

      if (participants != null && participants.isNotEmpty) {
        final participantData = participants.map((p) => {
          ...p as Map<String, dynamic>,
          'report_id': reportId,
        }).toList();
        await supabaseClient.from('report_participants').insert(participantData);
      }

      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final bytes = await file.readAsBytes();
          final fileName = file.name;
          final storagePath = '$reportId/$fileName';
          
          await supabaseClient.storage.from('evidence').uploadBinary(storagePath, bytes);
          final fileUrl = supabaseClient.storage.from('evidence').getPublicUrl(storagePath);
          
          await supabaseClient.from('evidence').insert({
            'report_id': reportId,
            'file_url': fileUrl,
            'file_name': fileName,
          });
        }
      }

      return getReportById(reportId.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateStatus(String reportId, String status, {String? notes}) async {
    try {
      final updateData = {'status': status};
      if (notes != null) updateData['bk_note'] = notes;

      await supabaseClient.from('reports').update(updateData).eq('id', reportId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
