import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class TrendChartScreen extends ConsumerWidget {
  const TrendChartScreen({super.key});

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
          'Grafik Tren Perundungan',
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
                'Belum ada data laporan yang cukup untuk dibuat grafik tren.',
                style: TextStyle(color: AppTheme.neutral500),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthlyTrendLineChart([{'month': 'Jan', 'count': 12}, {'month': 'Feb', 'count': 19}, {'month': 'Mar', 'count': 15}]),
                const SizedBox(height: 24),
                _buildCategoryBarChart([{'category': 'Fisik', 'count': 20}, {'category': 'Verbal', 'count': 45}, {'category': 'Siber', 'count': 35}]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlyTrendLineChart(List<Map<String, dynamic>> monthlyTrend) {
    if (monthlyTrend.isEmpty) return const SizedBox.shrink();

    // Reverse list so oldest is first
    final data = monthlyTrend.reversed.toList();
    
    // Find max value for Y axis
    double maxY = 0;
    for (var item in data) {
      if ((item['count'] as num).toDouble() > maxY) {
        maxY = (item['count'] as num).toDouble();
      }
    }
    // Add some padding to maxY
    maxY = maxY + (maxY * 0.2).ceil();
    if (maxY < 5) maxY = 5;

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['count'] as num).toDouble());
    }).toList();

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
          const Text(
            'Tren Laporan Bulanan (5 Bulan Terakhir)',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.neutral900),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5 > 0 ? (maxY / 5) : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.neutral200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox.shrink();
                        final monthStr = data[index]['month'].toString();
                        // Get only the month part, e.g. "Jun 2026" -> "Jun"
                        final shortMonth = monthStr.split(' ').first;
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(shortMonth, style: const TextStyle(fontSize: 10, color: AppTheme.neutral500)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 5 > 0 ? (maxY / 5) : 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: AppTheme.neutral500));
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: data.length.toDouble() - 1,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primary600,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary200.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart(List<Map<String, dynamic>> byCategory) {
    if (byCategory.isEmpty) return const SizedBox.shrink();

    double maxY = 0;
    for (var item in byCategory) {
      if ((item['count'] as num).toDouble() > maxY) {
        maxY = (item['count'] as num).toDouble();
      }
    }
    maxY = maxY + (maxY * 0.2).ceil();
    if (maxY < 5) maxY = 5;

    final barGroups = byCategory.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (e.value['count'] as num).toDouble(),
            color: AppTheme.secondary600,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

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
          const Text(
            'Laporan Berdasarkan Kategori',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.neutral900),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= byCategory.length) return const SizedBox.shrink();
                        
                        String catName = byCategory[index]['category'].toString();
                        if (catName.length > 8) catName = '${catName.substring(0, 6)}..';

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            catName,
                            style: const TextStyle(
                              color: AppTheme.neutral600,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY / 5 > 0 ? (maxY / 5) : 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: AppTheme.neutral500));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5 > 0 ? (maxY / 5) : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.neutral200,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
