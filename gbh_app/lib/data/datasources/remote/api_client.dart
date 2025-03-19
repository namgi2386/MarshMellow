// lib/data/datasources/remote/api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  
  ApiClient(this._dio);
  
  // 기본 GET 요청
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // 기본 POST 요청
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // 에러 핸들링 (기본)
  Exception _handleError(DioException error) {
    // 나중에 에러 처리 로직 추가
    return Exception('API 요청 실패: ${error.message}');
  }
}