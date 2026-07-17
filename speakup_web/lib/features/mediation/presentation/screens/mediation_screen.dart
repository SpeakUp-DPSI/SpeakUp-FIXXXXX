import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/mediation_model.dart';
import '../providers/mediation_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class MediationScreen extends ConsumerStatefulWidget {
  const MediationScreen({super.key});

  @override
  ConsumerState<MediationScreen> createState() => _MediationScreenState();
}

class _MediationScreenState extends ConsumerState<MediationScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String mediationId, String status) async {
    setState(() => _isUpdating = true);
    try {
      final dataSource = ref.read(mediationRemoteDataSourceProvider);
      await dataSource.updateParticipantStatus(mediationId, status);
      ref.invalidate(myMediationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted' ? 'Kehadiran dikonfirmasi.' : 'Anda menyatakan berhalangan.'),
            backgroundColor: status == 'accepted' ? AppTheme.success600 : AppTheme.danger600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: AppTheme.danger600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediationsAsync = ref.watch(myMediationsProvider);
    final authState = ref.watch(authProvider);
    
    bool isOrtu = false;
    String currentUserId = '';
    
    if (authState is AuthSuccess) {
      isOrtu = authState.user.roles.contains('ortu') || authState.user.roles.contains('wali');
      currentUserId = authState.user.id;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: const Text('Jadwal Mediasi', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: Stack(
        children: [
          mediationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => EmptyStateWidget(
              icon: Icons.cloud_off,
              title: 'Gagal memuat mediasi',
              subtitle: 'Tarik ke bawah untuk mencoba lagi.\n$err',
              iconColor: AppTheme.danger600,
            ),
            data: (mediations) {
              if (mediations.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.handshake_outlined,
                  title: 'Belum ada jadwal mediasi',
                  subtitle: 'Jadwal mediasi yang melibatkan Anda akan muncul di sini.',
                  iconColor: AppTheme.primary600,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(myMediationsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mediations.length,
                  itemBuilder: (context, index) {
                    final mediation = mediations[index];
                    return _buildMediationCard(context, mediation, isOrtu, currentUserId);
                  },
                ),
              );
            },
          ),
          if (_isUpdating)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildMediationCard(BuildContext context, MediationModel mediation, bool isOrtu, String currentUserId) {
    final statusColor = _getStatusColor(mediation.status);
    final myStatus = mediation.myStatus(currentUserId);

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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _formatStatus(mediation.status),
                      style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (isOrtu) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getParticipantStatusColor(myStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getParticipantStatusColor(myStatus)),
                  ),
                  child: Text(
                    _formatParticipantStatus(myStatus),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getParticipantStatusColor(myStatus)),
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Jadwal', '${mediation.scheduleDate.day}/${mediation.scheduleDate.month}/${mediation.scheduleDate.year} ${mediation.scheduleDate.hour}:${mediation.scheduleDate.minute.toString().padLeft(2, '0')}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Lokasi', mediation.location),
          if (mediation.mediatorName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, 'Mediator (Guru BK)', mediation.mediatorName!),
          ],
          if (mediation.result != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.notes, 'Hasil Mediasi', mediation.result!),
          ],
          
          if (isOrtu && myStatus == 'pending' && mediation.status != 'completed') ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Konfirmasi Kehadiran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.neutral700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger600,
                      side: const BorderSide(color: AppTheme.danger600),
                    ),
                    onPressed: () => _updateStatus(mediation.id, 'rejected'),
                    child: const Text('Berhalangan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _updateStatus(mediation.id, 'accepted'),
                    child: const Text('Hadir'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.neutral500),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppTheme.neutral500)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.neutral900))),
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

  String _formatParticipantStatus(String status) {
    switch (status) {
      case 'accepted': return 'Hadir';
      case 'rejected': return 'Berhalangan';
      default: return 'Belum Konfirmasi';
    }
  }

  Color _getParticipantStatusColor(String status) {
    switch (status) {
      case 'accepted': return AppTheme.success600;
      case 'rejected': return AppTheme.danger600;
      default: return AppTheme.warning600;
    }
  }
}
