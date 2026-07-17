import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'main_wrapper_screen.dart' show TabConfig;

class MainSidebar extends StatelessWidget {
  final List<TabConfig> tabs;
  final StatefulNavigationShell navigationShell;
  final bool isStudent;
  final String userName;
  final String userEmail;
  final String roleBadgeText;
  final Color roleBadgeColor;
  final List<QuickLinkConfig> quickLinks;

  const MainSidebar({
    super.key,
    required this.tabs,
    required this.navigationShell,
    required this.isStudent,
    required this.userName,
    required this.userEmail,
    required this.roleBadgeText,
    required this.roleBadgeColor,
    required this.quickLinks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.neutral100, width: 1)),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SpeakUp',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.neutral900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // ── Main Menu ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'MENU UTAMA',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.neutral400, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (int i = 0; i < tabs.length; i++)
                  if (tabs[i].label != 'Profil') // Hide Profil tab from sidebar
                    _SidebarItem(
                      icon: tabs[i].icon,
                      activeIcon: tabs[i].activeIcon,
                      label: tabs[i].label,
                      selected: navigationShell.currentIndex == tabs[i].branchIndex,
                      onTap: () {
                        if (i == 2 && isStudent && tabs[i].label == 'Lapor') {
                          context.push('/report/create');
                          return;
                        }
                        navigationShell.goBranch(
                          tabs[i].branchIndex,
                          initialLocation: tabs[i].branchIndex == navigationShell.currentIndex,
                        );
                      },
                    ),
                if (!isStudent && quickLinks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'PINTASAN CEPAT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.neutral400, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final ql in quickLinks)
                    _SidebarQuickLink(
                      icon: ql.icon,
                      label: ql.label,
                      onTap: () => context.push(ql.route),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickLinkConfig {
  final IconData icon;
  final String label;
  final String route;
  const QuickLinkConfig(this.icon, this.label, this.route);
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isActive ? widget.activeIcon : widget.icon,
                      color: isActive ? AppTheme.primary600 : AppTheme.neutral500,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? AppTheme.primary600 : AppTheme.neutral600,
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
                    Icon(widget.icon, color: AppTheme.neutral400, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(fontSize: 13, color: AppTheme.neutral600),
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
