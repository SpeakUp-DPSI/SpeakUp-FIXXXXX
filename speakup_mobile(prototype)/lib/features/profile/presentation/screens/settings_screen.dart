import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifPush = true;
  bool _notifEmail = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifPush = prefs.getBool('notif_push') ?? true;
      _notifEmail = prefs.getBool('notif_email') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
            subtitle:
                const Text('Menerima notifikasi langsung di perangkat'),
            value: _notifPush,
            onChanged: (val) {
              setState(() => _notifPush = val);
              _saveSetting('notif_push', val);
            },
            activeThumbColor: AppTheme.primary600,
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Menerima pemberitahuan via email'),
            value: _notifEmail,
            onChanged: (val) {
              setState(() => _notifEmail = val);
              _saveSetting('notif_email', val);
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
              'Pengaturan ini menyimpan preferensi notifikasi Anda secara lokal di perangkat.',
              style: TextStyle(fontSize: 12, color: AppTheme.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}
