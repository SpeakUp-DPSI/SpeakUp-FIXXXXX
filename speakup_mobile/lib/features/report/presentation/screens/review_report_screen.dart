import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/report_provider.dart';
import '../../../authentication/presentation/widgets/auth_stepper.dart';

class ReviewReportScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> reportData;

  const ReviewReportScreen({super.key, required this.reportData});

  @override
  ConsumerState<ReviewReportScreen> createState() =>
      _ReviewReportScreenState();
}

class _ReviewReportScreenState extends ConsumerState<ReviewReportScreen> {
  bool _isSubmitting = false;
  bool _agreedToPolicy = false;

  Future<void> _submitReport() async {
    if (!_agreedToPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui kebijakan privasi terlebih dahulu.'),
          backgroundColor: AppTheme.warning600,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'title': widget.reportData['title'],
      'description': widget.reportData['description'],
      'category': widget.reportData['category'],
      'incident_location': widget.reportData['incidentLocation'],
      'incident_date': widget.reportData['incidentDate'],
      'is_anonymous': widget.reportData['isAnonymous'] == true ? 1 : 0,
    };

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

    final filePaths =
        widget.reportData['filePaths'] as List<String>?;

    try {
      final created = await ref
          .read(createReportProvider.notifier)
          .create(data, filePaths: filePaths);

      ref.invalidate(reportsListProvider);

      if (mounted) {
        final code = created?.reportCode ?? 'REP-BARU';
        context.go('/report/success', extra: code);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim laporan: $e'),
            backgroundColor: AppTheme.danger600,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.reportData;
    final isAnon = data['isAnonymous'] == true;
    final filePaths = (data['filePaths'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthStepper(
                      currentStep: 3,
                      labels: ['Identitas', 'Bukti', 'Review'],
                    ),
                    const SizedBox(height: 24),

                    // ── Ringkasan Laporan ──────────────────────────────
                    _sectionTitle('Ringkasan Laporan'),
                    _buildInfoTable([
                      _TableRow(
                          label: 'Cara Melapor',
                          value: isAnon
                              ? 'Secara Anonim'
                              : 'Dengan Identitas'),
                      _TableRow(
                          label: 'Identitas Dirahasiakan',
                          valueWidget: isAnon
                              ? const Icon(Icons.check_circle,
                                  color: AppTheme.success600, size: 20)
                              : const Icon(Icons.cancel,
                                  color: AppTheme.neutral400, size: 20)),
                    ]),
                    const SizedBox(height: 16),

                    // ── Detail Kejadian ────────────────────────────────
                    _sectionTitle('Detail Kejadian'),
                    _buildInfoTable([
                      _TableRow(
                          label: 'Jenis Perundungan',
                          value: data['category'] ?? '-'),
                      _TableRow(
                          label: 'Tanggal Kejadian',
                          value: data['incidentDate'] ?? '-'),
                      _TableRow(
                          label: 'Waktu',
                          value: data['incidentTime'] ?? '-'),
                      _TableRow(
                          label: 'Lokasi',
                          value: data['incidentLocation'] ?? '-'),
                      _TableRow(
                          label: 'Pihak yang Terlibat',
                          value: data['reportedId']?.toString().isEmpty ??
                                  true
                              ? '-'
                              : data['reportedId'].toString()),
                      _TableRow(
                          label: 'Kronologi Kejadian',
                          value: data['description']?.toString().isEmpty ??
                                  true
                              ? '-'
                              : data['description'].toString()),
                    ]),
                    const SizedBox(height: 16),

                    // ── Bukti Terlampir ────────────────────────────────
                    if (filePaths.isNotEmpty) ...[
                      _sectionTitle('Bukti Terlampir (${filePaths.length})'),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.neutral300),
                        ),
                        child: Column(
                          children: List.generate(filePaths.length, (i) {
                            final path = filePaths[i].toString();
                            final name = path.split('/').last;
                            final isVideo = name.toLowerCase().contains(
                                    RegExp(r'\.(mp4|mov|avi|mkv)$'));
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          isVideo
                                              ? Icons.play_circle_outline
                                              : Icons.image_outlined,
                                          color: AppTheme.primary600,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.neutral900),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right,
                                          color: AppTheme.neutral400,
                                          size: 20),
                                    ],
                                  ),
                                ),
                                if (i < filePaths.length - 1)
                                  const Divider(height: 1),
                              ],
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Kebijakan Privasi ──────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _agreedToPolicy,
                            onChanged: (v) =>
                                setState(() => _agreedToPolicy = v ?? false),
                            activeColor: AppTheme.primary600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(
                                color: AppTheme.neutral300),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.neutral700),
                              children: const [
                                TextSpan(
                                    text:
                                        'Saya data yang diberikan digunakan dengan '),
                                TextSpan(
                                  text: 'kebijakan Privasi',
                                  style: TextStyle(
                                      color: AppTheme.primary600,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Kirim Laporan ──────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          disabledBackgroundColor:
                              AppTheme.neutral300,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Kirim Laporan',
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
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutral900),
      ),
    );
  }

  Widget _buildInfoTable(List<_TableRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      row.label,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.neutral500),
                    ),
                    const Spacer(),
                    if (row.valueWidget != null)
                      row.valueWidget!
                    else
                      Flexible(
                        child: Text(
                          row.value ?? '-',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.neutral900,
                              fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _TableRow {
  final String label;
  final String? value;
  final Widget? valueWidget;

  _TableRow({required this.label, this.value, this.valueWidget});
}

// ─── Shared AppBar ────────────────────────────────────────────────────────────

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
