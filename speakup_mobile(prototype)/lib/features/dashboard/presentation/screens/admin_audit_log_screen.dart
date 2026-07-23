import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class AuditLogModel {
  final String? id;
  final String? userId;
  final String action;
  final String modelType;
  final String? modelId;
  final Map<String, dynamic>? changes;
  final String? ipAddress;
  final DateTime createdAt;
  final String? userName;

  AuditLogModel({
    required this.id,
    this.userId,
    required this.action,
    required this.modelType,
    this.modelId,
    this.changes,
    this.ipAddress,
    required this.createdAt,
    this.userName,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      action: json['action'] ?? '',
      modelType: json['model_type'] ?? '',
      modelId: json['model_id']?.toString(),
      changes: json['changes'] is Map ? Map<String, dynamic>.from(json['changes']) : null,
      ipAddress: json['ip_address']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      userName: json['user']?['name']?.toString(),
    );
  }
}

final auditLogsProvider = FutureProvider.autoDispose<List<AuditLogModel>>((ref) async {
  try {
    final supabase = ref.read(supabaseClientProvider);
    final response = await supabase
        .from('audit_logs')
        .select('*, user:profiles!audit_logs_user_id_fkey(*)')
        .order('created_at', ascending: false);
        
    final list = response as List;
    return list.map((json) => AuditLogModel.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

class AdminAuditLogScreen extends ConsumerWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: auditLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => EmptyStateWidget(
          icon: Icons.cloud_off,
          title: 'Gagal memuat audit log',
          subtitle: 'Anda mungkin tidak memiliki akses.',
          iconColor: AppTheme.danger600,
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long,
              title: 'Belum ada audit log',
              subtitle: 'Semua aktivitas sistem akan tercatat di sini.',
              iconColor: AppTheme.neutral400,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(auditLogsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildLogCard(log);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogCard(AuditLogModel log) {
    final icon = _getActionIcon(log.action);
    final color = _getActionColor(log.action);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAction(log.action),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                if (log.userName != null)
                  Text(
                    'Oleh: ${log.userName}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.neutral600),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${log.createdAt.day}/${log.createdAt.month}/${log.createdAt.year} ${log.createdAt.hour}:${log.createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.neutral500),
                ),
                if (log.ipAddress != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'IP: ${log.ipAddress}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.neutral400),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    if (action.contains('create')) return Icons.add_circle_outline;
    if (action.contains('update') || action.contains('change')) return Icons.edit_outlined;
    if (action.contains('delete')) return Icons.delete_outline;
    if (action.contains('login')) return Icons.login;
    if (action.contains('logout')) return Icons.logout;
    if (action.contains('validate')) return Icons.check_circle_outline;
    return Icons.info_outline;
  }

  Color _getActionColor(String action) {
    if (action.contains('create')) return AppTheme.success600;
    if (action.contains('update') || action.contains('change')) return AppTheme.info600;
    if (action.contains('delete')) return AppTheme.danger600;
    if (action.contains('validate')) return AppTheme.warning600;
    return AppTheme.neutral600;
  }

  String _formatAction(String action) {
    switch (action) {
      case 'create_report': return 'Laporan Dibuat';
      case 'update_report_status': return 'Status Diperbarui';
      case 'validate_report': return 'Validasi Laporan';
      case 'schedule_mediation': return 'Mediasi Dijadwalkan';
      case 'update_mediation_status': return 'Status Mediasi Diperbarui';
      case 'create_follow_up': return 'Tindak Lanjut Dibuat';
      case 'update_profile': return 'Profil Diperbarui';
      case 'change_password': return 'Password Diubah';
      case 'login': return 'Login';
      case 'logout': return 'Logout';
      default: return action.replaceAll('_', ' ').toUpperCase();
    }
  }
}
