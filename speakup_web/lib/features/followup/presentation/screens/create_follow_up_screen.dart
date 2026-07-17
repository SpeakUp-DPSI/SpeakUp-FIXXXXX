import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../report/presentation/providers/report_provider.dart';
import '../providers/follow_up_provider.dart';

class CreateFollowUpScreen extends ConsumerStatefulWidget {
  final String reportId;
  final String reportCode;

  const CreateFollowUpScreen({
    super.key,
    required this.reportId,
    required this.reportCode,
  });

  @override
  ConsumerState<CreateFollowUpScreen> createState() =>
      _CreateFollowUpScreenState();
}

class _CreateFollowUpScreenState extends ConsumerState<CreateFollowUpScreen> {
  final _actionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _actionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_actionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan tindakan yang telah dilakukan.'),
          backgroundColor: AppTheme.warning600,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dataSource = ref.read(followUpRemoteDataSourceProvider);
      await dataSource.createFollowUp(widget.reportId, {
        'action_taken': _actionController.text,
      });

      ref.invalidate(reportsListProvider);
      ref.invalidate(reportDetailProvider(widget.reportId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tindak lanjut berhasil dicatat.'),
            backgroundColor: AppTheme.success600,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencatat tindak lanjut: $e'),
            backgroundColor: AppTheme.danger600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.neutral700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tindak Lanjut',
          style: TextStyle(
              color: AppTheme.neutral900,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.success100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.task_alt,
                        color: AppTheme.success600, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reportCode,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primary600),
                        ),
                        const Text(
                          'Tindak lanjut untuk laporan ini',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.neutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action taken
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_note,
                            size: 18, color: AppTheme.primary600),
                        const SizedBox(width: 8),
                        const Text(
                          'Tindakan yang Dilakukan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.neutral900),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: TextField(
                      controller: _actionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Jelaskan tindakan yang telah dilakukan sebagai tindak lanjut...',
                        hintStyle: const TextStyle(color: AppTheme.neutral400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.primary600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Catat Tindak Lanjut',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
