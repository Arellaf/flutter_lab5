import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<Response> register({
    required String email,
    required String password,
    required String nickname,
  }) {
    return dio.post(
      '/auth/register',
      data: {
        "email": email,
        "password": password,
        "nickname": nickname,
      },
    );
  }

  Future<Response> login({
    required String email,
    required String password,
  }) {
    return dio.post(
      '/auth/login',
      data: {
        "email": email,
        "password": password,
      },
    );
  }

  Future<Response> me() {
    return dio.get('/auth/me');
  }

  Future<Response> refresh() {
    return dio.post('/auth/refresh');
  }

  Future<Response> logout() {
    return dio.post('/auth/logout');
  }
}