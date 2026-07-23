// lib/core/services/realtime_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/report/presentation/providers/report_provider.dart';
import '../../features/mediation/presentation/providers/mediation_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';

class RealtimeService {
  final Ref ref;
  RealtimeChannel? _channel;
  String? _activeUserId;

  RealtimeService(this.ref);

  void start() {
    final authState = ref.read(authProvider);
    if (authState is! AuthSuccess) return;

    final uid = authState.user.id;
    if (_channel != null && _activeUserId == uid) return;

    stop();
    _activeUserId = uid;

    final supabase = ref.read(supabaseClientProvider);

    _channel = supabase
        .channel('speakup-realtime-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (payload) {
            ref.invalidate(notificationsProvider);
            ref.invalidate(unreadCountProvider);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (payload) {
            ref.invalidate(notificationsProvider);
            ref.invalidate(unreadCountProvider);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reports',
          callback: (payload) {
            ref.invalidate(reportsProvider);
            ref.invalidate(reportsListProvider);
            ref.invalidate(reportDetailProvider);
            ref.invalidate(dashboardStatsProvider);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mediations',
          callback: (payload) {
            ref.invalidate(myMediationsProvider);
            ref.invalidate(dashboardStatsProvider);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mediation_participants',
          callback: (payload) {
            ref.invalidate(myMediationsProvider);
          },
        )
        .subscribe();
  }

  void stop() {
    if (_channel != null) {
      _channel!.unsubscribe();
      _channel = null;
      _activeUserId = null;
    }
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref);
  ref.onDispose(() => service.stop());
  return service;
});
