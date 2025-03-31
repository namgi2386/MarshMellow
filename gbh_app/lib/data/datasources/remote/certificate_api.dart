import 'package:dio/dio.dart';

/*
  mm 인증서 api
*/
class CertificateApi {
  final Dio _dio;

  CertificateApi(this._dio);
  
  // 통합인증 여부 조회
  Future<Map<String, dynamic>> checkIntegratedStatus() async {
    final response = await _dio.get('/api/mm/auth/integrated-status');
    return response.data;
  }

  // 인증서 존재 여부 조회
  Future<Map<String, dynamic>> checkCertificateExist() async {
    final response = await _dio.get('/api/mm/auth/cert/exist');
    return response.data;
  }

  // 인증서 발급
  Future<Map<String, dynamic>> issueCertificate({
    required String csrPem,
    required String userEmail,
  }) async {
    final response = await _dio.post(
      '/api/mm/auth/cert/issue',
      data:{
        'csrPem' : csrPem,
        'userEmail' : userEmail,
      },
    );
    return response.data;
  }
}