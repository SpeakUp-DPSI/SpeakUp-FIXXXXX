import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.security, size: 120, color: AppTheme.primary600),
              const SizedBox(height: 48),
              const Text(
                'Lapor Tanpa Takut',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi pelaporan perundungan yang aman, rahasia, dan langsung terhubung dengan pihak sekolah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.neutral500,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Mulai Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
