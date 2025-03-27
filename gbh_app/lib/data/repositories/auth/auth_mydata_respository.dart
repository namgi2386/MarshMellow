import 'package:marshmellow/data/datasources/remote/api_client.dart';

/*
  금융인증서 비밀번호 관련 데이터 액세스 Repository
*/
class MydataRespository {
  final ApiClient _apiClient;

  MydataRespository(this._apiClient);

  // 인증서 생성 - 비밀번호 설정
  Future<bool> createCertificateWithPW({
    required String email,
    required String hashedPW,
  }) async {
    try {
      await _apiClient.post(
        // api 를 호출하여 인증서 생성 요청하세요!!!!!
        '/auth/certificate',
        data: {
          'email': email,
          'password' : hashedPW,
        }
      );
      return true;
    } catch (e) {
    return false;
    }
  }

  // 인증서 검증 - 로그인
  Future<bool> verifyCertificate({
    required String email,
    required String hashedPW,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify',
        data: {
          'email' : email,
          'password' : hashedPW
        } 
      );
      // 응답 확인 - 성공 여부 반환
      return response['success'] == true;
    } catch (e) {
      // 오류 발생시 검증 실패로 처리
      return false;
    }
  }

  // 인증서 상태 확인
  Future<bool> checkCertificateStatus(String email) async {
    try {
      final response = await _apiClient.get('/auth/certificate/status/$email');
      return response['isValid'] == true;
    } catch (e) {
      return false;
    }
  }
}