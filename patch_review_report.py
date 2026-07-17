import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # The original has:
    #     final reportedName =
    #        widget.reportData['reportedId']?.toString() ?? '';
    #    if (reportedName.isNotEmpty) {
    #      data['participants'] = [
    #        {'role': 'terlapor', 'name': reportedName}
    #      ];
    #    }
    
    participants_logic = """
    final reportedId = widget.reportData['reportedId']?.toString() ?? '';
    if (reportedId.isNotEmpty) {
      final pName = widget.reportData['perpetratorName']?.toString() ?? '';
      final pClass = widget.reportData['perpetratorClass']?.toString() ?? '';
      final pNotes = widget.reportData['perpetratorCharacteristics']?.toString() ?? '';
      
      String nameToSend = pName;
      if (['Siswa satu kelas', 'Siswa kelas lain', 'Kakak kelas', 'Guru/Staff'].contains(reportedId)) {
         nameToSend = pName;
      } else {
         nameToSend = reportedId;
      }

      data['participants'] = [
        {
          'role': 'terlapor',
          'name': nameToSend,
          'class_name': pClass,
          'notes': pNotes.isNotEmpty ? 'Ciri-ciri: $pNotes' : reportedId,
        }
      ];
    }
"""

    content = re.sub(r'    final reportedName =.*?    \}', participants_logic.strip('\n'), content, flags=re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/report/presentation/screens/review_report_screen.dart')
patch_file('speakup_mobile/lib/features/report/presentation/screens/review_report_screen.dart')

