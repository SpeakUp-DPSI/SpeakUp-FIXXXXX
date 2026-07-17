import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    new_buttons = """                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleValidation(context, ref, report.id, 'completed'),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Selesaikan Laporan', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
"""
    # Replace the existing `const SizedBox(height: 16),` under the `Catat Tindak Lanjut` button
    pattern = r'label: const Text\(\'Catat Tindak Lanjut\',\n                          style: TextStyle\(color: AppTheme\.success600\)\),\n                      style: OutlinedButton\.styleFrom\(\n                        side: const BorderSide\(color: AppTheme\.success600\),\n                        shape: RoundedRectangleBorder\(\n                            borderRadius: BorderRadius\.circular\(14\)\),\n                        padding: const EdgeInsets\.symmetric\(vertical: 14\),\n                      \),\n                    \),\n                  \),\n                  const SizedBox\(height: 16\),'
    replacement = r"label: const Text('Catat Tindak Lanjut',\n                          style: TextStyle(color: AppTheme.success600)),\n                      style: OutlinedButton.styleFrom(\n                        side: const BorderSide(color: AppTheme.success600),\n                        shape: RoundedRectangleBorder(\n                            borderRadius: BorderRadius.circular(14)),\n                        padding: const EdgeInsets.symmetric(vertical: 14),\n                      ),\n                    ),\n                  ),\n" + new_buttons
    
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/report/presentation/screens/report_detail_screen.dart')
patch_file('speakup_mobile/lib/features/report/presentation/screens/report_detail_screen.dart')

