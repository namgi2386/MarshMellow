import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/certificate_api.dart';
import 'package:marshmellow/di/providers/api_providers.dart';

class CertificateRepository {
  final CertificateApi _certificateApi;

  CertificateRepository(this._certificateApi);

  // 통합인증 여부 조회
  Future<bool> hasCompletedIntegratedAuth() async {
    try {
      final response = await _certificateApi.checkIntegratedStatus();
      return response['data'] ?? false;
    } catch (e) {
      print('통합인증 상태 조회 실패: $e');
      return false;
    }
  }

  // 인증서 존재 여부 및 상태 조회
  Future<Map<String, dynamic>> getCertificateStatus() async {
    try {
      final response = await _certificateApi.checkCertificateExist();
      return response['data'] ?? {'exist' : false, 'status' : null, 'certificatePem' : null};
    } catch (e) {
      print('인증서 상태 조회 실패: $e');
      return {'exist' : false, 'status' : null, 'certificatePem' : null};
    }
  }

  // 인증서 발급
  Future<String?> issueCertificate({required String csrPem, required String userEmail}) async {
    try {
      final response = await _certificateApi.issueCertificate(
        csrPem: csrPem, 
        userEmail: userEmail
      );
      return response['data']?['certificatePem'];
    } catch (e) {
      print('인증서 발급 실패: $e');
      return null;
    }
  }
}

// 프로바이더 정의
final CertificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  final certificateApi = ref.watch(certificateApiProvider);
  return CertificateRepository(certificateApi);
});