import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/mediation_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/mediation_provider.dart';
import '../../../../core/theme/app_theme.dart';

class MediationDetailPage extends ConsumerStatefulWidget {
  final MediationModel mediation;

  const MediationDetailPage({super.key, required this.mediation});

  @override
  ConsumerState<MediationDetailPage> createState() => _MediationDetailPageState();
}

class _MediationDetailPageState extends ConsumerState<MediationDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    bool isGuruBK = false;
    if (authState is AuthSuccess && authState.user.roles.contains('guru_bk')) {
      isGuruBK = true;
    }

    final m = widget.mediation;
    final statusColor = _getStatusColor(m.status);
    final statusLabel = _formatStatus(m.status);
    final isCompleted = m.status == 'completed';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ─── App Bar ───────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: Color(0xFF111827)),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                title: const Text(
                  'Detail Mediasi',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  color: Colors.white,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.fromLTRB(48, 0, 20, 16),
                  child: const Text(
                    'Informasi lengkap mengenai proses mediasi.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            // ─── Content ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: RefreshIndicator(
                onRefresh: () async {},
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Status Card ──────────────────────────────────
                      _buildStatusCard(m, statusColor, statusLabel),
                      const SizedBox(height: 16),

                      // ─── Informasi Mediasi ───────────────────────────
                      _buildInfoSection(m),
                      const SizedBox(height: 16),

                      // ─── Status Partisipan ────────────────────────────
                      _buildParticipantsSection(m),
                      const SizedBox(height: 16),

                      // ─── Timeline ─────────────────────────────────────
                      _buildTimeline(m.status),
                      const SizedBox(height: 16),

                      // ─── Catatan Mediator ─────────────────────────────
                      _buildMediatorNotes(m.result),
                      const SizedBox(height: 16),

                      // ─── Lampiran ─────────────────────────────────────
                      _buildAttachments(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // ─── Bottom Action ─────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomActions(m, isCompleted, isGuruBK),
    );
  }

  // ─── Status Card ──────────────────────────────────────────────────────────

  Widget _buildStatusCard(MediationModel m, Color statusColor, String statusLabel) {
    return Hero(
      tag: 'mediation-status-${m.id}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.handshake, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.reportCode ?? 'Laporan #${m.reportId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Info Section ──────────────────────────────────────────────────────────

  Widget _buildInfoSection(MediationModel m) {
    final items = [
      _InfoItem(Icons.calendar_today_rounded, 'Tanggal',
          '${_monthName(m.scheduleDate.month)} ${m.scheduleDate.day}, ${m.scheduleDate.year}'),
      _InfoItem(Icons.access_time_rounded, 'Jam',
          '${m.scheduleDate.hour.toString().padLeft(2, '0')}:${m.scheduleDate.minute.toString().padLeft(2, '0')} WIB'),
      _InfoItem(Icons.location_on_rounded, 'Lokasi', m.location.isNotEmpty ? m.location : '-'),
      _InfoItem(Icons.person_4_rounded, 'Mediator', m.mediatorName ?? 'Guru BK'),
      _InfoItem(Icons.person_rounded, 'Pelapor', 'Anonim'),
      _InfoItem(Icons.group_rounded, 'Terlapor', m.participants.isNotEmpty ? (m.participants.first.userName ?? '-') : '-'),
      _InfoItem(Icons.rule_rounded, 'Jenis Pelanggaran', 'Perundungan'),
      _InfoItem(Icons.description_rounded, 'Ringkasan Kasus', 'Mediasi terkait laporan ${m.reportCode ?? "#${m.reportId}"}'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Mediasi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, size: 16, color: const Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(MediationModel m) {
    if (m.participants.isEmpty) return const SizedBox();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Kehadiran Partisipan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...m.participants.map((p) {
            Color pColor = AppTheme.warning600;
            String pLabel = 'Menunggu';
            if (p.status == 'confirmed') {
              pColor = AppTheme.success600;
              pLabel = 'Hadir';
            } else if (p.status == 'rejected') {
              pColor = AppTheme.danger600;
              pLabel = 'Berhalangan';
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.userName ?? 'User #${p.userId}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: pColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: pColor),
                          ),
                          child: Text(pLabel, style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (p.status == 'rejected' && p.reason != null && p.reason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Alasan: ${p.reason}', style: TextStyle(fontSize: 12, color: AppTheme.danger600, fontStyle: FontStyle.italic)),
                    ]
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Timeline ──────────────────────────────────────────────────────────────

  Widget _buildTimeline(String currentStatus) {
    final steps = _getTimelineSteps(currentStatus);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Mediasi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _buildTimelineItem(
              label: step['label'],
              isCompleted: step['completed'],
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String label,
    required bool isCompleted,
    required bool isLast,
  }) {
    final color = isCompleted ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF2563EB) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : const SizedBox.shrink(),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: color,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                color: isCompleted ? const Color(0xFF111827) : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getTimelineSteps(String status) {
    const allSteps = [
      'Laporan diterima',
      'Diverifikasi',
      'Mediasi dijadwalkan',
      'Menunggu pelaksanaan',
      'Selesai',
    ];

    int activeIndex;
    switch (status) {
      case 'completed':
        activeIndex = 4;
        break;
      case 'ongoing':
        activeIndex = 3;
        break;
      case 'scheduled':
        activeIndex = 2;
        break;
      case 'cancelled':
        activeIndex = -1;
        break;
      default:
        activeIndex = 0;
    }

    return List.generate(allSteps.length, (i) {
      return {
        'label': allSteps[i],
        'completed': i <= activeIndex,
      };
    });
  }

  // ─── Mediator Notes ────────────────────────────────────────────────────────

  Widget _buildMediatorNotes(String? result) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'Catatan Mediator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result != null && result.isNotEmpty
                  ? result
                  : 'Belum ada catatan mediator untuk mediasi ini.',
              style: TextStyle(
                fontSize: 14,
                color: result != null && result.isNotEmpty
                    ? const Color(0xFF374151)
                    : const Color(0xFF9CA3AF),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Attachments ───────────────────────────────────────────────────────────

  Widget _buildAttachments() {
    final attachments = [
      {'name': 'Bukti1.jpg', 'icon': Icons.image_rounded, 'size': '2.4 MB'},
      {'name': 'Surat.pdf', 'icon': Icons.picture_as_pdf_rounded, 'size': '1.1 MB'},
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.attach_file_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'Lampiran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...attachments.map((file) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Membuka ${file['name']}...'),
                          backgroundColor: const Color(0xFF2563EB),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              file['icon'] as IconData,
                              color: const Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file['name'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  file['size'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ─── Bottom Actions ────────────────────────────────────────────────────────

  Widget _buildBottomActions(MediationModel m, bool isCompleted, bool isGuruBK) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: isCompleted
          ? SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Membuka hasil mediasi...'),
                      backgroundColor: const Color(0xFF059669),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Lihat Hasil Mediasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            )
          : isGuruBK && m.participants.any((p) => p.status == 'confirmed')
              ? SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCompleteMediationDialog(context, m),
                    icon: const Icon(Icons.fact_check_rounded, color: Colors.white),
                    label: const Text(
                      'Selesaikan Masalah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              : Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (isGuruBK) {
                          try {
                            await ref.read(mediationRemoteDataSourceProvider).contactParticipant(m.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Notifikasi telah dikirim ke pihak terkait'),
                                  backgroundColor: AppTheme.success600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal mengirim notifikasi: $e'),
                                  backgroundColor: AppTheme.danger600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Menghubungi ${m.mediatorName ?? "mediator"}...'),
                              backgroundColor: const Color(0xFF2563EB),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: Text(isGuruBK ? 'Hubungi Pihak Terkait' : 'Hubungi Mediator'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Membuka lokasi: ${m.location}'),
                            backgroundColor: const Color(0xFF2563EB),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Lihat Lokasi',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _showCompleteMediationDialog(BuildContext context, MediationModel m) {
    final resultController = TextEditingController();
    bool isLoading = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selesaikan Mediasi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Masukkan hasil mediasi:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: resultController,
                    decoration: const InputDecoration(
                      hintText: 'Hasil kesepakatan...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (resultController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hasil mediasi wajib diisi'),
                                backgroundColor: AppTheme.warning600,
                              ),
                            );
                            return;
                          }
                          
                          setState(() => isLoading = true);
                          
                          try {
                            await ref.read(mediationRemoteDataSourceProvider).updateMediationStatus(
                                  m.id,
                                  {
                                    'status': 'completed',
                                    'result': resultController.text.trim(),
                                  },
                                );
                            ref.invalidate(myMediationsProvider);
                            if (context.mounted) {
                              Navigator.pop(context); // pop dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mediasi berhasil diselesaikan'),
                                  backgroundColor: AppTheme.success600,
                                ),
                              );
                              context.pop(); // pop detail page
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyelesaikan mediasi: $e'),
                                  backgroundColor: AppTheme.danger600,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success600,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Selesai'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'scheduled':
        return 'Dijadwalkan';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return const Color(0xFFD97706);
      case 'ongoing':
        return const Color(0xFF2563EB);
      case 'completed':
        return const Color(0xFF059669);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _monthName(int month) {
    const names = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return names[month];
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);
}
