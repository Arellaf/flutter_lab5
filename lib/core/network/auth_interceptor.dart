import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart'; 


class AuthInterceptor extends Interceptor {
  final TokenStorage storage;
  final Dio dio; 

  AuthInterceptor(this.storage, this.dio);

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
      if (err.requestOptions.path.contains('/login') || 
          // err.requestOptions.path.contains('/me') ||
          err.requestOptions.path.contains('/refresh')) {
        return handler.next(err); 
      }

      try {
        final refreshDio = Dio(dio.options);
        refreshDio.interceptors.add(dio.interceptors.firstWhere((i) => i is CookieManager));

        final response = await refreshDio.post('/auth/refresh'); 
        final newAccessToken = response.data['accessToken'];

        if (newAccessToken != null) {
          await storage.saveAccessToken(newAccessToken);

          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final clonedRequest = await dio.request(
            requestOptions.path,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
          );

          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        await storage.clear();
        return handler.next(err);
      }
    }
    
    return handler.next(err);
  }
}
