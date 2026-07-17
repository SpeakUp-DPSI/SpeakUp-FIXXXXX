import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    back_button = """
          Row(
            children: [
              if (context.canPop()) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.neutral900),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral900,
                ),
              ),
            ],
          ),
"""
    # Replace the Text widget containing the title
    pattern = r'          Text\(\n            title,\n            style: const TextStyle\(\n              fontSize: 20,\n              fontWeight: FontWeight\.bold,\n              color: AppTheme\.neutral900,\n            \),\n          \),'
    content = re.sub(pattern, back_button.strip('\n'), content)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/dashboard/presentation/screens/widgets/web_header.dart')

