import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/widgets/auth_stepper.dart';

// ─── Controller utama multi-step create report ────────────────────────────────

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() =>
      _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  int _step = 1;

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

  // Step 2 data
  final List<File> _photos = [];
  final List<File> _videos = [];
  final List<File> _documents = [];
  final TextEditingController _chronologyCtrl = TextEditingController();

  @override
  void dispose() {
    _chronologyCtrl.dispose();
    super.dispose();
  }

  void _goNext() => setState(() => _step++);
  void _goBack() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _step == 1
              ? _Step1Identitas(
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
                )
              : _Step2Bukti(
                  key: const ValueKey(2),
                  photos: _photos,
                  videos: _videos,
                  documents: _documents,
                  chronologyCtrl: _chronologyCtrl,
                  onPhotosChanged: (v) => setState(() {
                    _photos.clear();
                    _photos.addAll(v);
                  }),
                  onVideosChanged: (v) => setState(() {
                    _videos.clear();
                    _videos.addAll(v);
                  }),
                  onDocumentsChanged: (v) => setState(() {
                    _documents.clear();
                    _documents.addAll(v);
                  }),
                  onNext: () {
                    final filePaths = [
                      ..._photos.map((f) => f.path),
                      ..._videos.map((f) => f.path),
                      ..._documents.map((f) => f.path),
                    ];

                    String dateStr = '';
                    if (_selectedDate != null) {
                      dateStr =
                          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
                    }
                    String timeStr = '';
                    if (_selectedTime != null) {
                      timeStr =
                          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')} WIB';
                    }

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

                    context.push('/report/review', extra: reportData);
                  },
                  onBack: _goBack,
                ),
        ),
      ),
    );
  }
}

// ─── Step 1: Identitas ───────────────────────────────────────────────────────

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

  static const _categories = [
    'Perundungan Verbal',
    'Perundungan Fisik',
    'Perundungan Sosial',
    'Cyberbullying',
    'Pemerasan',
    'Lainnya',
  ];

  static const _platforms = [
    'WhatsApp',
    'Instagram',
    'Facebook',
    'TikTok',
    'Twitter',
    'Lainnya',
  ];

  static const _locations = [
    'Kantin Sekolah',
    'Kelas',
    'Toilet',
    'Area Parkir',
    'Lapangan',
    'Koridor',
    'Lainnya',
  ];

  static const _parties = [
    'Siswa satu kelas',
    'Siswa kelas lain',
    'Kakak kelas',
    'Guru/Staff',
    'Tidak diketahui',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthStepper(
                  currentStep: 1,
                  labels: ['Identitas', 'Bukti', 'Review'],
                ),
                const SizedBox(height: 24),

                // Toggle Identitas / Anonim
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onToggleAnonymous(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: !isAnonymous
                                ? AppTheme.primary600
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !isAnonymous
                                  ? AppTheme.primary600
                                  : AppTheme.neutral300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline,
                                  color: !isAnonymous
                                      ? Colors.white
                                      : AppTheme.neutral500,
                                  size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lapor dengan\nIdentitas',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: !isAnonymous
                                        ? Colors.white
                                        : AppTheme.neutral700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onToggleAnonymous(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: isAnonymous
                                ? AppTheme.primary600
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAnonymous
                                  ? AppTheme.primary600
                                  : AppTheme.neutral300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.remove_red_eye_outlined,
                                  color: isAnonymous
                                      ? Colors.white
                                      : AppTheme.neutral500,
                                  size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lapor secara\nAnonim',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isAnonymous
                                        ? Colors.white
                                        : AppTheme.neutral700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Jenis Perundungan
                _requiredLabel('Jenis Perundungan'),
                const SizedBox(height: 8),
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
                const SizedBox(height: 16),

                // Tanggal + Waktu
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _requiredLabel('Tanggal Kejadian'),
                          const SizedBox(height: 8),
                          _buildDateField(context),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _requiredLabel('Waktu'),
                          const SizedBox(height: 8),
                          _buildTimeField(context),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lokasi Kejadian
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
                const SizedBox(height: 16),

                // Pihak yang Terlibat
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
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(hint,
                style: const TextStyle(
                    color: AppTheme.neutral400, fontSize: 14)),
          ),
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.neutral500),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          items: items
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(c,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.neutral900)),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final text = selectedDate == null
        ? null
        : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        onDateChanged(picked);
      },
      child: _fieldBox(
        text ?? 'Pilih tanggal',
        Icons.calendar_today_outlined,
        isEmpty: text == null,
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    final text = selectedTime == null
        ? null
        : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        onTimeChanged(picked);
      },
      child: _fieldBox(
        text ?? 'Pilih waktu',
        Icons.access_time_outlined,
        isEmpty: text == null,
      ),
    );
  }

  Widget _fieldBox(String text, IconData icon, {bool isEmpty = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color:
                    isEmpty ? AppTheme.neutral400 : AppTheme.neutral900,
              ),
            ),
          ),
          Icon(icon, color: AppTheme.neutral400, size: 18),
        ],
      ),
    );
  }

  Widget _requiredLabel(String text) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral900)),
        const Text(' *',
            style: TextStyle(color: AppTheme.danger600, fontSize: 14)),
      ],
    );
  }
}

