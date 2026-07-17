import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Item navigasi generik dipakai bareng sama sidebar (web) dan
/// bottom nav (mobile) — supaya isi menu tidak perlu ditulis dua kali.
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class MainWrapperScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends ConsumerState<MainWrapperScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    String primaryRole = 'siswa';
    String userName = 'User';
    String userEmail = '';
    if (authState is AuthSuccess) {
      primaryRole = authState.user.roles.isNotEmpty
          ? authState.user.roles.first.toLowerCase()
          : 'siswa';
      userName = authState.user.name;
      userEmail = authState.user.email;
    }

    final bool isStudent = primaryRole == 'siswa';

    final items = [
      const _NavItem(Icons.home_outlined, Icons.home, 'Beranda'),
      const _NavItem(Icons.history_outlined, Icons.history, 'Riwayat'),
      isStudent
          ? const _NavItem(Icons.add_circle_outline, Icons.add_circle, 'Lapor')
          : const _NavItem(Icons.dashboard_customize_outlined, Icons.dashboard_customize, 'Kelola'),
      const _NavItem(Icons.notifications_outlined, Icons.notifications, 'Notifikasi'),
      const _NavItem(Icons.person_outline, Icons.person, 'Profil'),
    ];

    void onTap(int index) {
      if (index == 2 && isStudent) {
        context.push('/report/create');
        return; // Jangan goBranch untuk index tengah pada siswa, langsung push rute baru
      }
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }

    // §8.3 Design_System.md — DESKTOP ke atas pakai sidebar, di bawah itu bottom nav
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    if (isDesktop) {
      return _DesktopLayout(
        navigationShell: widget.navigationShell,
        items: items,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: onTap,
        role: primaryRole,
        userName: userName,
        userEmail: userEmail,
        onLogout: () {
          ref.read(authProvider.notifier).logout();
        },
      );
    }

    return _MobileLayout(
      navigationShell: widget.navigationShell,
      items: items,
      currentIndex: widget.navigationShell.currentIndex,
      onTap: onTap,
      isStudent: isStudent,
    );
  }
}

/// Layout mobile — persis perilaku lama (bottom nav + FAB khusus siswa),
/// tidak ada perubahan fungsional dari sebelumnya.
class _MobileLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isStudent;

  const _MobileLayout({
    required this.navigationShell,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.isStudent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: isStudent
          ? FloatingActionButton(
              onPressed: () => context.push('/report/create'),
              backgroundColor: AppTheme.primary600,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary600,
          unselectedItemColor: AppTheme.neutral500,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            for (int i = 0; i < items.length; i++)
              BottomNavigationBarItem(
                icon: Icon(
                  i == 2 && isStudent ? Icons.add : items[i].icon,
                  color: i == 2 && isStudent ? Colors.transparent : null,
                ),
                activeIcon: Icon(items[i].activeIcon),
                label: items[i].label,
              ),
          ],
        ),
      ),
    );
  }
}

