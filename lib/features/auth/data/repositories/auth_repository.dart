import 'package:dio/dio.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage storage;

  AuthRepository({
    required this.remote,
    required this.storage,
  });

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final Response res = await remote.login(
      email: email,
      password: password,
    );

    final token = res.data['accessToken'];

    await storage.saveAccessToken(token);

    return token;
  }

  Future<void> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    await remote.register(
      email: email,
      password: password,
      nickname: nickname,
    );
  }

  Future<UserModel> me() async {
    final res = await remote.me();
    return UserModel.fromJson(res.data);
  }

  Future<void> logout() async {
    await remote.logout();
    await storage.clear();
  }

  Future<String?> getToken() async {
    return storage.getAccessToken();
  }
}