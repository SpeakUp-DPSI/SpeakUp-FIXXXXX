import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    new_quick_actions = """
                      // ─── Menu Laporan & Statistik ──────────────────────
                      const Text(
                        'Statistik & Analitik',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutral900),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _menuCard(
                              context,
                              Icons.auto_graph,
                              'Grafik Tren',
                              '/principal/trend',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _menuCard(
                              context,
                              Icons.analytics_outlined,
                              'Monitoring',
                              '/principal/monitoring',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _menuCard(
                              context,
                              Icons.summarize_outlined,
                              'Rekap',
                              '/reports',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
"""
    # Find the place to insert (before `const SizedBox(height: 24);` at the end of the children list of the dashboard main column)
    # The current code has:
    #                      const SizedBox(height: 16),
    #                      const SizedBox(height: 24),
    #                    ],
    pattern = r'                      const SizedBox\(height: 16\),\s*const SizedBox\(height: 24\),\s*\]'
    replacement = "                      const SizedBox(height: 16),\n" + new_quick_actions + "                    ]"
    content = re.sub(pattern, replacement, content)

    # Add the _menuCard helper method
    menu_card_method = """
  Widget _menuCard(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary600, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""
    content = re.sub(r'\}\s*$', menu_card_method, content)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/dashboard/presentation/screens/principal_dashboard_screen.dart')
patch_file('speakup_mobile/lib/features/dashboard/presentation/screens/principal_dashboard_screen.dart')

