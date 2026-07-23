import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/mediation_model.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/mediation_remote_data_source.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final myMediationsProvider = FutureProvider.autoDispose<List<MediationModel>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final ds = MediationRemoteDataSource(supabase);
  return ds.getMyMediations();
});

// ── Screen ─────────────────────────────────────────────────────────────────

class ParentMediationScreen extends ConsumerStatefulWidget {
  const ParentMediationScreen({super.key});

  @override
  ConsumerState<ParentMediationScreen> createState() => _ParentMediationScreenState();
}

class _ParentMediationScreenState extends ConsumerState<ParentMediationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _loadingMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmAttendance(MediationModel med, String status) async {
    setState(() => _loadingMap[med.id] = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      final ds = MediationRemoteDataSource(supabase);
      await ds.updateParticipantStatus(med.id, status);
      ref.invalidate(myMediationsProvider);
      if (mounted) {
        final msg = status == 'confirmed' ? 'Kehadiran dikonfirmasi' : 'Ketidakhadiran dikonfirmasi';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: status == 'confirmed' ? AppTheme.success600 : AppTheme.danger600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppTheme.danger600),
        );
      }
    } finally {
      setState(() => _loadingMap[med.id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediationsAsync = ref.watch(myMediationsProvider);
    final authState = ref.watch(authProvider);
    final userId = authState is AuthSuccess ? authState.user.id : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Mediasi Anak',
          style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary600,
          unselectedLabelColor: AppTheme.neutral500,
          indicatorColor: AppTheme.primary600,
          tabs: const [
            Tab(text: 'Perlu Konfirmasi'),
            Tab(text: 'Semua'),
          ],
        ),
      ),
      body: mediationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => EmptyStateWidget(
          icon: Icons.cloud_off,
          title: 'Gagal memuat mediasi',
          subtitle: 'Tarik ke bawah untuk mencoba lagi.',
          iconColor: AppTheme.danger600,
        ),
        data: (mediations) {
          final pending = mediations.where((m) => m.myStatus(userId) == 'pending').toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myMediationsProvider),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(pending, userId, showAttendance: true),
                _buildList(mediations, userId, showAttendance: false),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<MediationModel> list, String userId, {required bool showAttendance}) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.handshake_outlined,
        title: 'Tidak ada mediasi',
        subtitle: showAttendance
            ? 'Semua undangan mediasi sudah dikonfirmasi.'
            : 'Belum ada mediasi untuk anak Anda.',
        iconColor: AppTheme.neutral400,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildCard(list[index], userId);
      },);
  }

  Widget _buildCard(MediationModel med, String userId) {
    final statusColor = _statusColor(med.status);
    final myStatusColor = _myStatusColor(med.myStatus(userId));
    final myStatusLabel = _myStatusLabel(med.myStatus(userId));
    final isLoading = _loadingMap[med.id] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.handshake, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.reportCode ?? 'Laporan #${med.reportId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.neutral900),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _badge(_statusLabel(med.status), statusColor),
                          const SizedBox(width: 6),
                          _badge(myStatusLabel, myStatusColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _infoRow(Icons.calendar_today_outlined, 'Jadwal',
                    '${med.scheduleDate.day}/${med.scheduleDate.month}/${med.scheduleDate.year}  ${med.scheduleDate.hour.toString().padLeft(2, "0")}:${med.scheduleDate.minute.toString().padLeft(2, "0")} WIB'),
                const SizedBox(height: 6),
                _infoRow(Icons.location_on_outlined, 'Lokasi', med.location),
                if (med.mediatorName != null) ...[
                  const SizedBox(height: 6),
                  _infoRow(Icons.person_outline, 'Mediator', med.mediatorName!),
                ],
                if (med.result != null) ...[
                  const SizedBox(height: 6),
                  _infoRow(Icons.notes_outlined, 'Hasil Mediasi', med.result!),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          if (med.myStatus(userId) == 'pending')
            Padding(
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmAttendance(med, 'rejected'),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Tidak Hadir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.danger600,
                              side: const BorderSide(color: AppTheme.danger600),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmAttendance(med, 'confirmed'),
                            icon: const Icon(Icons.check, size: 16, color: Colors.white),
                            label: const Text('Hadir', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.success600,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/mediation-detail', extra: med),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary600,
                    side: const BorderSide(color: AppTheme.primary600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Lihat Detail'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );

  Widget _infoRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.neutral400),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.neutral500)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.neutral900)),
          ),
        ],
      );

  String _statusLabel(String s) {
    switch (s) {
      case 'scheduled': return 'Dijadwalkan';
      case 'ongoing': return 'Berlangsung';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return s;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'scheduled': return AppTheme.warning600;
      case 'ongoing': return AppTheme.info600;
      case 'completed': return AppTheme.success600;
      case 'cancelled': return AppTheme.danger600;
      default: return AppTheme.neutral500;
    }
  }

  String _myStatusLabel(String? s) {
    switch (s) {
      case 'pending': return 'Belum Konfirmasi';
      case 'confirmed': return 'Akan Hadir';
      case 'rejected': return 'Tidak Hadir';
      case 'attended': return 'Sudah Hadir';
      default: return 'Belum Konfirmasi';
    }
  }

  Color _myStatusColor(String? s) {
    switch (s) {
      case 'pending': return AppTheme.warning600;
      case 'confirmed': return AppTheme.success600;
      case 'rejected': return AppTheme.danger600;
      case 'attended': return AppTheme.info600;
      default: return AppTheme.warning600;
    }
  }
}
