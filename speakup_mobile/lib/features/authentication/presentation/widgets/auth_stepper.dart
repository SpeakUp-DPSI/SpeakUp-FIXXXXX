import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthStepper extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  final List<String> labels;

  const AuthStepper({
    super.key,
    required this.currentStep,
    this.labels = const ['Data Diri', 'Verifikasi', 'Selesai'],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = (i ~/ 2) + 1;
          final isDone = currentStep > stepIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone ? AppTheme.primary600 : AppTheme.neutral300,
            ),
          );
        }

        final stepIndex = i ~/ 2 + 1;
        final isActive = currentStep == stepIndex;
        final isDone = currentStep > stepIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isActive || isDone) ? AppTheme.primary600 : Colors.white,
                border: Border.all(
                  color: (isActive || isDone)
                      ? AppTheme.primary600
                      : AppTheme.neutral300,
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '$stepIndex',
                        style: TextStyle(
                          color: isActive ? Colors.white : AppTheme.neutral400,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[stepIndex - 1],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: (isActive || isDone)
                    ? AppTheme.primary600
                    : AppTheme.neutral400,
              ),
            ),
          ],
        );
      }),
    );
  }
}
