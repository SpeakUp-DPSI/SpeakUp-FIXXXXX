import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';
import 'web_profile_dropdown.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  int _bannerIndex = 0;

  final List<Map<String, String>> _banners = [
    {
      'title': 'Berani Melapor!',
      'subtitle':
          'Identitas kamu dijamin kerahasiaannya jika menggunakan fitur anonim.',
    },
    {
      'title': 'Kamu Tidak Sendiri',
      'subtitle':
          'Tim konselor siap mendampingi kamu melalui setiap laporan yang dikirim.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final reportsAsync = ref.watch(reportsListProvider);

    String userName = 'Siswa';
    if (authState is AuthSuccess) {
      final fullName = authState.user.name;
      userName = fullName.split(' ').first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(reportsListProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── AppBar ──────────────────────────────────────────────
                _buildAppBar(context),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ─── Greeting ───────────────────────────────────
                      _buildGreeting(userName),
                      const SizedBox(height: 20),

                      // ─── Banner Carousel ─────────────────────────────
                      _buildBanner(context),
                      const SizedBox(height: 24),

                      // ─── Ringkasan Laporan ───────────────────────────
                      const Text(
                        'Ringkasan Laporan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutral900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      reportsAsync.when(
                        loading: () => _buildStatCards(0, 0, 0, 0),
                        error: (e, _) => _buildStatCards(0, 0, 0, 0),
                        data: (reports) {
                          final total = reports.length;
                          final processed = reports
                              .where((r) => r.status == 'processing')
                              .length;
                          final completed = reports
                              .where((r) => r.status == 'completed')
                              .length;
                          final rejected = reports
                              .where((r) => r.status == 'rejected')
                              .length;
                          return _buildStatCards(
                              total, processed, completed, rejected);
                        },
                      ),
                      const SizedBox(height: 24),

                      // ─── Aktivitas Terkini ───────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Aktivitas Terkini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neutral900,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/reports'),
                            child: const Row(
                              children: [
                                Text(
                                  'Lihat semua',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primary600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    size: 18, color: AppTheme.primary600),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      reportsAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) => _buildEmptyActivity(context),
                        data: (reports) {
                          if (reports.isEmpty) {
                            return _buildEmptyActivity(context);
                          }
                          return Column(
                            children: reports
                                .take(5)
                                .map((r) => _buildActivityItem(
                                      context,
                                      r.reportCode,
                                      r.title,
                                      r.status,
                                      r.id,
                                    ))
                                .toList(),
                          );
                        },
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

  // ─── AppBar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 768) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary600,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 6),
              const Text(
                'SpeakUp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary600,
                ),
              ),
            ],
          ),
          // Actions
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
                        color: AppTheme.neutral700, size: 26),
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
          ],
        ),
      ],
      ),
    );
  }

  // ─── Greeting ───────────────────────────────────────────────────────────

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Halo, ',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral900,
            ),
            children: [
              TextSpan(
                text: name,
                style: const TextStyle(
                  color: Color(0xFFE8A020),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Terima kasih sudah peduli dan berani\nmenciptakan lingkungan sekolah yang aman.',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.neutral500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ─── Banner ─────────────────────────────────────────────────────────────

  Widget _buildBanner(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              setState(() =>
                  _bannerIndex = (_bannerIndex + 1) % _banners.length);
            } else if (details.primaryVelocity! > 0) {
              setState(() =>
                  _bannerIndex = (_bannerIndex - 1 + _banners.length) %
                      _banners.length);
            }
          },
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.primary600,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gambar ilustrasi — fallback gradient jika belum ada
                Image.asset(
                  'assets/images/beranda_illustration.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2E63C6),
                          Color(0xFF1A3A7A),
                        ],
                      ),
                    ),
                  ),
                ),
                // Overlay gelap
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
                // Teks konten
                Positioned(
                  left: 20,
                  bottom: 20,
                  right: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _banners[_bannerIndex]['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _banners[_bannerIndex]['subtitle']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dot indicator
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _bannerIndex == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _bannerIndex == i
                    ? AppTheme.primary600
                    : AppTheme.neutral300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── Stat Cards ─────────────────────────────────────────────────────────

  Widget _buildStatCards(
      int total, int processed, int completed, int rejected) {
    return Row(
      children: [
        _statCard(total.toString(), 'Laporan', const Color(0xFF1A3A7A)),
        const SizedBox(width: 10),
        _statCard(processed.toString(), 'Diproses', AppTheme.primary600),
        const SizedBox(width: 10),
        _statCard(completed.toString(), 'Selesai', const Color(0xFF0D9488)),
        const SizedBox(width: 10),
        _statCard(rejected.toString(), 'Ditolak', AppTheme.neutral400),
      ],
    );
  }

  Widget _statCard(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Activity Item ───────────────────────────────────────────────────────

  Widget _buildActivityItem(
    BuildContext context,
    String code,
    String title,
    String status,
    String id,
  ) {
    final icon = _getCategoryIcon(title);
    final statusLabel = _formatStatus(status);
    final badgeColor = _getBadgeColor(status);

    return GestureDetector(
      onTap: () => context.push('/report/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.neutral100),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primary50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary600, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.neutral500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: AppTheme.neutral300),
          const SizedBox(height: 12),
          const Text(
            'Belum ada laporan',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.neutral500),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => context.push('/report/create'),
            child: const Text('Buat Laporan Pertama'),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  IconData _getCategoryIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('verbal')) return Icons.chat_bubble_outline;
    if (t.contains('fisik')) return Icons.back_hand_outlined;
    if (t.contains('sosial') || t.contains('pengucilan')) {
      return Icons.people_outline;
    }
    if (t.contains('cyber')) return Icons.computer_outlined;
    return Icons.description_outlined;
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
        return AppTheme.warning600;
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