/// Layout desktop/web — sidebar tetap di kiri dengan branding, navigasi utama,
/// quick links per role, dan user info di bawah.
class _DesktopLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String role;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const _DesktopLayout({
    required this.navigationShell,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.role,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  String get _roleBadgeLabel {
    if (role.contains('admin')) return 'Admin';
    if (role.contains('kepsek') || role.contains('kepala')) return 'Kepala Sekolah';
    if (role.contains('guru') || role.contains('bk')) return 'Guru BK';
    if (role.contains('ortu') || role.contains('wali') || role.contains('orangtua')) return 'Orang Tua';
    return 'Siswa';
  }

  Color get _roleBadgeColor {
    if (role.contains('admin')) return AppTheme.purple600;
    if (role.contains('kepsek') || role.contains('kepala')) return const Color(0xFF0D9488);
    if (role.contains('guru') || role.contains('bk')) return AppTheme.primary600;
    if (role.contains('ortu') || role.contains('wali') || role.contains('orangtua')) return AppTheme.warning600;
    return AppTheme.info600;
  }

  bool get _canCreateReport {
    return role.contains('siswa') || role.contains('ortu') || role.contains('guru') || role.contains('bk') || role.contains('orangtua') || role.contains('wali');
  }

  List<_QuickLink> get _roleQuickLinks {
    if (role.contains('admin')) {
      return [
        _QuickLink(Icons.manage_accounts_rounded, 'Kelola Pengguna', '/admin/users'),
        _QuickLink(Icons.receipt_long, 'Audit Log', '/audit-logs'),
      ];
    }
    if (role.contains('kepsek') || role.contains('kepala')) {
      return [
        _QuickLink(Icons.bar_chart_rounded, 'Rekap Laporan', '/principal/recap'),
        _QuickLink(Icons.monitor_heart_outlined, 'Monitoring', '/principal/monitoring'),
      ];
    }
    if (role.contains('guru') || role.contains('bk')) {
      return [
        _QuickLink(Icons.people_outline, 'Mediasi', '/mediations'),
        _QuickLink(Icons.assignment_outlined, 'Kelola Laporan', '/reports'),
      ];
    }
    if (role.contains('ortu') || role.contains('wali') || role.contains('orangtua')) {
      return [
        _QuickLink(Icons.assignment_outlined, 'Laporan Anak', '/reports'),
      ];
    }
    // Siswa tidak memiliki quick link di sidebar lagi
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: AppTheme.neutral100, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // ── Branding ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primary600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Speak',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                            TextSpan(
                              text: 'Up',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // ── Role badge ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _roleBadgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _roleBadgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _roleBadgeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Divider ──
                const Divider(height: 1, color: AppTheme.neutral100),
                const SizedBox(height: 12),
                // ── Navigasi Utama Label ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'MENU UTAMA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutral400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // ── Nav Items ──
                for (int i = 0; i < items.length; i++)
                  if (items[i].label != 'Profil')
                    _SidebarItem(
                      icon: items[i].icon,
                      activeIcon: items[i].activeIcon,
                      label: items[i].label,
                      selected: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                const SizedBox(height: 16),
                // ── Role Quick Links ──
                if (_roleQuickLinks.isNotEmpty) ...[
                  const Divider(height: 1, color: AppTheme.neutral100),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'AKSES CEPAT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutral400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final link in _roleQuickLinks)
                    _SidebarQuickLink(
                      icon: link.icon,
                      label: link.label,
                      onTap: () {
                        // Shell branch routes use go(), others use push()
                        if (link.route == '/mediations' || link.route == '/reports') {
                          context.go(link.route);
                        } else {
                          context.push(link.route);
                        }
                      },
                    ),
                ],
                ],
            ),
          ),
          // ── Content Area with Top Navbar ─────────────────────────
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA),
              child: Column(
                children: [
                  // ── Top Navbar ──
                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: AppTheme.neutral100, width: 1)),
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        if (_canCreateReport) ...[
                          ElevatedButton.icon(
                            onPressed: () => context.push('/report/create'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Buat Laporan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(width: 32),
                        ],
                        // User Profile
                        PopupMenuButton<int>(
                          offset: const Offset(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          elevation: 8,
                          onSelected: (value) {
                            if (value == 0) {
                              final profileIndex = items.indexWhere((e) => e.label == 'Profil');
                              if (profileIndex != -1) onTap(profileIndex);
                            } else if (value == 1) {
                              context.push('/profile/settings');
                            } else if (value == 2) {
                              onLogout();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 0,
                              child: Row(
                                children: [
                                  Icon(Icons.person_outline, size: 20, color: AppTheme.neutral700),
                                  SizedBox(width: 12),
                                  Text('Lihat Profil', style: TextStyle(color: AppTheme.neutral900)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.settings_outlined, size: 20, color: AppTheme.neutral700),
                                  SizedBox(width: 12),
                                  Text('Pengaturan', style: TextStyle(color: AppTheme.neutral900)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(Icons.logout, size: 20, color: AppTheme.danger600),
                                  SizedBox(width: 12),
                                  Text('Keluar', style: TextStyle(color: AppTheme.danger600, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
                                    ),
                                    Text(
                                      _roleBadgeLabel,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.neutral500),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: _roleBadgeColor.withValues(alpha: 0.15),
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: _roleBadgeColor, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Main Content ──
                  Expanded(
                    child: navigationShell,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLink {
  final IconData icon;
  final String label;
  final String route;
  const _QuickLink(this.icon, this.label, this.route);
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary600.withValues(alpha: 0.08)
                : _hovered
                    ? AppTheme.neutral100
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: AppTheme.primary600.withValues(alpha: 0.2), width: 1)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      isActive ? widget.activeIcon : widget.icon,
                      size: 20,
                      color: isActive ? AppTheme.primary600 : AppTheme.neutral500,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? AppTheme.primary600 : AppTheme.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarQuickLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarQuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SidebarQuickLink> createState() => _SidebarQuickLinkState();
}

class _SidebarQuickLinkState extends State<_SidebarQuickLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.neutral100 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 18, color: AppTheme.neutral500),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.neutral600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 16, color: AppTheme.neutral400),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}