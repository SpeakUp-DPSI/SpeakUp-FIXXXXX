import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';
import '../../../report/data/models/report_model.dart';
import 'web_profile_dropdown.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final reportsAsync = ref.watch(reportsListProvider);

    final isWideScreen = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: isWideScreen ? null : AppBar(
        title: const Text('Dashboard Orang Tua', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Row(
            children: [
              if (MediaQuery.of(context).size.width >= 768)
                const WebProfileDropdown(),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_outlined, color: AppTheme.neutral700, size: 26),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.danger600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(reportsListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.family_restroom, size: 48, color: Colors.white54),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pantau Laporan Anak',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lihat status laporan dan jadwal mediasi yang melibatkan anak Anda.',
                            style: TextStyle(fontSize: 14, color: AppTheme.primary100),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ringkasan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
              ),
              const SizedBox(height: 16),
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => EmptyStateWidget(
                  icon: Icons.cloud_off,
                  title: 'Gagal memuat data',
                  subtitle: 'Tarik ke bawah untuk mencoba lagi.',
                  iconColor: AppTheme.danger600,
                ),
                data: (stats) => Row(
                  children: [
                    _buildStatCard('Total Laporan', '${stats.total}', AppTheme.primary600),
                    const SizedBox(width: 16),
                    _buildStatCard('Selesai', '${stats.completed}', AppTheme.success600),
                    const SizedBox(width: 16),
                    _buildStatCard('Diproses', '${stats.processing}', AppTheme.info600),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laporan Terkini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
                  ),
                  TextButton(
                    onPressed: () => context.go('/reports'),
                    child: const Text('Lihat Semua', style: TextStyle(color: AppTheme.primary600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => EmptyStateWidget(
                  icon: Icons.cloud_off,
                  title: 'Gagal memuat laporan',
                  subtitle: 'Tarik ke bawah untuk mencoba lagi.',
                  iconColor: AppTheme.danger600,
                ),
                data: (reports) {
                  if (reports.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.inbox_outlined,
                      title: 'Belum ada laporan',
                      subtitle: 'Laporan dari anak Anda akan muncul di sini.',
                      iconColor: AppTheme.neutral400,
                    );
                  }
                  return Column(
                    children: reports.take(5).map((r) => _buildReportItem(r, context)).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Jadwal Mediasi Mendatang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
              ),
              const SizedBox(height: 16),
              reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const SizedBox.shrink(),
                data: (reports) {
                  final mediationReports = reports
                      .where((r) =>
                          r.status == 'mediation' &&
                          r.incidentDate != null)
                      .take(3)
                      .toList();
                  if (mediationReports.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.calendar_today_outlined,
                      title: 'Belum ada jadwal mediasi',
                      subtitle: 'Tidak ada jadwal mediasi terkait anak Anda saat ini.',
                      iconColor: AppTheme.neutral400,
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutral300),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < mediationReports.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                          _mediationItemFromReport(mediationReports[i]),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.neutral600)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(ReportModel report, BuildContext context) {
    final statusColor = _getStatusColor(report.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: ListTile(
        onTap: () => context.push('/report/${report.id}'),
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.assignment, color: statusColor),
        ),
        title: Text(report.reportCode, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(_formatStatus(report.status), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'waiting_validation': return 'Menunggu';
      case 'processing': return 'Diproses';
      case 'mediation': return 'Mediasi';
      case 'follow_up': return 'Tindak Lanjut';
      case 'completed': return 'Selesai';
      case 'rejected': return 'Ditolak';
      default: return 'Terkirim';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting_validation': return AppTheme.warning600;
      case 'processing': return AppTheme.info600;
      case 'completed': return AppTheme.success600;
      case 'rejected': return AppTheme.danger600;
      default: return AppTheme.primary600;
    }
  }

  Widget _mediationItemFromReport(ReportModel report) {
    final monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateParts = (report.incidentDate ?? '').split('-');
    final day = dateParts.length >= 3 ? dateParts[2].substring(0, 2) : '--';
    final monthIdx = dateParts.length >= 2 ? int.tryParse(dateParts[1]) ?? 1 : 1;
    final month = monthNames[monthIdx].toUpperCase().substring(0, 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            children: [
              Text(day,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.neutral900)),
              Text(month,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.neutral500)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.reportCode,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.primary600)),
                Text(report.category ?? report.title,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.neutral600)),
                Text(report.incidentLocation ?? '',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.neutral400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
