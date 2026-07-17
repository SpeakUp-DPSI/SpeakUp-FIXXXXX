import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manajemen Sistem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard('Laporan', Icons.description, AppTheme.primary600, () {
                  context.go('/reports');
                }),
                _buildMenuCard('Audit Logs', Icons.receipt_long, AppTheme.info600, () {
                  context.push('/audit-logs');
                }),
                _buildMenuCard('Pengguna', Icons.manage_accounts, AppTheme.success600, () {
                  context.push('/users');
                }),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Status Sistem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.success600.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done, color: AppTheme.success600, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Semua sistem operasional', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success600)),
                      Text('Terhubung dengan API (v1.0.0)', style: TextStyle(fontSize: 12, color: AppTheme.neutral700)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neutral300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