// ─── Step 2: Bukti ───────────────────────────────────────────────────────────

class _Step2Bukti extends StatefulWidget {
  final List<File> photos, videos, documents;
  final TextEditingController chronologyCtrl;
  final ValueChanged<List<File>> onPhotosChanged, onVideosChanged,
      onDocumentsChanged;
  final VoidCallback onNext, onBack;

  const _Step2Bukti({
    super.key,
    required this.photos,
    required this.videos,
    required this.documents,
    required this.chronologyCtrl,
    required this.onPhotosChanged,
    required this.onVideosChanged,
    required this.onDocumentsChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<_Step2Bukti> createState() => _Step2BuktiState();
}

class _Step2BuktiState extends State<_Step2Bukti> {
  int _chronoLength = 0;

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 80);
      if (picked.isNotEmpty) {
        final updated = [...widget.photos, ...picked.map((x) => File(x.path))];
        widget.onPhotosChanged(updated);
      }
    } catch (_) {}
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        widget.onVideosChanged([...widget.videos, File(picked.path)]);
      }
    } catch (_) {}
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: true,
      );
      if (result != null) {
        final newDocs = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        widget.onDocumentsChanged([...widget.documents, ...newDocs]);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthStepper(
                  currentStep: 2,
                  labels: ['Identitas', 'Bukti', 'Review'],
                ),
                const SizedBox(height: 16),

                const Text(
                  'Unggah bukti yang dapat membantu memperkuat laporan Anda',
                  style: TextStyle(fontSize: 13, color: AppTheme.neutral500),
                ),
                const SizedBox(height: 20),

                // Foto
                _uploadCard(
                  icon: Icons.image_outlined,
                  iconColor: AppTheme.primary600,
                  title: 'Foto',
                  subtitle: 'JPG, PNG (maksimal 20 MB)',
                  buttonLabel: '+ Pilih Foto',
                  count: widget.photos.length,
                  onTap: _pickPhoto,
                ),
                const SizedBox(height: 12),

                // Video
                _uploadCard(
                  icon: Icons.videocam_outlined,
                  iconColor: AppTheme.primary600,
                  title: 'Video',
                  subtitle: 'MP4, MOV (maksimal 100 MB)',
                  buttonLabel: '+ Pilih Video',
                  count: widget.videos.length,
                  onTap: _pickVideo,
                ),
                const SizedBox(height: 12),

                // Dokumen
                _uploadCard(
                  icon: Icons.description_outlined,
                  iconColor: AppTheme.primary600,
                  title: 'File',
                  subtitle: '(maksimal. 20 mb)',
                  buttonLabel: '+ Pilih Dokumen',
                  count: widget.documents.length,
                  onTap: _pickDocument,
                ),
                const SizedBox(height: 20),

                // Kronologi Kejadian
                const Text(
                  'Kronologi Kejadian',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral900),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: widget.chronologyCtrl,
                  maxLines: 5,
                  maxLength: 1000,
                  onChanged: (v) =>
                      setState(() => _chronoLength = v.length),
                  decoration: InputDecoration(
                    hintText: 'Ceritakan apa yang terjadi secara lengkap',
                    counterText: '$_chronoLength/1000',
                    counterStyle: const TextStyle(
                        fontSize: 12, color: AppTheme.neutral400),
                  ),
                ),
                const SizedBox(height: 24),

                // Kembali + Lanjutkan
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onBack,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppTheme.primary600, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                              color: AppTheme.primary600,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Lanjutkan',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _uploadCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required int count,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.neutral900)),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const Spacer(),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.neutral400)),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    side: const BorderSide(
                        color: AppTheme.primary600, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(buttonLabel,
                      style: const TextStyle(
                          color: AppTheme.primary600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared AppBar ───────────────────────────────────────────────────────────

Widget _buildAppBar(BuildContext context) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: SafeArea(
      bottom: false,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppTheme.neutral700),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          // Logo
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primary600,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.shield_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 6),
          const Text(
            'SpeakUp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppTheme.neutral700),
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}
