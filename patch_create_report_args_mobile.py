import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the _Step1Identitas constructor call
    pattern = r'\? _Step1Identitas\([\s\S]*?onBack: _goBack,\n                \)'
    
    new_call = """? _Step1Identitas(
                  key: const ValueKey(1),
                  isAnonymous: _isAnonymous,
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
                  onNext: _goNext,
                  onBack: _goBack,
                )"""
    
    content = re.sub(pattern, new_call, content)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_mobile/lib/features/report/presentation/screens/create_report_screen.dart')
