import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifPush = true;
  bool _notifEmail = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthSuccess) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final supabase = ref.read(supabaseClientProvider);
      final data = await supabase
          .from('profiles')
          .select('notif_push_enabled, notif_email_enabled')
          .eq('id', authState.user.id)
          .single();

      setState(() {
        _notifPush = data['notif_push_enabled'] ?? true;
        _notifEmail = data['notif_email_enabled'] ?? false;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String column, bool value) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthSuccess) return;

    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase
          .from('profiles')
          .update({column: value})
          .eq('id', authState.user.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan pengaturan. Coba lagi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Notifikasi',
              style: TextStyle(
                  color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi',
            style: TextStyle(
                color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Menerima notifikasi langsung di perangkat'),
            value: _notifPush,
            onChanged: _isSaving
                ? null
                : (val) {
                    setState(() => _notifPush = val);
                    _saveSetting('notif_push_enabled', val);
                  },
            activeThumbColor: AppTheme.primary600,
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Menerima pemberitahuan via email'),
            value: _notifEmail,
            onChanged: _isSaving
                ? null
                : (val) {
                    setState(() => _notifEmail = val);
                    _saveSetting('notif_email_enabled', val);
                  },
            activeThumbColor: AppTheme.primary600,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Pengaturan ini tersimpan ke akun Anda dan berlaku di semua perangkat.',
              style: TextStyle(fontSize: 12, color: AppTheme.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}
