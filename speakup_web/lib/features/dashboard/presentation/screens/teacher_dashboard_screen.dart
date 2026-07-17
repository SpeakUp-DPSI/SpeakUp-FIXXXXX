import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';
import 'web_profile_dropdown.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final reportsAsync = ref.watch(reportsListProvider);

    String userName = 'Bu Guru';
    if (authState is AuthSuccess) {
      userName = authState.user.name;
    }

    final now = DateTime.now();
    final dayNames = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateStr =
        '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]} ${now.year}';

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
                // ─── AppBar ──────────────────────────────────────────────
                _buildAppBar(context),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Greeting + Date ─────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutral900),
                                children: [
                                  const TextSpan(text: 'Selamat Pagi, '),
                                  TextSpan(
                                    text: userName,
                                    style: const TextStyle(
                                        color: AppTheme.primary600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateStr,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.neutral500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ─── Stat Cards ──────────────────────────────────
                      statsAsync.when(
                        loading: () => _buildStatGrid(0, 0, 0, 0, 0, 0),
                        error: (e, _) => _buildStatGrid(0, 0, 0, 0, 0, 0),
                        data: (stats) => _buildStatGrid(
                          stats.total,
                          stats.total, // menunggu approx
                          stats.total - stats.completed - stats.mediation,
                          stats.valid,
                          stats.mediation,
                          stats.completed,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Recent Reports ──────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            reportsAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              ),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (reports) {
                                final recent = reports.take(5).toList();
                                if (recent.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(
                                        child: Text('Belum ada laporan',
                                            style: TextStyle(
                                                color:
                                                    AppTheme.neutral400))),
                                  );
                                }
                                return Column(
                                  children: List.generate(recent.length,
                                      (i) {
                                    final r = recent[i];
                                    final badgeColor =
                                        _getBadgeColor(r.status);
                                    final badgeLabel =
                                        _formatStatusShort(r.status);
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () => context
                                              .push('/report/${r.id}'),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppTheme.primary50,
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                  ),
                                                  child: const Icon(
                                                      Icons.article_outlined,
                                                      color:
                                                          AppTheme.primary600,
                                                      size: 20),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        r.reportCode,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 13,
                                                            color: AppTheme
                                                                .primary600),
                                                      ),
                                                      Text(
                                                        r.category ??
                                                            r.title,
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppTheme
                                                                .neutral500),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (r.incidentDate != null)
                                                  Text(
                                                    r.incidentDate!,
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            AppTheme.neutral400),
                                                  ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: badgeColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    badgeLabel,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                    Icons.chevron_right,
                                                    size: 18,
                                                    color:
                                                        AppTheme.neutral400),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (i < recent.length - 1)
                                          const Divider(
                                              height: 1,
                                              indent: 16,
                                              endIndent: 16),
                                      ],
                                    );
                                  }),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),



                      // ─── Jadwal Mediasi ───────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 14, 16, 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary600,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.calendar_month_outlined,
                                        color: Colors.white,
                                        size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Jadwal Mediasi Mendatang',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppTheme.primary600),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            reportsAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (reports) {
                                final mediationReports = reports
                                    .where((r) =>
                                        r.status == 'mediation' &&
                                        r.incidentDate != null)
                                    .take(3)
                                    .toList();
                                if (mediationReports.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        'Belum ada jadwal mediasi',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.neutral400),
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    for (var i = 0;
                                        i < mediationReports.length;
                                        i++) ...[
                                      if (i > 0)
                                        const Divider(
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16),
                                      _mediationItemFromReport(
                                          mediationReports[i]),
                                    ],
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Notification Summary ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _notifRow(Icons.check_circle, AppTheme.success600,
                                null, 4),
                            const SizedBox(height: 12),
                            _notifRow(Icons.check_circle, AppTheme.primary600,
                                '3 laporan menunggu validasi\nPerlu pemeriksaan segera',
                                4),
                          ],
                        ),
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

  // ─── AppBar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 768) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primary600,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 6),
              const Text(
                'SpeakUp',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary600),
              ),
            ],
          ),
          Row(
            children: [
              if (MediaQuery.of(context).size.width >= 768)
                const WebProfileDropdown(),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.go('/notifications'),
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppTheme.neutral700),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.danger600, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          ],
        ),
      ],
      ),
    );
  }

  // ─── Stat Grid ────────────────────────────────────────────────────────────

  Widget _buildStatGrid(int total, int menunggu, int diproses, int valid,
      int mediasi, int selesai) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 768;
      return GridView.count(
        crossAxisCount: isWide ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWide ? 2.8 : 2.5,
      children: [
        _statCard(Icons.folder_copy_outlined, '$total', 'Semua Laporan',
            const Color(0xFF1A3A7A), bordered: true),
        _statCard(Icons.timer_outlined, '$menunggu', 'Sedang berjalan',
            AppTheme.warning600,
            bordered: true, label: 'Menunggu'),
        _statCard(Icons.sync, '$diproses', 'Dalam Penanganan',
            AppTheme.primary600,
            bordered: true, label: 'Diproses'),
        _statCard(Icons.verified_outlined, '$valid', 'Sedang berjalan',
            AppTheme.primary600,
            bordered: true, label: 'Valid'),
        _statCard(Icons.people_outline, '$mediasi', 'Sedang berjalan',
            const Color(0xFF1A3A7A),
            bordered: true, label: 'Mediasi'),
        _statCard(Icons.check_circle_outline, '$selesai', 'Sedang berjalan',
            AppTheme.success600,
            bordered: true, label: 'Selesai'),
      ],
      );
    });
  }

  Widget _statCard(IconData icon, String count, String sub, Color color,
      {bool bordered = false, String? label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: bordered ? Border.all(color: color.withValues(alpha: 0.35)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(count,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: color)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label ?? sub,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.neutral600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.neutral400),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mediation Item ───────────────────────────────────────────────────────

  Widget _mediationItemFromReport(report) {
    final monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateParts = (report.incidentDate ?? '').split('-');
    final day = dateParts.length >= 3 ? dateParts[2].substring(0, 2) : '--';
    final monthIdx = dateParts.length >= 2 ? int.tryParse(dateParts[1]) ?? 1 : 1;
    final month = monthNames[monthIdx].toUpperCase().substring(0, 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  // ─── Notif Row ────────────────────────────────────────────────────────────

  Widget _notifRow(
      IconData icon, Color color, String? text, int count) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: text != null
              ? Text(text,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.neutral700))
              : const SizedBox.shrink(),
        ),
        Text('$count',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.neutral700)),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Color _getBadgeColor(String status) {
    switch (status) {
      case 'waiting_validation':
        return AppTheme.warning600;
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

  String _formatStatusShort(String status) {
    switch (status) {
      case 'waiting_validation':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'mediation':
        return 'Mediasi';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Terkirim';
    }
  }
}
