import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';
import '../../../report/data/models/report_model.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

/// Kasus yang tidak ada pembaruan status lebih dari N hari ini
/// dianggap "Perlu Perhatian" dan mendapatkan badge tambahan.
const int kNeedAttentionThresholdDays = 5;

/// Urutan tahap penanganan — digunakan untuk menghitung progress mediasi.
const List<String> kStatusOrder = [
  'waiting_validation',
  'processing',
  'mediation',
  'follow_up',
  'completed',
];

// ─── Filter enum ──────────────────────────────────────────────────────────────

enum _MonitorFilter {
  all('Semua Penanggung Jawab'),
  oldest('Terlama Diproses'),
  nearDeadline('Mendekati Tenggat');

  const _MonitorFilter(this.label);
  final String label;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PrincipalMonitoringScreen extends ConsumerStatefulWidget {
  const PrincipalMonitoringScreen({super.key});

  @override
  ConsumerState<PrincipalMonitoringScreen> createState() =>
      _PrincipalMonitoringScreenState();
}

class _PrincipalMonitoringScreenState
    extends ConsumerState<PrincipalMonitoringScreen> {
  _MonitorFilter _filter = _MonitorFilter.all;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsListProvider);

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
          'Monitoring',
          style: TextStyle(
              color: AppTheme.neutral900,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
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
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _Header(),
                ),
              ),

              // ── Filter chips ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildFilterChips(),
                ),
              ),

              // ── Count label ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: reportsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (all) {
                    final active = _applyFilter(_sortedActive(all));
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '${active.length} kasus aktif',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutral500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Cases list ───────────────────────────────────────────────
              reportsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: _ErrorState(message: '$e'),
                ),
                data: (all) {
                  final active = _applyFilter(_sortedActive(all));
                  if (active.isEmpty) {
                    return const SliverFillRemaining(
                      child: _EmptyState(),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final isLast = i == active.length - 1;
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                              16, 0, 16, isLast ? 32 : 0),
                          child: _MonitorCard(report: active[i]),
                        );
                      },
                      childCount: active.length,
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

  // ── Filter chips ─────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _MonitorFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _MonitorFilter.values[i];
          final selected = _filter == f;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
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
                f.label,
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

  // ── Data helpers ─────────────────────────────────────────────────────────

  /// Ambil hanya kasus yang masih aktif (bukan completed/rejected).
  List<ReportModel> _sortedActive(List<ReportModel> all) {
    final active = all
        .where((r) =>
            r.status != 'completed' &&
            r.status != 'rejected' &&
            r.status != 'submitted')
        .toList();

    // Default: urutkan berdasarkan lama berjalan (terlama dulu)
    active.sort((a, b) =>
        _daysRunning(b).compareTo(_daysRunning(a)));
    return active;
  }

  List<ReportModel> _applyFilter(List<ReportModel> active) {
    switch (_filter) {
      case _MonitorFilter.all:
        return active;
      case _MonitorFilter.oldest:
        // Sudah diurutkan terlama, kembalikan apa adanya
        return active;
      case _MonitorFilter.nearDeadline:
        // Kasus yang sudah mendekati batas perhatian (>= 3 hari, belum melewati threshold)
        return active
            .where((r) =>
                _daysRunning(r) >= 3 &&
                _daysRunning(r) < kNeedAttentionThresholdDays)
            .toList();
    }
  }

  /// Menghitung berapa hari sejak laporan masuk / terakhir diperbarui.
  int _daysRunning(ReportModel r) {
    // Coba ambil tanggal dari riwayat status pertama
    if (r.statusHistories != null && r.statusHistories!.isNotEmpty) {
      final first = r.statusHistories!.first;
      final dateStr = first['created_at']?.toString() ??
          first['date']?.toString();
      if (dateStr != null) {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) {
          return DateTime.now().difference(parsed).inDays;
        }
      }
    }
    // Fallback: pakai tanggal kejadian
    if (r.incidentDate != null) {
      final parsed = DateTime.tryParse(r.incidentDate!);
      if (parsed != null) {
        return DateTime.now().difference(parsed).inDays;
      }
    }
    return 0;
  }
}

// ─── Header widget ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monitoring Penanganan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutral900,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.info_outline,
                size: 13, color: AppTheme.neutral400),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Kasus yang sedang berjalan, diurutkan berdasarkan lama penanganan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.neutral500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Monitor Card ─────────────────────────────────────────────────────────────

