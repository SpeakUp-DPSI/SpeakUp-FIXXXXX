import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/follow_up_model.dart';

final followUpsProvider = FutureProvider.autoDispose<List<FollowUpModel>>((ref) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.dio.get('/reports');
    if (response.data['success'] == true) {
      final responseData = response.data['data'];
      List<dynamic> reportList;
      if (responseData is Map && responseData.containsKey('data')) {
        reportList = responseData['data'] as List;
      } else if (responseData is List) {
        reportList = responseData;
      } else {
        reportList = [];
      }
      
      List<FollowUpModel> followUps = [];
      for (var report in reportList) {
        if (report['follow_ups'] != null && (report['follow_ups'] as List).isNotEmpty) {
          for (var fu in report['follow_ups']) {
            fu['report'] = {'report_code': report['report_code']};
            followUps.add(FollowUpModel.fromJson(fu));
          }
        }
      }
      return followUps;
    }
    return [];
  } catch (_) {
    return [];
  }
});

class FollowUpScreen extends ConsumerWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followUpsAsync = ref.watch(followUpsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tindak Lanjut & Riwayat', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: followUpsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => EmptyStateWidget(
          icon: Icons.cloud_off,
          title: 'Gagal memuat tindak lanjut',
          subtitle: 'Tarik ke bawah untuk mencoba lagi.',
          iconColor: AppTheme.danger600,
        ),
        data: (followUps) {
          if (followUps.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.task_alt,
              title: 'Belum ada tindak lanjut',
              subtitle: 'Catatan tindak lanjut yang dibuat oleh Guru BK akan muncul di sini.',
              iconColor: AppTheme.primary600,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(followUpsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: followUps.length,
              itemBuilder: (context, index) {
                final followUp = followUps[index];
                return _buildFollowUpCard(followUp);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowUpCard(FollowUpModel followUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.task_alt, color: AppTheme.success600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  followUp.reportCode ?? 'Laporan #${followUp.reportId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(followUp.actionTaken, style: const TextStyle(color: AppTheme.neutral700)),
          if (followUp.followUpDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppTheme.neutral500),
                const SizedBox(width: 4),
                Text(
                  '${followUp.followUpDate!.day}/${followUp.followUpDate!.month}/${followUp.followUpDate!.year}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.neutral500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
