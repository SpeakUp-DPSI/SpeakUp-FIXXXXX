import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_users_provider.dart';
import '../../data/models/admin_user_model.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.neutral700),
          onPressed: () => context.pop(),
        ),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Terjadi kesalahan: $e')),
        data: (users) {
          final filteredUsers = users.where((u) {
            return u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                   u.email.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.neutral300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.neutral300),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary100,
                        child: Text(user.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppTheme.primary600, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.email, style: const TextStyle(fontSize: 12, color: AppTheme.neutral500)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRoleBadge(user.role),
                          const SizedBox(width: 8),
                          const Icon(Icons.more_vert, color: AppTheme.neutral400, size: 20),
                        ],
                      ),
                      onTap: () => _showUserActionMenu(context, user),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary600,
        onPressed: () => _showUserDialog(context, null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bgColor;
    Color textColor;
    String label;

    switch (role.toLowerCase()) {
      case 'admin':
        bgColor = AppTheme.danger600.withOpacity(0.1);
        textColor = AppTheme.danger600;
        label = 'Admin';
        break;
      case 'kepsek':
        bgColor = AppTheme.warning100;
        textColor = AppTheme.warning600;
        label = 'Kepala Sekolah';
        break;
      case 'guru_bk':
        bgColor = AppTheme.primary100;
        textColor = AppTheme.primary600;
        label = 'Guru BK';
        break;
      case 'ortu':
        bgColor = AppTheme.info100;
        textColor = AppTheme.info600;
        label = 'Orang Tua';
        break;
      case 'siswa':
      default:
        bgColor = AppTheme.success100;
        textColor = AppTheme.success600;
        label = 'Siswa';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showUserActionMenu(BuildContext context, AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text('Aksi untuk ${user.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.manage_accounts, color: AppTheme.primary600),
                title: const Text('Ubah Hak Akses (Role)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showChangeRoleDialog(context, user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.warning600),
                title: const Text('Edit Profil Pengguna'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUserDialog(context, user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.danger600),
                title: const Text('Hapus Pengguna', style: TextStyle(color: AppTheme.danger600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmDialog(context, user);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AdminUserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna?'),
        content: Text('Apakah Anda yakin ingin menghapus akun ${user.name}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.neutral500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger600),
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menghapus...')));
              final success = await ref.read(adminUsersProvider.notifier).deleteUser(user.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil dihapus'), backgroundColor: AppTheme.success600));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus'), backgroundColor: AppTheme.danger600));
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      )
    );
  }

  void _showUserDialog(BuildContext context, AdminUserModel? user) {
    final isEdit = user != null;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final passCtrl = TextEditingController();
    String selectedRole = user?.role ?? 'siswa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna Baru', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
                    const SizedBox(height: 12),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 12),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Nomor Telepon (Opsional)')),
                    const SizedBox(height: 12),
                    if (!isEdit) ...[
                      TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Kata Sandi')),
                      const SizedBox(height: 12),
                      const Text('Hak Akses:', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: const [
                          DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
                          DropdownMenuItem(value: 'guru_bk', child: Text('Guru BK')),
                          DropdownMenuItem(value: 'kepsek', child: Text('Kepala Sekolah')),
                          DropdownMenuItem(value: 'ortu', child: Text('Orang Tua/Wali')),
                          DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                        ],
                        onChanged: (v) => setModalState(() => selectedRole = v!),
                      ),
                      const SizedBox(height: 24),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () async {
                          if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                          if (!isEdit && passCtrl.text.isEmpty) return;
                          
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyimpan data...')));
                          
                          bool success;
                          if (isEdit) {
                            success = await ref.read(adminUsersProvider.notifier).updateUser(user.id, nameCtrl.text, emailCtrl.text, phoneCtrl.text);
                          } else {
                            success = await ref.read(adminUsersProvider.notifier).createUser(nameCtrl.text, emailCtrl.text, passCtrl.text, phoneCtrl.text, selectedRole);
                          }

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Berhasil diperbarui' : 'Berhasil ditambahkan'), backgroundColor: AppTheme.success600));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan'), backgroundColor: AppTheme.danger600));
                            }
                          }
                        },
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  void _showChangeRoleDialog(BuildContext context, AdminUserModel user) {
    String selectedRole = user.role;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ubah Hak Akses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Pilih hak akses baru untuk ${user.name}', style: const TextStyle(color: AppTheme.neutral600)),
                  const SizedBox(height: 16),
                  _buildRoleRadio('siswa', 'Siswa', selectedRole, (val) => setModalState(() => selectedRole = val!)),
                  _buildRoleRadio('guru_bk', 'Guru BK', selectedRole, (val) => setModalState(() => selectedRole = val!)),
                  _buildRoleRadio('kepsek', 'Kepala Sekolah', selectedRole, (val) => setModalState(() => selectedRole = val!)),
                  _buildRoleRadio('ortu', 'Orang Tua/Wali', selectedRole, (val) => setModalState(() => selectedRole = val!)),
                  _buildRoleRadio('admin', 'Administrator', selectedRole, (val) => setModalState(() => selectedRole = val!)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        if (selectedRole != user.role) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyimpan perubahan...')));
                          final success = await ref.read(adminUsersProvider.notifier).updateUserRole(user.id, selectedRole);
                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hak akses berhasil diubah'), backgroundColor: AppTheme.success600));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengubah hak akses'), backgroundColor: AppTheme.danger600));
                            }
                          }
                        }
                      },
                      child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoleRadio(String value, String title, String groupValue, ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      activeColor: AppTheme.primary600,
    );
  }
}
