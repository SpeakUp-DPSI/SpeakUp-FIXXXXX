import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';
import '../../../report/data/models/report_model.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class PrincipalRecapScreen extends ConsumerStatefulWidget {
  const PrincipalRecapScreen({super.key});

  @override
  ConsumerState<PrincipalRecapScreen> createState() =>
      _PrincipalRecapScreenState();
}

class _PrincipalRecapScreenState extends ConsumerState<PrincipalRecapScreen> {
  // ── State ────────────────────────────────────────────────────────────────
  DateTime _startDate = DateTime(2026, 6, 1);
  DateTime _endDate = DateTime(2026, 7, 1);
  String _selectedCategory = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';

  static const _categories = [
    'Semua',
    'Verbal',
    'Fisik',
    'Sosial',
    'Cyberbullying',
  ];

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String get _periodLabel {
    final s = _startDate;
    final e = _endDate;
    if (s.year == e.year) {
      return '${s.day} ${_months[s.month - 1]} – '
          '${e.day} ${_months[e.month - 1]} ${e.year}';
    }
    return '${s.day} ${_months[s.month - 1]} ${s.year} – '
        '${e.day} ${_months[e.month - 1]} ${e.year}';
  }

  Future<void> _pickPeriod() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(reportsProvider);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  List<ReportModel> _applyFilters(List<ReportModel> all) {
    var result = all;

    if (_selectedCategory != 'Semua') {
      result = result.where((r) {
        final cat = (r.category ?? r.title).toLowerCase();
        return cat.contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((r) {
        final code = r.reportCode.toLowerCase();
        final name =
            (r.korban?.name ?? r.reporter?['name'] ?? '').toString().toLowerCase();
        return code.contains(_searchQuery) || name.contains(_searchQuery);
      }).toList();
    }

    return result;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final reportsAsync = ref.watch(reportsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(reportsProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _buildHeader(),
                ),
              ),

              // ── Stat Cards ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: statsAsync.when(
                    loading: () => _buildStatCards(
                        total: 0, diproses: 0, selesai: 0, ditolak: 0),
                    error: (_, _) => _buildStatCards(
                        total: 0, diproses: 0, selesai: 0, ditolak: 0),
                    data: (stats) => _buildStatCards(
                      total: stats.total,
                      diproses: stats.processing + stats.mediation,
                      selesai: stats.completed,
                      ditolak: (stats.total -
                              stats.processing -
                              stats.mediation -
                              stats.completed -
                              stats.valid)
                          .clamp(0, stats.total),
                    ),
                  ),
                ),
              ),

