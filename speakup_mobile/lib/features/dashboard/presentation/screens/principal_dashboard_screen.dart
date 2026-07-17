import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';

class PrincipalDashboardScreen extends ConsumerStatefulWidget {
  const PrincipalDashboardScreen({super.key});

  @override
  ConsumerState<PrincipalDashboardScreen> createState() =>
      _PrincipalDashboardScreenState();
}

class _PrincipalDashboardScreenState
    extends ConsumerState<PrincipalDashboardScreen> {
  String _dateRangeLabel = '1 Juni - 1 Juli 2026';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final reportsAsync = ref.watch(reportsListProvider);

    String userName = 'Pak Kepala';
    if (authState is AuthSuccess) {
      userName = authState.user.name;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(reportsListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Hero Header (full-bleed illustration) ──────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildHeroHeader(userName),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Date Filter ──────────────────────────────────
                      _buildDateFilter(),
                      const SizedBox(height: 16),

                      // ─── Stat Cards ───────────────────────────────────
                      statsAsync.when(
                        loading: () => _buildStatCards(0, 0, 0, 0, 0),
                        error: (e, _) => _buildStatCards(0, 0, 0, 0, 0),
                        data: (stats) => _buildStatCards(
                          stats.total,
                          stats.today,
                          stats.total - stats.completed - stats.mediation,
                          stats.completed,
                          0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Tingkat Penyelesaian ─────────────────────────
                      statsAsync.when(
                        loading: () => _buildCompletionCard(0, 0),
                        error: (e, _) => _buildCompletionCard(0, 0),
                        data: (stats) =>
                            _buildCompletionCard(stats.completed, stats.total),
                      ),
                      const SizedBox(height: 16),

                      // ─── Kasus Butuh Perhatian ────────────────────────
                      const Text(
                        'Kasus yang membutuhkan perhatian',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFD4371C)),
                      ),
                      const SizedBox(height: 10),
                      reportsAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (reports) {
                          final urgent = reports
                              .where((r) =>
                                  r.status == 'waiting_validation' ||
                                  r.status == 'processing')
                              .take(3)
                              .toList();
                          if (urgent.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tidak ada kasus mendesak saat ini.',
                                  style: TextStyle(
                                      color: AppTheme.neutral400,
                                      fontSize: 13),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: urgent
                                .map((r) => _buildUrgentCard(r, context))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // ─── Menu Laporan & Statistik ──────────────────────
                      const Text(
                        'Statistik & Analitik',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutral900),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _menuCard(
                              context,
                              Icons.auto_graph,
                              'Grafik Tren',
                              '/principal/trend',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _menuCard(
                              context,
                              Icons.analytics_outlined,
                              'Monitoring',
                              '/principal/monitoring',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _menuCard(
                              context,
                              Icons.summarize_outlined,
                              'Rekap',
                              '/reports',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Hero Header ──────────────────────────────────────────────────────────
  // Ilustrasi memenuhi seluruh kartu, teks di depan dengan gradient overlay

  Widget _buildHeroHeader(String userName) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Ilustrasi penuh seluruh kartu
          Image.asset(
            'assets/images/kepsek_illustration.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            errorBuilder: (ctx, e, s) => Container(
              color: const Color(0xFFE8EEF8),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.school_outlined,
                  color: Colors.black12, size: 80),
            ),
          ),

          // Layer 2: Teks di depan
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            right: 140, // Memberi ruang agar teks tidak menabrak karakter di kanan
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selamat Pagi,',
                  style: TextStyle(
                    color: Color(0xFF0D2149),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Color(0xFF0D2149),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Berikut ringkasan penanganan\nkasus perundungan di sekolah Anda.',
                  style: TextStyle(
                    color: Color(0xFF1A3A7A),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Date Filter ─────────────────────────────────────────────────────────

  Widget _buildDateFilter() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: DateTime(2027),
        );
        if (picked != null) {
          final months = [
            'Jan','Feb','Mar','Apr','Mei','Jun',
            'Jul','Agt','Sep','Okt','Nov','Des'
          ];
          setState(() {
            _dateRangeLabel =
                '${picked.start.day} ${months[picked.start.month - 1]} - '
                '${picked.end.day} ${months[picked.end.month - 1]} ${picked.end.year}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neutral300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppTheme.neutral500),
            const SizedBox(width: 8),
            Text(
              _dateRangeLabel,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.neutral900),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppTheme.neutral500),
          ],
        ),
      ),
    );
  }

  // ─── Stat Cards ──────────────────────────────────────────────────────────

  Widget _buildStatCards(
      int total, int baru, int diproses, int selesai, int ditolak) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.folder_copy_outlined,
                count: '$total',
                label: 'Total Kasus',
                bgColor: const Color(0xFF0D2149),
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                icon: Icons.access_time_outlined,
                count: '$baru',
                label: 'Kasus Baru',
                bgColor: const Color(0xFF1A5EB8),
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                icon: Icons.sync,
                count: '$diproses',
                label: 'Diproses',
                bgColor: const Color(0xFFE87C1E),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.verified_outlined,
                count: '$selesai',
                label: 'Selesai',
                bgColor: const Color(0xFF0E9E82),
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                icon: Icons.cancel_outlined,
                count: '$ditolak',
                label: 'Ditolak',
                bgColor: const Color(0xFF8B2424),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String count,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: textColor.withValues(alpha: 0.85), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                Text(
                  label,
                  style: TextStyle(
                      color: textColor.withValues(alpha: 0.75),
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Completion Rate Card ────────────────────────────────────────────────

  Widget _buildCompletionCard(int selesai, int total) {
    final pct = total > 0 ? ((selesai / total) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tingkat Penyelesaian',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.neutral600,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  '$pct%',
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3A7A)),
                ),
                const SizedBox(height: 4),
                Text(
                  '$selesai dari $total Kasus Selesai',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.neutral500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _PieChartPainter(
                percentage: pct / 100,
                primaryColor: const Color(0xFF1A3A7A),
                secondaryColor: const Color(0xFFBFD3F2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Urgent Cases Card ───────────────────────────────────────────────────

  Widget _buildUrgentCard(dynamic report, BuildContext context) {
    final isBaru = report.status == 'waiting_validation';
    return GestureDetector(
      onTap: () => context.push('/report/${report.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFD4371C), size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        report.reportCode,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.neutral500),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: isBaru
                              ? const Color(0xFFE87C1E)
                              : AppTheme.primary600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isBaru ? 'Baru' : 'Proses',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    report.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.neutral900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppTheme.neutral400),
                      const SizedBox(width: 4),
                      Text(
                        report.incidentDate ?? '-',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.neutral400),
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

  Widget _menuCard(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary600, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Pie Chart Painter ────────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final double percentage;
  final Color primaryColor;
  final Color secondaryColor;

  _PieChartPainter({
    required this.percentage,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(center, radius,
        Paint()
          ..color = secondaryColor
          ..style = PaintingStyle.fill);

    final sweepAngle = 2 * 3.14159265 * percentage;
    canvas.drawArc(
        rect,
        -3.14159265 / 2,
        sweepAngle,
        true,
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill);

    canvas.drawCircle(
        center,
        radius * 0.55,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
