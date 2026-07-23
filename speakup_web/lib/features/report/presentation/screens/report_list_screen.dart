import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/report_model.dart';
import '../providers/report_provider.dart';
import '../widgets/report_search_delegate.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  String _selectedStatus = '';
  String _selectedSort = 'newest';

  final List<Map<String, String>> _statusFilters = [
    {'value': '', 'label': 'Semua'},
    {'value': 'waiting_validation', 'label': 'Menunggu Validasi'},
    {'value': 'valid', 'label': 'Valid'},
    {'value': 'processing', 'label': 'Diproses'},
    {'value': 'mediation', 'label': 'Mediasi'},
    {'value': 'completed', 'label': 'Selesai'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.neutral700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Daftar Laporan',
          style: TextStyle(
              color: AppTheme.neutral900,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined,
                color: AppTheme.neutral700),
            onPressed: () {
              showSearch(
                  context: context, delegate: ReportSearchDelegate(ref));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: () => showSearch(
                  context: context, delegate: ReportSearchDelegate(ref)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.neutral300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppTheme.neutral400, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Cari kode laporan / nama siswa',
                      style: TextStyle(
                          color: AppTheme.neutral400, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Filter Chips ──────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, _a) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _statusFilters[i];
                final activeFirst = i == 0 && _selectedStatus == '';
                final selected =
                    activeFirst || (_selectedStatus == f['value'] && i != 0);
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedStatus = f['value']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary600
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary600
                            : AppTheme.neutral300,
                      ),
                    ),
                    child: Text(
                      f['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppTheme.neutral600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Count + Sort ──────────────────────────────────────────────
          Consumer(
            builder: (context, ref, _) {
              final reportsAsync = ref.watch(reportsListProvider);
              return reportsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
                data: (reports) {
                  final count = _filterReports(reports).length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$count ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.primary600),
                              ),
                              const TextSpan(
                                text: 'Total Laporan',
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.neutral600),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Text('Urutkan',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.neutral400)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() => _selectedSort =
                              _selectedSort == 'newest' ? 'oldest' : 'newest'),
                          child: Row(
                            children: [
                              Text(
                                _selectedSort == 'newest'
                                    ? 'Terbaru'
                                    : 'Terlama',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.neutral700),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.sort,
                                  size: 18, color: AppTheme.neutral500),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // ─── List ──────────────────────────────────────────────────────
          Expanded(child: _buildReportList()),
        ],
      ),
    );
  }

  List<ReportModel> _filterReports(List<ReportModel> all) {
    var filtered = all;
    if (_selectedStatus.isNotEmpty) {
      filtered = all.where((r) => r.status == _selectedStatus).toList();
    }
    return filtered;
  }

  Widget _buildReportList() {
    return Consumer(
      builder: (context, ref, _) {
        final reportsAsync = ref.watch(reportsListProvider);

        return reportsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (err, stack) => EmptyStateWidget(
            icon: Icons.cloud_off,
            title: 'Gagal memuat laporan',
            subtitle: 'Periksa koneksi internet Anda.',
            iconColor: AppTheme.danger600,
          ),
          data: (reports) {
            final filtered = _filterReports(reports);

            if (filtered.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.inbox_outlined,
                title: 'Tidak ada laporan',
                subtitle: 'Tidak ada laporan dengan filter ini.',
                iconColor: AppTheme.neutral400,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(reportsListProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _buildReportCard(filtered[index], context);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportCard(ReportModel report, BuildContext context) {
    final badgeColor = _getBadgeColor(report.status);
    final badgeLabel = _formatStatus(report.status);
    final icon = _getCategoryIcon(report.category ?? report.title);

    return GestureDetector(
      onTap: () => context.push('/report/${report.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category icon ─────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary600, size: 24),
            ),
            const SizedBox(width: 12),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        report.reportCode,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primary600),
                      ),
                      const Spacer(),
                      Text(
                        report.category ?? _getCategoryLabel(report.title, category: report.category),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.neutral900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        report.incidentDate ?? '-',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.neutral400),
                      ),
                      const SizedBox(width: 4),
                      if (report.incidentDate != null)
                        const Text('·',
                            style: TextStyle(color: AppTheme.neutral400)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getReporterName(report),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.neutral500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getReporterClass(report),
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.neutral400),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badgeLabel,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.remove_red_eye_outlined,
                              size: 18, color: AppTheme.primary600),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  IconData _getCategoryIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('verbal')) return Icons.chat_bubble_outline;
    if (l.contains('fisik') || l.contains('pemerasan')) {
      return Icons.back_hand_outlined;
    }
    if (l.contains('sosial') || l.contains('pengucilan')) {
      return Icons.people_outline;
    }
    if (l.contains('cyber')) return Icons.computer_outlined;
    return Icons.description_outlined;
  }

  String _getCategoryLabel(String title, {String? category}) {
    if (category != null && category.isNotEmpty) return category;
    if (title.toLowerCase().contains('verbal')) return 'Verbal';
    if (title.toLowerCase().contains('fisik')) return 'Fisik';
    if (title.toLowerCase().contains('cyber')) return 'Cyber';
    return 'Lainnya';
  }

  String _getReporterName(ReportModel report) {
    if (report.isAnonymous) return 'Anonim';
    if (report.reporter != null) {
      return report.reporter!['name']?.toString() ?? 'Siswa';
    }
    if (report.korban?.name != null) return report.korban!.name!;
    return 'Siswa';
  }

  String _getReporterClass(ReportModel report) {
    if (report.korban?.className != null) return report.korban!.className!;
    return '-';
  }

  Color _getBadgeColor(String status) {
    switch (status) {
      case 'waiting_validation':
        return AppTheme.warning600;
      case 'valid':
        return AppTheme.info600;
      case 'processing':
        return AppTheme.primary600;
      case 'mediation':
        return const Color(0xFF7C3AED);
      case 'completed':
        return AppTheme.success600;
      case 'rejected':
        return AppTheme.danger600;
      default:
        return AppTheme.neutral500;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'waiting_validation':
        return 'Menunggu';
      case 'valid':
        return 'Valid';
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
