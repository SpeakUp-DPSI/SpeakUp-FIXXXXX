import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'student_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'principal_dashboard_screen.dart';
import 'parent_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class DynamicDashboardScreen extends ConsumerWidget {
  const DynamicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthSuccess) {
      final role = authState.user.roles.isNotEmpty ? authState.user.roles.first.toLowerCase() : 'siswa';
      
      if (role.contains('guru')) {
        return const TeacherDashboardScreen();
      } else if (role.contains('kepala') || role.contains('kepsek')) {
        return const PrincipalDashboardScreen();
      } else if (role.contains('ortu') || role.contains('wali')) {
        return const ParentDashboardScreen();
      } else if (role.contains('admin')) {
        return const AdminDashboardScreen();
      } else {
        return const StudentDashboardScreen();
      }
    }

    return const Center(child: CircularProgressIndicator());
  }
}
