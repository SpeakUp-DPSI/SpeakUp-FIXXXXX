import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../data/models/dashboard_stats_model.dart';

class PolicyReportScreen extends ConsumerWidget {
  const PolicyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

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
          'Laporan Kebijakan & Evaluasi',
          style: TextStyle(
              color: AppTheme.neutral900,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Gagal memuat data: $e')),
        data: (stats) {
          if (stats.total == 0) {
            return const Center(
              child: Text(
                'Belum ada data laporan yang cukup untuk dievaluasi.',
                style: TextStyle(color: AppTheme.neutral500),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExecutiveSummary(stats),
                const SizedBox(height: 24),
                _buildTrendAnalysis(stats),
                const SizedBox(height: 24),
                _buildRecommendations(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExecutiveSummary(DashboardStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: AppTheme.primary600),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Eksekutif',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sejauh ini, terdapat ${stats.total} kasus perundungan yang dilaporkan. '
            'Dari total tersebut, ${stats.completed} kasus telah berhasil diselesaikan '
            'sedangkan ${stats.processing + stats.mediation} kasus sedang dalam proses penanganan oleh tim Guru BK.',
            style: const TextStyle(color: AppTheme.neutral700, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(DashboardStatsModel stats) {
    String highestCategory = 'N/A';
    int highestCount = 0;
    
        final mockByCategory = <Map<String, dynamic>>[
      {'category': 'Verbal', 'count': 45},
      {'category': 'Fisik', 'count': 20},
      {'category': 'Siber', 'count': 35},
    ];

    for (var cat in mockByCategory) {
      int count = cat['count'] as int;
      if (count > highestCount) {
        highestCount = count;
        highestCategory = cat['category'] as String;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppTheme.secondary600),
              const SizedBox(width: 8),
              const Text(
                'Analisis Tren Perundungan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Berdasarkan data yang dihimpun, kategori perundungan yang paling sering terjadi adalah "$highestCategory" '
            'dengan total $highestCount kejadian. Pola ini mengindikasikan perlunya pendekatan khusus '
            'pada area tersebut dibandingkan bentuk perundungan lainnya.',
            style: const TextStyle(color: AppTheme.neutral700, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(DashboardStatsModel stats) {
    List<String> recommendations = [];

    // Rule 1: High unresolved cases
    if (stats.processing + stats.mediation > (stats.total * 0.3)) {
      recommendations.add('Beban kerja Guru BK saat ini cukup tinggi karena banyaknya kasus yang sedang diproses. Disarankan untuk melibatkan Wali Kelas dalam mediasi tahap awal.');
    } else {
      recommendations.add('Tingkat penyelesaian kasus berada pada angka yang baik. Pertahankan alur koordinasi saat ini.');
    }

    // Rule 2: Based on top category
    String highestCategory = '';
    int highestCount = 0;
        final mockByCategory = <Map<String, dynamic>>[
      {'category': 'Verbal', 'count': 45},
      {'category': 'Fisik', 'count': 20},
      {'category': 'Siber', 'count': 35},
    ];

    for (var cat in mockByCategory) {
      if ((cat['count'] as int) > highestCount) {
        highestCount = cat['count'] as int;
        highestCategory = cat['category'].toString().toLowerCase();
      }
    }

    if (highestCategory.contains('verbal')) {
      recommendations.add('Tingginya kasus perundungan verbal memerlukan pengadaan seminar Komunikasi Positif dan kampanye stop "Jokes" yang merendahkan.');
    } else if (highestCategory.contains('fisik')) {
      recommendations.add('Kasus fisik membutuhkan pengawasan ekstra pada jam rawan (istirahat/pulang) dan titik-titik buta (blind spots) CCTV sekolah.');
    } else if (highestCategory.contains('cyber')) {
      recommendations.add('Sangat penting untuk memasukkan materi Literasi Digital dan Bahaya Jejak Digital pada kurikulum atau jam wali kelas.');
    } else {
      recommendations.add('Lakukan sosialisasi berkala tentang pedoman perilaku dan sanksi perundungan kepada seluruh siswa.');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppTheme.primary600),
              const SizedBox(width: 8),
              const Text(
                'Rekomendasi Tindak Lanjut',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6, color: AppTheme.primary600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r, style: const TextStyle(color: AppTheme.neutral700, height: 1.5)),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
