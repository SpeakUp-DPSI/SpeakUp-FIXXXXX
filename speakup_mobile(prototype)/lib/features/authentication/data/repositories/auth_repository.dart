import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<UserModel> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    final user = result['user'] as UserModel;
    return user;
  }

  Future<UserModel?> signUp(String email, String password, Map<String, dynamic> data) async {
    final result = await remoteDataSource.signUp(email, password, data);
    return result['user'] as UserModel?;
  }

  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  Future<UserModel> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    return await remoteDataSource.updateProfile(data);
  }

  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    await remoteDataSource.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
  }
}
