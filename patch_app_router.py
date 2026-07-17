import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Import trend_chart_screen
    import_trend = "import '../../features/dashboard/presentation/screens/trend_chart_screen.dart';"
    if import_trend not in content:
        content = content.replace(
            "import '../../features/dashboard/presentation/screens/principal_monitoring_screen.dart';",
            "import '../../features/dashboard/presentation/screens/principal_monitoring_screen.dart';\n" + import_trend
        )
    
    # Add route
    route_trend = """
      GoRoute(
        path: '/principal/trend',
        builder: (context, state) => const TrendChartScreen(),
      ),
"""
    if "'/principal/trend'" not in content:
        content = content.replace(
            "path: '/principal/monitoring',",
            "path: '/principal/monitoring',\n        builder: (context, state) => const PrincipalMonitoringScreen(),\n      ),\n" + route_trend + "      // DUMMY TO REPLACE"
        )
        content = content.replace("      // DUMMY TO REPLACE", "")

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/core/router/app_router.dart')
patch_file('speakup_mobile/lib/core/router/app_router.dart')

