import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/models/admin_user_model.dart';

final adminUsersProvider = AsyncNotifierProvider<AdminUsersNotifier, List<AdminUserModel>>(() {
  return AdminUsersNotifier();
});

class AdminUsersNotifier extends AsyncNotifier<List<AdminUserModel>> {
  @override
  Future<List<AdminUserModel>> build() async {
    return _fetchUsers();
  }

  Future<List<AdminUserModel>> _fetchUsers() async {
    final supabase = ref.watch(supabaseClientProvider);
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((u) => AdminUserModel.fromJson(u))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      await supabase.from('profiles').update({'role': newRole}).eq('id', userId);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createUser(String name, String email, String password, String phone, String role) async {
    return false;
  }

  Future<bool> updateUser(String userId, String name, String email, String phone) async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      await supabase.from('profiles').update({
        'name': name,
        'email': email,
        'phone': phone,
      }).eq('id', userId);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    return false;
  }
}