class _MonitorCard extends StatelessWidget {
  final ReportModel report;

  const _MonitorCard({required this.report});

  // ── Computed properties ─────────────────────────────────────────────────

  int get _daysRunning {
    if (report.statusHistories != null &&
        report.statusHistories!.isNotEmpty) {
      final first = report.statusHistories!.first;
      final dateStr = first['created_at']?.toString() ??
          first['date']?.toString();
      if (dateStr != null) {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) {
          return DateTime.now().difference(parsed).inDays;
        }
      }
    }
    if (report.incidentDate != null) {
      final parsed = DateTime.tryParse(report.incidentDate!);
      if (parsed != null) {
        return DateTime.now().difference(parsed).inDays;
      }
    }
    return 0;
  }

  bool get _needsAttention => _daysRunning >= kNeedAttentionThresholdDays;

  bool get _isMediation => report.status == 'mediation';

  int get _currentStep {
    final idx = kStatusOrder.indexOf(report.status);
    return idx < 0 ? 1 : idx + 1; // 1-based
  }

  int get _totalSteps => kStatusOrder.length;

  String get _handledBy {
    final konselor = report.participants
        .where((p) =>
            p.role == 'konselor' ||
            p.role == 'guru_bk' ||
            p.role == 'handler')
        .firstOrNull;
    if (konselor?.name != null) return konselor!.name!;
    if (report.reporter?['name'] != null) {
      return report.reporter!['name'].toString();
    }
    return 'Belum ditugaskan';
  }

  String get _categoryLabel {
    if (report.category != null && report.category!.isNotEmpty) {
      return report.category!;
    }
    final t = report.title.toLowerCase();
    if (t.contains('verbal')) return 'Perundungan Verbal';
    if (t.contains('fisik')) return 'Perundungan Fisik';
    if (t.contains('sosial')) return 'Perundungan Sosial';
    if (t.contains('cyber')) return 'Cyberbullying';
    return 'Perundungan';
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = StatusColors.of(report.status);
    final badgeLabel = StatusColors.labelOf(report.status);

    return GestureDetector(
      onTap: () => context.push('/report/${report.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: _needsAttention
              ? Border.all(
                  color: AppTheme.danger600.withValues(alpha: 0.35),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status stripe ───────────────────────────────────────────
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: kode + badge ───────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ikon kategori
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primary50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _categoryIcon(),
                          color: AppTheme.primary600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kode · Kategori
                            Text(
                              '${report.reportCode} · $_categoryLabel',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.neutral900,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            // Ditangani oleh · hari berjalan
                            Text(
                              'Ditangani $_handledBy · $_daysRunning hari berjalan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.neutral500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Badge kolom kanan — status + optional "Perlu Perhatian"
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StatusBadge(
                              label: badgeLabel, color: badgeColor),
                          if (_needsAttention) ...[
                            const SizedBox(height: 4),
                            const _AttentionBadge(),
                          ],
                        ],
                      ),
                    ],
                  ),

                  // ── Progress bar (mediasi only) ─────────────────────
                  if (_isMediation) ...[
                    const SizedBox(height: 12),
                    _MediationProgress(
                      current: _currentStep,
                      total: _totalSteps,
                    ),
                  ],

                  // ── Tanggal kejadian ────────────────────────────────
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppTheme.neutral400),
                      const SizedBox(width: 5),
                      Text(
                        'Kejadian: ${report.incidentDate ?? '-'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.neutral400,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppTheme.neutral300),
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

  IconData _categoryIcon() {
    final label = (report.category ?? report.title).toLowerCase();
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
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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
}

class _AttentionBadge extends StatelessWidget {
  const _AttentionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.danger100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.danger600.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 11,
              color: AppTheme.danger600.withValues(alpha: 0.85)),
          const SizedBox(width: 3),
          Text(
            'Perlu Perhatian',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.danger600.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediationProgress extends StatelessWidget {
  final int current;
  final int total;
  const _MediationProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.linear_scale_rounded,
                size: 13, color: AppTheme.purple600),
            const SizedBox(width: 5),
            Text(
              'Tahap $current/$total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.purple600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppTheme.purple100,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.purple600),
          ),
        ),
      ],
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────

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
                color: AppTheme.success100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 36, color: AppTheme.success600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Semua kasus tertangani',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tidak ada kasus aktif saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off,
                size: 48, color: AppTheme.neutral300),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.neutral500),
            ),
          ],
        ),
      ),
    );
  }
}