              // ── Category chips ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildCategoryChips(),
                ),
              ),

              // ── Search bar ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _buildSearchBar(),
                ),
              ),

              // ── Count label ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: reportsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (reports) {
                    final filtered = _applyFilters(reports);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '${filtered.length} laporan ditemukan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutral500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Report list ──────────────────────────────────────────────
              reportsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 48, color: AppTheme.neutral300),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat data\n$e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.neutral500),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (reports) {
                  final filtered = _applyFilters(reports);
                  if (filtered.isEmpty) {
                    return const SliverFillRemaining(
                      child: _EmptyState(),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final isLast = i == filtered.length - 1;
                        return Padding(
                          padding:
                              EdgeInsets.fromLTRB(16, 0, 16, isLast ? 32 : 0),
                          child: _buildReportRow(filtered[i], context),
                        );
                      },
                      childCount: filtered.length,
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

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + period ─────────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rekapitulasi Kasus',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppTheme.neutral400),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _periodLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutral500,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // ── Action buttons ─────────────────────────────────────────────────
        Row(
          children: [
            _headerButton(
              icon: Icons.tune_rounded,
              label: 'Ubah Periode',
              onTap: _pickPeriod,
              isPrimary: false,
            ),
            const SizedBox(width: 8),
            _headerButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Export PDF',
              onTap: _exportPdf,
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primary600 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary ? AppTheme.primary600 : AppTheme.neutral300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isPrimary ? Colors.white : AppTheme.neutral700,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppTheme.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Mengekspor periode $_periodLabel…')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary600,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Stat Cards ───────────────────────────────────────────────────────────────

  Widget _buildStatCards({
    required int total,
    required int diproses,
    required int selesai,
    required int ditolak,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.folder_copy_outlined,
            count: '$total',
            label: 'Total Kasus',
            bgColor: const Color(0xFF0D2149),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.sync_rounded,
            count: '$diproses',
            label: 'Diproses',
            bgColor: const Color(0xFFE87C1E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.verified_outlined,
            count: '$selesai',
            label: 'Selesai',
            bgColor: const Color(0xFF0E9E82),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.cancel_outlined,
            count: '$ditolak',
            label: 'Ditolak',
            bgColor: const Color(0xFF8B2424),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String count,
    required String label,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 22),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Category Chips ───────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary600 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppTheme.primary600
                      : AppTheme.neutral300,
                ),
              ),
              child: Text(
                cat,
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
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.neutral400, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.neutral900,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari kode laporan atau nama siswa',
                hintStyle:
                    TextStyle(color: AppTheme.neutral400, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.close,
                    color: AppTheme.neutral400, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ── Report Row ───────────────────────────────────────────────────────────────

  Widget _buildReportRow(ReportModel report, BuildContext context) {
    final badgeColor = StatusColors.of(report.status);
    final badgeLabel = StatusColors.labelOf(report.status);
    final categoryLabel = _categoryLabel(report);
    final handledBy = _handledBy(report);

    return GestureDetector(
      onTap: () => context.push('/report/${report.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        child: Column(
          children: [
            // ── Stripe warna status di bagian atas card ───────────────────
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ikon kategori ───────────────────────────────────────
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primary50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon(report),
                      color: AppTheme.primary600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Blok informasi ──────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kode laporan + badge status
                        Row(
                          children: [
                            Text(
                              report.reportCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.primary600,
                              ),
                            ),
                            const Spacer(),
                            _statusBadge(badgeLabel, badgeColor),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Kategori
                        _infoRow(
                          icon: Icons.label_outline,
                          text: categoryLabel,
                          color: AppTheme.neutral700,
                          bold: true,
                        ),
                        const SizedBox(height: 3),

                        // Tanggal kejadian
                        _infoRow(
                          icon: Icons.calendar_today_outlined,
                          text: report.incidentDate ?? '-',
                          color: AppTheme.neutral500,
                        ),
                        const SizedBox(height: 3),

                        // Ditangani oleh
                        _infoRow(
                          icon: Icons.person_outline,
                          text: 'Ditangani: $handledBy',
                          color: AppTheme.neutral500,
                        ),
                      ],
                    ),
                  ),

                  // ── Chevron ─────────────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(Icons.chevron_right_rounded,
                        color: AppTheme.neutral300, size: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    required Color color,
    bool bold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.neutral400),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Local helpers ────────────────────────────────────────────────────────────

  IconData _categoryIcon(ReportModel r) {
    final label = (r.category ?? r.title).toLowerCase();
    if (label.contains('verbal')) return Icons.chat_bubble_outline;
    if (label.contains('fisik') || label.contains('pemerasan')) {
      return Icons.back_hand_outlined;
    }
    if (label.contains('sosial') || label.contains('pengucilan')) {
      return Icons.people_outline;
    }
    if (label.contains('cyber')) return Icons.computer_outlined;
    return Icons.description_outlined;
  }

  String _categoryLabel(ReportModel r) {
    if (r.category != null && r.category!.isNotEmpty) return r.category!;
    final t = r.title.toLowerCase();
    if (t.contains('verbal')) return 'Verbal';
    if (t.contains('fisik')) return 'Fisik';
    if (t.contains('sosial')) return 'Sosial';
    if (t.contains('cyber')) return 'Cyberbullying';
    return 'Lainnya';
  }

  String _handledBy(ReportModel r) {
    final konselor = r.participants
        .where((p) =>
            p.role == 'konselor' ||
            p.role == 'guru_bk' ||
            p.role == 'handler')
        .firstOrNull;
    if (konselor?.name != null) return konselor!.name!;
    if (r.reporter?['name'] != null) return r.reporter!['name'].toString();
    return '—';
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 36, color: AppTheme.neutral400),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada laporan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba ubah filter periode atau kategori.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}
