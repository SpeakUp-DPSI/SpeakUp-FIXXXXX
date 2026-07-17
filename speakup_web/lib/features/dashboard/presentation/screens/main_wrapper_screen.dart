import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

import 'main_sidebar.dart';
import 'widgets/web_header.dart';

/// Tab configuration for each role.
class _TabConfig {
  final int branchIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabConfig({
    required this.branchIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// Ensure the class name TabConfig matches what is used in main_sidebar.dart
typedef TabConfig = _TabConfig;

class MainWrapperScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends ConsumerState<MainWrapperScreen> {
  String _getUserRole() {
    final authState = ref.read(authProvider);
    if (authState is AuthSuccess) {
      return authState.user.roles.isNotEmpty
          ? authState.user.roles.first.toLowerCase()
          : 'siswa';
    }
    return 'siswa';
  }

  List<_TabConfig> _getTabsForRole(String role) {
    if (role.contains('guru')) {
      return const [
        _TabConfig(branchIndex: 0, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
        _TabConfig(branchIndex: 1, icon: Icons.article_outlined, activeIcon: Icons.article_rounded, label: 'Laporan'),
        _TabConfig(branchIndex: 2, icon: Icons.handshake_outlined, activeIcon: Icons.handshake_rounded, label: 'Mediasi'),
        _TabConfig(branchIndex: 3, icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Rekap'),
        _TabConfig(branchIndex: 4, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
      ];
    } else if (role.contains('kepala') || role.contains('kepsek')) {
      return const [
        _TabConfig(branchIndex: 0, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
        _TabConfig(branchIndex: 1, icon: Icons.monitor_outlined, activeIcon: Icons.monitor_rounded, label: 'Monitoring'),
        _TabConfig(branchIndex: 3, icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Notifikasi'),
        _TabConfig(branchIndex: 4, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
      ];
    } else if (role.contains('ortu') || role.contains('wali')) {
      return const [
        _TabConfig(branchIndex: 0, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
        _TabConfig(branchIndex: 1, icon: Icons.family_restroom_outlined, activeIcon: Icons.family_restroom_rounded, label: 'Anak'),
        _TabConfig(branchIndex: 2, icon: Icons.handshake_outlined, activeIcon: Icons.handshake_rounded, label: 'Mediasi'),
        _TabConfig(branchIndex: 3, icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Notifikasi'),
        _TabConfig(branchIndex: 4, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
      ];
    } else if (role.contains('admin')) {
      return const [
        _TabConfig(branchIndex: 0, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
        _TabConfig(branchIndex: 1, icon: Icons.article_outlined, activeIcon: Icons.article_rounded, label: 'Laporan'),
        _TabConfig(branchIndex: 4, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
      ];
    } else {
      // Student (default): Beranda, Riwayat, [FAB], Status, Profil
      return const [
        _TabConfig(branchIndex: 0, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
        _TabConfig(branchIndex: 1, icon: Icons.history_outlined, activeIcon: Icons.history_rounded, label: 'Riwayat'),
        _TabConfig(branchIndex: 3, icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt_rounded, label: 'Status'),
        _TabConfig(branchIndex: 4, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
      ];
    }
  }

  String _getRoleBadgeText(String role) {
    if (role.contains('admin')) return 'Admin';
    if (role.contains('kepsek') || role.contains('kepala')) return 'Kepala Sekolah';
    if (role.contains('guru') || role.contains('bk')) return 'Guru BK';
    if (role.contains('ortu') || role.contains('wali') || role.contains('orangtua')) return 'Orang Tua';
    return 'Siswa';
  }

  Color _getRoleBadgeColor(String role) {
    if (role.contains('admin')) return AppTheme.purple600;
    if (role.contains('kepsek') || role.contains('kepala')) return const Color(0xFF0D9488);
    if (role.contains('guru') || role.contains('bk')) return AppTheme.primary600;
    if (role.contains('ortu') || role.contains('wali') || role.contains('orangtua')) return AppTheme.warning600;
    return AppTheme.info600;
  }

  List<QuickLinkConfig> _getQuickLinksForRole(String role) {
    if (role.contains('admin')) {
      return [
        const QuickLinkConfig(Icons.manage_accounts_rounded, 'Kelola Pengguna', '/admin/users'),
        const QuickLinkConfig(Icons.receipt_long, 'Audit Log', '/audit-logs'),
      ];
    }
    if (role.contains('kepsek') || role.contains('kepala')) {
      return [
        const QuickLinkConfig(Icons.bar_chart_rounded, 'Rekap Laporan', '/principal/recap'),
        const QuickLinkConfig(Icons.monitor_heart_outlined, 'Monitoring', '/principal/monitoring'),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final role = _getUserRole();
    final tabs = _getTabsForRole(role);
    final isStudent = role.contains('siswa') || role.isEmpty;
    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    
    final authState = ref.watch(authProvider);
    String userName = 'User';
    String userEmail = '';
    if (authState is AuthSuccess) {
      userName = authState.user.name;
      userEmail = authState.user.email;
    }

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            MainSidebar(
              tabs: tabs,
              navigationShell: widget.navigationShell,
              isStudent: isStudent,
              userName: userName,
              userEmail: userEmail,
              roleBadgeText: _getRoleBadgeText(role),
              roleBadgeColor: _getRoleBadgeColor(role),
              quickLinks: _getQuickLinksForRole(role),
            ),
            Expanded(
              child: Scaffold(
                appBar: WebHeader(
                  title: tabs.firstWhere((t) => t.branchIndex == widget.navigationShell.currentIndex, orElse: () => tabs.first).label,
                ),
                body: widget.navigationShell,
                floatingActionButton: isStudent ? _buildCreateReportFab(context) : null,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: isStudent ? _buildCreateReportFab(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context, tabs, isStudent),
    );
  }

  Widget _buildCreateReportFab(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primary600,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary600.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/report/create'),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, List<_TabConfig> tabs, bool showFabNotch) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        notchMargin: showFabNotch ? 8 : 0,
        shape: showFabNotch ? const CircularNotchedRectangle() : null,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavItems(tabs, showFabNotch),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(List<_TabConfig> tabs, bool showFabNotch) {
    final widgets = <Widget>[];

    for (int i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final isActive = widget.navigationShell.currentIndex == tab.branchIndex;

      widgets.add(
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.navigationShell.goBranch(
                tab.branchIndex,
                initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  color: isActive ? AppTheme.primary600 : AppTheme.neutral400,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppTheme.primary600 : AppTheme.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Insert FAB notch spacer after the second item (for students)
      if (showFabNotch && i == 1) {
        widgets.add(const SizedBox(width: 60));
      }
    }

    return widgets;
  }
}
