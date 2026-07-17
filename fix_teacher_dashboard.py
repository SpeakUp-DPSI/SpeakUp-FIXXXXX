import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # We want to remove the broken dangling block.
    # It looks like:
    #         },
    #       child: Column(
    #         ...
    #         ],
    #       ),
    #     );
    #   }
    
    # We can use regex to find `// ─── Quick Action ─────────────────────────────────────────────────────────` 
    # up to `  // ─── Mediation Item` and replace it with just `  // ─── Mediation Item`
    
    pattern = r'  // ─── Quick Action ─────────────────────────────────────────────────────────.*?// ─── Mediation Item'
    replacement = r'// ─── Mediation Item'
    
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Fixed {filepath}")

fix_file('speakup_web/lib/features/dashboard/presentation/screens/teacher_dashboard_screen.dart')
fix_file('speakup_mobile/lib/features/dashboard/presentation/screens/teacher_dashboard_screen.dart')

