import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(SupabaseService.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.read(authRemoteDataSourceProvider);
  return AuthRepository(remote);
});

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _checkAuth();
    return AuthInitial();
  }

  Future<void> _checkAuth() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session != null) {
      try {
        state = AuthLoading();
        final user = await _repository.getProfile();
        state = AuthSuccess(user);
      } catch (e) {
        state = AuthInitial();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthLoading();

    try {
      final user = await _repository.login(email, password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp(String email, String password, Map<String, dynamic> data) async {
    state = AuthLoading();

    try {
      final user = await _repository.signUp(email, password, data);
      if (user != null) {
        state = AuthSuccess(user);
      } else {
        // Automatically check auth if sign up succeeded but no profile immediately returned
        await _checkAuth();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthLoading();
    try {
      await _repository.logout();
      state = AuthInitial();
    } catch (e) {
      state = AuthInitial();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = await _repository.updateProfile(data);
      state = AuthSuccess(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _repository.getProfile();
      state = AuthSuccess(user);
    } catch (e) {
      // Silently fail on refresh
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
