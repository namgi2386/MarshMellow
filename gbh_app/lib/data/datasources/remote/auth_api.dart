// data/datasources/remote/auth_api.dart
import 'package:dio/dio.dart';
import 'package:marshmellow/core/constants/api_constants.dart';
import 'package:marshmellow/core/config/app_config.dart';

class AuthApi {
  final Dio _dio;
  
  // 엔드포인트 정의
  static const String _BASE_PATH = '/auth';
  static const String LOGIN = '$_BASE_PATH/login';
  static const String REGISTER = '$_BASE_PATH/register';
  static const String VERIFY_EMAIL = '$_BASE_PATH/verify-email';
  static const String RESET_PASSWORD = '$_BASE_PATH/reset-password';
  
  AuthApi(this._dio);
  
  Future<Response> login(String email, String password) async {
    return await _dio.post(
      AppConfig.apiBaseUrl + LOGIN,
      data: {'email': email, 'password': password},
    );
  }
  
  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post(
      AppConfig.apiBaseUrl + REGISTER,
      data: userData,
    );
  }
  
  // 다른 인증 관련 API 메서드들...
}