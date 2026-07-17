import os
import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Add state variables to _CreateReportScreenState
    state_vars = """
  // Step 1 data
  bool _isAnonymous = false;
  String _selectedCategory = '';
  String _customCategory = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedLocation = '';
  String _customPlatform = '';
  String _selectedParty = '';
  String _perpetratorName = '';
  String _perpetratorClass = '';
  String _perpetratorCharacteristics = '';
"""
    content = re.sub(r'  // Step 1 data\n  bool _isAnonymous = false;.*?  String _selectedParty = \'\';', state_vars.strip('\n'), content, flags=re.DOTALL)

    # 2. Add parameters to _Step1Identitas constructor call in build
    call_params = """
              selectedCategory: _selectedCategory,
              customCategory: _customCategory,
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              selectedLocation: _selectedLocation,
              customPlatform: _customPlatform,
              selectedParty: _selectedParty,
              perpetratorName: _perpetratorName,
              perpetratorClass: _perpetratorClass,
              perpetratorCharacteristics: _perpetratorCharacteristics,
              onToggleAnonymous: (v) =>
                  setState(() => _isAnonymous = v),
              onCategoryChanged: (v) =>
                  setState(() => _selectedCategory = v),
              onCustomCategoryChanged: (v) =>
                  setState(() => _customCategory = v),
              onDateChanged: (v) => setState(() => _selectedDate = v),
              onTimeChanged: (v) => setState(() => _selectedTime = v),
              onLocationChanged: (v) =>
                  setState(() => _selectedLocation = v),
              onCustomPlatformChanged: (v) =>
                  setState(() => _customPlatform = v),
              onPartyChanged: (v) =>
                  setState(() => _selectedParty = v),
              onPerpetratorNameChanged: (v) =>
                  setState(() => _perpetratorName = v),
              onPerpetratorClassChanged: (v) =>
                  setState(() => _perpetratorClass = v),
              onPerpetratorCharacteristicsChanged: (v) =>
                  setState(() => _perpetratorCharacteristics = v),
"""
    content = re.sub(r'              selectedCategory: _selectedCategory,.*?              onPartyChanged: \(v\) =>\n                  setState\(\(\) => _selectedParty = v\),', call_params.strip('\n'), content, flags=re.DOTALL)

    # 3. Add to reportData map
    report_data = """
                final reportData = {
                  'isAnonymous': _isAnonymous,
                  'category': _selectedCategory == 'Lainnya' ? _customCategory : _selectedCategory,
                  'incidentDate': dateStr,
                  'incidentTime': timeStr,
                  'incidentLocation': _selectedCategory == 'Cyberbullying' ? (_selectedLocation == 'Lainnya' ? _customPlatform : _selectedLocation) : _selectedLocation,
                  'reportedId': _selectedParty,
                  'perpetratorName': _perpetratorName,
                  'perpetratorClass': _perpetratorClass,
                  'perpetratorCharacteristics': _perpetratorCharacteristics,
                  'description': _chronologyCtrl.text,
                  'filePaths': filePaths,
                  'hasFile': filePaths.isNotEmpty,
                  'title': _selectedCategory.isNotEmpty
                      ? (_selectedCategory == 'Lainnya' ? _customCategory : _selectedCategory)
                      : 'Laporan Perundungan',
                };
"""
    content = re.sub(r'                final reportData = \{.*?                \};', report_data.strip('\n'), content, flags=re.DOTALL)

    # 4. Update _Step1Identitas class properties and constructor
    step1_props = """
class _Step1Identitas extends StatelessWidget {
  final bool isAnonymous;
  final String selectedCategory, customCategory, selectedLocation, customPlatform, selectedParty;
  final String perpetratorName, perpetratorClass, perpetratorCharacteristics;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<bool> onToggleAnonymous;
  final ValueChanged<String> onCategoryChanged, onCustomCategoryChanged, onLocationChanged, onCustomPlatformChanged, onPartyChanged;
  final ValueChanged<String> onPerpetratorNameChanged, onPerpetratorClassChanged, onPerpetratorCharacteristicsChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final VoidCallback onNext, onBack;

  const _Step1Identitas({
    super.key,
    required this.isAnonymous,
    required this.selectedCategory,
    required this.customCategory,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedLocation,
    required this.customPlatform,
    required this.selectedParty,
    required this.perpetratorName,
    required this.perpetratorClass,
    required this.perpetratorCharacteristics,
    required this.onToggleAnonymous,
    required this.onCategoryChanged,
    required this.onCustomCategoryChanged,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onLocationChanged,
    required this.onCustomPlatformChanged,
    required this.onPartyChanged,
    required this.onPerpetratorNameChanged,
    required this.onPerpetratorClassChanged,
    required this.onPerpetratorCharacteristicsChanged,
    required this.onNext,
    required this.onBack,
  });
"""
    content = re.sub(r'class _Step1Identitas extends StatelessWidget \{.*?  \}\);', step1_props.strip('\n'), content, flags=re.DOTALL)

    # 5. Platforms for Cyberbullying
    platforms = """
  static const _platforms = [
    'WhatsApp',
    'Instagram',
    'Facebook',
    'TikTok',
    'Twitter',
    'Lainnya',
  ];

  static const _locations = [
"""
    content = content.replace("  static const _locations = [", platforms.strip('\n'))

    # 6. Build Method Logic for _Step1Identitas
    # We need to inject text fields conditionally
    
    # Custom Category
    cat_replacement = """
                _buildDropdown(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  hint: 'Pilih jenis perundungan',
                  items: _categories,
                  onChanged: (v) => onCategoryChanged(v ?? ''),
                ),
                if (selectedCategory == 'Lainnya') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Masukkan jenis perundungan',
                    value: customCategory,
                    onChanged: onCustomCategoryChanged,
                  ),
                ],
"""
    content = re.sub(r'                _buildDropdown\(\n                  value: selectedCategory\.isEmpty \? null : selectedCategory,\n                  hint: \'Pilih jenis perundungan\',\n                  items: _categories,\n                  onChanged: \(v\) => onCategoryChanged\(v \?\? \'\'\),\n                \),', cat_replacement.strip('\n'), content)

    # Location / Platform
    loc_replacement = """
                _requiredLabel(selectedCategory == 'Cyberbullying' ? 'Jenis Platform' : 'Lokasi Kejadian'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedLocation.isEmpty ? null : selectedLocation,
                  hint: selectedCategory == 'Cyberbullying' ? 'Pilih platform' : 'Pilih lokasi',
                  items: selectedCategory == 'Cyberbullying' ? _platforms : _locations,
                  onChanged: (v) => onLocationChanged(v ?? ''),
                ),
                if (selectedCategory == 'Cyberbullying' && selectedLocation == 'Lainnya') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Masukkan nama platform',
                    value: customPlatform,
                    onChanged: onCustomPlatformChanged,
                  ),
                ],
"""
    content = re.sub(r'                _requiredLabel\(\'Lokasi Kejadian\'\);\n                const SizedBox\(height: 8\);\n                _buildDropdown\(\n                  value: selectedLocation\.isEmpty \? null : selectedLocation,\n                  hint: \'Pilih lokasi\',\n                  items: _locations,\n                  onChanged: \(v\) => onLocationChanged\(v \?\? \'\'\),\n                \),', loc_replacement.strip('\n'), content)
    # the regex might fail if spaces don't match exactly, let's use a more robust replace for Location
    
    # Better approach for Location Replacement:
    content = content.replace("_requiredLabel('Lokasi Kejadian'),\n                const SizedBox(height: 8),\n                _buildDropdown(\n                  value: selectedLocation.isEmpty ? null : selectedLocation,\n                  hint: 'Pilih lokasi',\n                  items: _locations,\n                  onChanged: (v) => onLocationChanged(v ?? ''),\n                ),", loc_replacement.strip('\n'))

    # Pihak Terlibat Replacement
    party_replacement = """
                _requiredLabel('Pihak yang Terlibat'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedParty.isEmpty ? null : selectedParty,
                  hint: 'Pilih pihak yang terlibat',
                  items: _parties,
                  onChanged: (v) => onPartyChanged(v ?? ''),
                ),
                if (['Siswa satu kelas', 'Siswa kelas lain', 'Kakak kelas'].contains(selectedParty)) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Nama Pelaku',
                    value: perpetratorName,
                    onChanged: onPerpetratorNameChanged,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Kelas Pelaku',
                    value: perpetratorClass,
                    onChanged: onPerpetratorClassChanged,
                  ),
                ] else if (selectedParty == 'Guru/Staff') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Nama Pelaku (Guru/Staff)',
                    value: perpetratorName,
                    onChanged: onPerpetratorNameChanged,
                  ),
                ] else if (selectedParty == 'Tidak diketahui') ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Ciri-ciri Pelaku',
                    value: perpetratorCharacteristics,
                    onChanged: onPerpetratorCharacteristicsChanged,
                  ),
                ],
"""
    content = content.replace("_requiredLabel('Pihak yang Terlibat'),\n                const SizedBox(height: 8),\n                _buildDropdown(\n                  value: selectedParty.isEmpty ? null : selectedParty,\n                  hint: 'Pilih pihak yang terlibat',\n                  items: _parties,\n                  onChanged: (v) => onPartyChanged(v ?? ''),\n                ),", party_replacement.strip('\n'))

    # Helper method _buildTextField
    textfield_helper = """
  Widget _buildTextField({
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppTheme.neutral900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.neutral400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary600, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
"""
    content = content.replace("  Widget _buildDropdown({", textfield_helper.strip('\n'))

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/report/presentation/screens/create_report_screen.dart')
patch_file('speakup_mobile/lib/features/report/presentation/screens/create_report_screen.dart')

