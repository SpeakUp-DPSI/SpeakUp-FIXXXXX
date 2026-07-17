import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'info',
      referenceId: json['reference_id']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}

final notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  try {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
        
    return (response as List).map((json) => NotificationModel.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  try {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;
    
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);
        
    return response.count;
  } catch (_) {
    return 0;
  }
});

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final supabase = ref.read(supabaseClientProvider);
                final userId = supabase.auth.currentUser?.id;
                if (userId != null) {
                  await supabase.from('notifications').update({'is_read': true}).eq('user_id', userId);
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadCountProvider);
                }
              } catch (_) {}
            },
            child: const Text('Baca Semua', style: TextStyle(color: AppTheme.primary600)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => EmptyStateWidget(
          icon: Icons.cloud_off,
          title: 'Gagal memuat notifikasi',
          subtitle: 'Tarik ke bawah untuk mencoba lagi.',
          iconColor: AppTheme.danger600,
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'Belum ada notifikasi',
              subtitle: 'Pembaruan status laporan akan muncul di sini.',
              iconColor: AppTheme.neutral400,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(context, ref, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, NotificationModel notification) {
    final icon = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppTheme.primary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notification.isRead ? AppTheme.neutral300 : AppTheme.primary200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: AppTheme.neutral900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(notification.body, style: const TextStyle(fontSize: 12, color: AppTheme.neutral600)),
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primary600,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () async {
          if (!notification.isRead && notification.id != null) {
            try {
              final supabase = ref.read(supabaseClientProvider);
              await supabase.from('notifications').update({'is_read': true}).eq('id', notification.id!);
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            } catch (_) {}
          }
          if (notification.referenceId != null && context.mounted) {
            switch (notification.type) {
              case 'mediation':
                context.push('/mediation/${notification.referenceId}');
                break;
              case 'follow_up':
                context.push('/followup/${notification.referenceId}');
                break;
              default:
                context.push('/report/${notification.referenceId}');
                break;
            }
          }
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'warning': return Icons.warning_amber;
      case 'success': return Icons.check_circle;
      case 'error': return Icons.error;
      default: return Icons.info_outline;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'warning': return AppTheme.warning600;
      case 'success': return AppTheme.success600;
      case 'error': return AppTheme.danger600;
      default: return AppTheme.info600;
    }
  }
}
