import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # The contact logic currently has:
    #                     if (isGuruBK) {
    #                        final userId = m.participantId;
    #                        if (userId != null) {
    #                          ScaffoldMessenger.of(context).showSnackBar( ... 'Menghubungi Ortu' ... );
    #                        }
    #                     } else ...

    new_contact_logic = """
                      onPressed: () async {
                        try {
                          await ref.read(mediationRemoteDataSourceProvider).contactParticipant(m.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil menghubungi pihak terkait'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghubungi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
"""
    # Find the onPressed block for Hubungi Pihak Terkait
    # It starts at `onPressed: () {` and ends right before `icon: const Icon(Icons.phone_rounded, size: 18),`
    
    # We use regex to replace everything inside onPressed for the Hubungi button
    pattern = r'onPressed: \(\) \{.*?icon: const Icon\(Icons\.phone_rounded, size: 18\),'
    replacement = new_contact_logic.strip('\n') + '\n                      icon: const Icon(Icons.phone_rounded, size: 18),'
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    # Need to import provider if not already there, actually it's a ConsumerWidget so ref is available.
    # We might need to import mediation_provider.dart if not imported.
    if 'mediation_provider.dart' not in content:
        content = content.replace("import '../../../../core/theme/app_theme.dart';", "import '../../../../core/theme/app_theme.dart';\nimport '../providers/mediation_provider.dart';")

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/mediation/presentation/screens/mediation_detail_page.dart')
patch_file('speakup_mobile/lib/features/mediation/presentation/screens/mediation_detail_page.dart')

