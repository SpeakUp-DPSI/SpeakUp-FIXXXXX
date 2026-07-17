import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/mediation_model.dart';

final mediationsProvider = FutureProvider.autoDispose<List<MediationModel>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  
  try {
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
      
      List<MediationModel> mediations = [];
      for (var report in reportList) {
        if (report['mediations'] != null && (report['mediations'] as List).isNotEmpty) {
          for (var m in report['mediations']) {
            m['report'] = {'report_code': report['report_code']};
            mediations.add(MediationModel.fromJson(m));
          }
        }
      }
      return mediations;
    }
    return [];
  } catch (_) {
    return [];
  }
});

class MediationScreen extends ConsumerWidget {
  const MediationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediationsAsync = ref.watch(mediationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mediasi', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: mediationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => EmptyStateWidget(
          icon: Icons.cloud_off,
          title: 'Gagal memuat mediasi',
          subtitle: 'Tarik ke bawah untuk mencoba lagi.',
          iconColor: AppTheme.danger600,
        ),
        data: (mediations) {
          if (mediations.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.handshake_outlined,
              title: 'Belum ada mediasi',
              subtitle: 'Jadwal mediasi yang dibuat oleh Guru BK akan muncul di sini.',
              iconColor: AppTheme.primary600,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mediationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mediations.length,
              itemBuilder: (context, index) {
                final mediation = mediations[index];
                return _buildMediationCard(context, mediation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediationCard(BuildContext context, MediationModel mediation) {
    final statusColor = _getStatusColor(mediation.status);
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.handshake, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mediation.reportCode ?? 'Laporan #${mediation.reportId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatStatus(mediation.status),
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Jadwal', '${mediation.scheduleDate.day}/${mediation.scheduleDate.month}/${mediation.scheduleDate.year} ${mediation.scheduleDate.hour}:${mediation.scheduleDate.minute.toString().padLeft(2, '0')}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Lokasi', mediation.location),
          if (mediation.result != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.notes, 'Hasil', mediation.result!),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/mediation-detail', extra: mediation),
              child: const Text('Lihat Detail'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.neutral500),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.neutral500)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
      ],
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'scheduled': return 'Dijadwalkan';
      case 'ongoing': return 'Sedang Berlangsung';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return AppTheme.warning600;
      case 'ongoing': return AppTheme.info600;
      case 'completed': return AppTheme.success600;
      case 'cancelled': return AppTheme.danger600;
      default: return AppTheme.neutral500;
    }
  }
}
