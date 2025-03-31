// data/datasources/remote/auth_api.dart
import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;
  
  AuthApi(this._dio);

  // 본인확인 api
  Future<Map<String, dynamic>> verifyIdentity(String phoneNumber) async {
    final response = await _dio.post(
      '/api/mm/auth/identity-verify',
      data: {
        'phoneNumber' : phoneNumber,
      }
    );
    return response.data;
  }

  // SSE 연결을 위한 URL 반환
  String getIdentityVerificationSubscribeURl(String phoneNumber) {
    return '/api/mm/auth/subscribe/$phoneNumber';
  }

}