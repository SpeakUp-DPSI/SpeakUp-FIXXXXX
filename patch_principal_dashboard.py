import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Remove Quick Actions
    # Look for '// ─── Quick Actions (Carousel style)' and remove it entirely up to the next SizedBox
    quick_actions_regex = r'// ─── Quick Actions \(Carousel style\) ──────────────.*?const SizedBox\(height: 16\),'
    content = re.sub(quick_actions_regex, '', content, flags=re.DOTALL)
    
    # Also remove _quickAction method
    quick_action_method = r'Widget _quickAction\(.*?\}\n'
    content = re.sub(quick_action_method, '', content, flags=re.DOTALL)
    
    # 2. Add Trend/Stats/Recap if not present?
    # Wait, the user said "kembalikan fitur grafik tren, statistik, dan rekapitulasi".
    # I had a PrincipalMonitoringScreen and TrendChartScreen before. 
    # Are they in principal_dashboard_screen? Let's check what's currently there.

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/dashboard/presentation/screens/principal_dashboard_screen.dart')
patch_file('speakup_mobile/lib/features/dashboard/presentation/screens/principal_dashboard_screen.dart')

