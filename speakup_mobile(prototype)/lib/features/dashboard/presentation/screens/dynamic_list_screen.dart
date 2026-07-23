import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../report/presentation/screens/report_list_screen.dart';

class DynamicListScreen extends ConsumerWidget {
  const DynamicListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthSuccess) {
      final role = authState.user.roles.isNotEmpty
          ? authState.user.roles.first.toLowerCase()
          : 'siswa';

      if (role.contains('siswa')) {
        return const HistoryScreen();
      }
    }

    return const ReportListScreen();
  }
}
