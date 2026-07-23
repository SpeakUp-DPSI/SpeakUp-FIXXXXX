import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthSuccess ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              color: AppTheme.primary600,
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primary100,
                        child: Icon(Icons.person, size: 50, color: AppTheme.primary600),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 20, color: AppTheme.primary600),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Pengguna',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 14, color: AppTheme.primary100),
                  ),
                  if (user?.roles.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatRole(user!.roles.first),
                      style: TextStyle(fontSize: 12, color: AppTheme.primary100),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuGroup('Pengaturan Akun', [
              _buildMenuItem(Icons.person_outline, 'Edit Profil', onTap: () => context.push('/profile/edit')),
              _buildMenuItem(Icons.lock_outline, 'Ganti Kata Sandi'),
              _buildMenuItem(Icons.notifications_none, 'Pengaturan Notifikasi', onTap: () => context.push('/profile/settings')),
            ]),
            const SizedBox(height: 16),
            _buildMenuGroup('Lainnya', [
              _buildMenuItem(Icons.help_outline, 'Pusat Bantuan'),
              _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi'),
              _buildMenuItem(
                Icons.logout,
                'Keluar',
                textColor: AppTheme.danger600,
                iconColor: AppTheme.danger600,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        title: const Text('Keluar dari Aplikasi?'),
                        content: const Text('Anda harus masuk kembali untuk mengakses fitur SpeakUp.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Batal', style: TextStyle(color: AppTheme.neutral500)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger600),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              ref.read(authProvider.notifier).logout();
                              context.go('/login');
                            },
                            child: const Text('Keluar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'siswa': return 'Siswa';
      case 'guru_bk': return 'Guru Bimbingan & Konseling';
      case 'kepala_sekolah': return 'Kepala Sekolah';
      case 'orang_tua': return 'Orang Tua / Wali';
      case 'admin': return 'Administrator';
      default: return role;
    }
  }

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.neutral700)),
        ),
        Container(color: Colors.white, child: Column(children: items)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Color? textColor, Color? iconColor, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (iconColor ?? AppTheme.neutral500).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor ?? AppTheme.neutral700, size: 24),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor ?? AppTheme.neutral900)),
      trailing: Icon(Icons.chevron_right, color: AppTheme.neutral400),
      onTap: onTap ?? () {},
    );
  }
}
