import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage storage;

  AuthInterceptor(this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    if (options.path.contains('/login') || options.path.contains('/register')) {
      return handler.next(options);
    }

    final token = await storage.getAccessToken(); 
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {

    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path.contains('/login') || err.requestOptions.path.contains('/me')) {
        return handler.next(err); 
      }
    }
    
    return handler.next(err);
  }
}
