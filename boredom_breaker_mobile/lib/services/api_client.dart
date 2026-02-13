import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiClient {
  final Dio _dio = Dio();

  static String? token;

  // Method to update the token globally for all Dio requests
  static void setToken(String? newToken) {
    token = newToken;
  }

  ApiClient() {
    _dio.options.baseUrl = ApiConfig.baseUrl; // Dynamically sets URL
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Simple logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ),
    );

    // Auth Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] =
                'Bearer $token'; // Adjust 'Bearer' as needed
          }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get client => _dio;
}
