import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class ReportSuccessScreen extends StatelessWidget {
  final String reportCode;

  const ReportSuccessScreen({super.key, required this.reportCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: AppTheme.success100, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, size: 80, color: AppTheme.success600),
              ),
              const SizedBox(height: 32),
              const Text('Laporan Berhasil Terkirim!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.neutral900), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text(
                'Terima kasih telah berani speak up. Laporan Anda telah masuk dan sedang menunggu validasi oleh Guru BK.',
                style: TextStyle(color: AppTheme.neutral700, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary100, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Text('Kode Laporan Anda:', style: TextStyle(color: AppTheme.neutral700)),
                    const SizedBox(height: 8),
                    Text(reportCode, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.primary600)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: reportCode));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode disalin ke clipboard!')));
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Salin Kode'),
                    )
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/dashboard'); // GoRouter will inject back the MainWrapperScreen
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
