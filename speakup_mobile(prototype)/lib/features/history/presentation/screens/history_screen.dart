import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../report/presentation/providers/report_provider.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _activeFilter = '';

  final List<Map<String, String>> _filters = [
    {'value': '', 'label': 'Semua'},
    {'value': 'processing', 'label': 'Diproses'},
    {'value': 'completed', 'label': 'Selesai'},
    {'value': 'rejected', 'label': 'Ditolak'},
  ];

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── AppBar ──────────────────────────────────────────────
            _buildAppBar(context),

            // ─── Judul ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: const Text(
                  'Riwayat Laporan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary600,
                  ),
                ),
              ),
            ),

            // ─── Filter Chips ─────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final isActive = _activeFilter == f['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _activeFilter = f['value']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary600 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppTheme.primary600
                              : AppTheme.neutral300,
                        ),
                      ),
                      child: Text(
                        f['label']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : AppTheme.neutral600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ─── List ─────────────────────────────────────────────────
            Expanded(
              child: reportsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => EmptyStateWidget(
                  icon: Icons.cloud_off,
                  title: 'Gagal memuat riwayat',
                  subtitle: 'Tarik ke bawah untuk mencoba lagi.',
                  iconColor: AppTheme.danger600,
                ),
                data: (reports) {
                  var filtered = reports;
                  if (_activeFilter.isNotEmpty) {
                    filtered = reports
                        .where((r) => r.status == _activeFilter)
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.history,
                      title: 'Tidak ada laporan',
                      subtitle: _activeFilter.isEmpty
                          ? 'Laporan yang Anda buat akan muncul di sini.'
                          : 'Tidak ada laporan dengan status ini.',
                      actionLabel: _activeFilter.isEmpty ? 'Buat Laporan' : null,
                      onAction: _activeFilter.isEmpty
                          ? () => context.push('/report/create')
                          : null,
                    );
                  }

                  return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(reportsListProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final report = filtered[index];
                        return _buildReportCard(context, report);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, dynamic report) {
    final badgeColor = _getBadgeColor(report.status);
    final statusLabel = _formatStatus(report.status);
    final icon = _getCategoryIcon(report.title ?? '');

    return GestureDetector(
      onTap: () => context.push('/report/${report.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neutral300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primary50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary600, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.reportCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    report.title ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.neutral500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  IconData _getCategoryIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('verbal')) return Icons.chat_bubble_outline;
    if (t.contains('fisik') || t.contains('pemerasan')) {
      return Icons.back_hand_outlined;
    }
    if (t.contains('sosial') || t.contains('pengucilan')) {
      return Icons.people_outline;
    }
    if (t.contains('cyber')) return Icons.computer_outlined;
    return Icons.access_time_outlined;
  }


  Color _getBadgeColor(String status) {
    switch (status) {
      case 'processing':
        return AppTheme.primary600;
      case 'completed':
        return const Color(0xFF0D9488);
      case 'rejected':
        return AppTheme.danger600;
      case 'waiting_validation':
        return const Color(0xFFD97706);
      default:
        return AppTheme.neutral500;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'waiting_validation':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'mediation':
        return 'Mediasi';
      case 'follow_up':
        return 'Tindak Lanjut';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Terkirim';
    }
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

Widget _buildAppBar(BuildContext context) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        const SizedBox(width: 8),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary600,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 6),
        const Text(
          'SpeakUp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary600,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppTheme.neutral700),
          onPressed: () {},
        ),
      ],
    ),
  );
}
