import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Add import
    import_users = "import '../../features/admin/presentation/screens/user_management_screen.dart';"
    if import_users not in content:
        content = content.replace(
            "import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';",
            "import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';\n" + import_users
        )
    
    # Add route for /users
    route_users = """
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
"""
    if "'/users'" not in content:
        # insert after admin route
        content = content.replace(
            "builder: (context, state) => const AdminDashboardScreen(),\n      ),",
            "builder: (context, state) => const AdminDashboardScreen(),\n      ),\n" + route_users
        )

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/core/router/app_router.dart')
patch_file('speakup_mobile/lib/core/router/app_router.dart')

