import re

def patch_file(filepath):
    try:
        with open(filepath, 'r') as f:
            content = f.read()

        # Fix typing of mockByCategory
        mock = """    final mockByCategory = [
      {'category': 'Verbal', 'count': 45},
      {'category': 'Fisik', 'count': 20},
      {'category': 'Siber', 'count': 35},
    ];"""
        fixed_mock = """    final mockByCategory = <Map<String, dynamic>>[
      {'category': 'Verbal', 'count': 45},
      {'category': 'Fisik', 'count': 20},
      {'category': 'Siber', 'count': 35},
    ];"""
        content = content.replace(mock, fixed_mock)

        # Fix type casting in loops
        content = content.replace("int count = cat['count'];", "int count = cat['count'] as int;")
        content = content.replace("highestCategory = cat['category'];", "highestCategory = cat['category'] as String;")
        content = content.replace("if (cat['count'] > highestCount)", "if ((cat['count'] as int) > highestCount)")
        content = content.replace("highestCount = cat['count'];", "highestCount = cat['count'] as int;")
        
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Patched {filepath}")
    except FileNotFoundError:
        pass

patch_file('speakup_web/lib/features/dashboard/presentation/screens/policy_report_screen.dart')
patch_file('speakup_mobile/lib/features/dashboard/presentation/screens/policy_report_screen.dart')
