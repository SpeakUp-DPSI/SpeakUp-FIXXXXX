import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class WebProfileDropdown extends ConsumerWidget {
  const WebProfileDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    String userName = 'U';
    if (authState is AuthSuccess) {
      userName = authState.user.name.isNotEmpty ? authState.user.name[0].toUpperCase() : 'U';
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: 'Profil',
      onSelected: (value) {
        if (value == 'settings') {
          context.push('/profile'); // Assuming profile screen has account settings
        } else if (value == 'logout') {
          ref.read(authProvider.notifier).logout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.manage_accounts_outlined, color: AppTheme.neutral700, size: 20),
              const SizedBox(width: 12),
              const Text('Pengaturan Akun', style: TextStyle(color: AppTheme.neutral900)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppTheme.danger600, size: 20),
              const SizedBox(width: 12),
              const Text('Logout', style: TextStyle(color: AppTheme.danger600, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primary100,
          foregroundColor: AppTheme.primary600,
          child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
