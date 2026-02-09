import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    _dio.options.baseUrl = ApiConfig.baseUrl; // Dynamically sets URL
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Simple logging interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true, requestHeader: true, requestBody: true,
      responseHeader: true, responseBody: true,
    ));
    
    // Authorization token handling would go here (storage read)
  }

  Dio get client => _dio;
}
