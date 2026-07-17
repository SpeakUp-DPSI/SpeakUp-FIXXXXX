import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSource(this.supabaseClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) throw Exception('Login failed: User is null');

      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      // Map 'role' to 'roles' for UserModel compatibility
      if (profileResponse['role'] != null) {
        profileResponse['roles'] = [profileResponse['role']];
      }

      return {
        'token': response.session?.accessToken ?? '',
        'user': UserModel.fromJson(profileResponse),
      };
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String password, Map<String, dynamic> data) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: data,
      );

      if (response.user == null) throw Exception('Sign up failed: User is null');

      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profileResponse != null && profileResponse['role'] != null) {
        profileResponse['roles'] = [profileResponse['role']];
      }

      return {
        'token': response.session?.accessToken ?? '',
        'user': profileResponse != null ? UserModel.fromJson(profileResponse) : null,
      };
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (_) {
      // Ignore logout errors
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
          
      if (response['role'] != null) {
        response['roles'] = [response['role']];
      }
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final response = await supabaseClient
          .from('profiles')
          .update(data)
          .eq('id', user.id)
          .select()
          .single();

      if (response['role'] != null) {
        response['roles'] = [response['role']];
      }
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
