import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:marshmellow/core/constants/storage_keys.dart';
import 'package:marshmellow/core/services/certificate_service.dart';
import 'package:uuid/uuid.dart';

/*
  전자서명 생성 및 검증 서비스
*/
class DigitalSignatureService {
  final CertificateService _certificateService;
  final FlutterSecureStorage _secureStorage;

  DigitalSignatureService(this._certificateService, this._secureStorage);

  // 반쪽키 가져오기
  Future<String?> getHalfUserKey() async {
    final savedHalfUserKey = await _secureStorage.read(key: StorageKeys.halfUserKey);
    print('전자서명검증에사용할반쪽키는: $savedHalfUserKey');
    
    return savedHalfUserKey;
  }



  // 전자서명 생성
  Future<Map<String, dynamic>> generateDigitalSignature(String originalText) async {
    try {
      // 1. 반쪽 키 가져오기
      final halfUserKey = await getHalfUserKey();
      print('$halfUserKey');
      
      // 2. 원문 서명
      final signedData = await _certificateService.signData(originalText);
      if (signedData == null) {
        throw Exception('전자서명 생성에 실패했습니다.');
      }
      print('$signedData');

      
      // 3. 인증서 가져오기
      final certificatePemRaw = await _secureStorage.read(key: StorageKeys.certificatePem);
      if (certificatePemRaw == null) {
        throw Exception('인증서를 찾을 수 없습니다.');
      }
      final certificatePem = certificatePemRaw.replaceAll(r'\n', '\n').replaceAll('\\n', '\n').replaceAll('\r\n', '\n').trim();
      if (certificatePem == null) {
        throw Exception('인증서를 찾을 수 없습니다.');
      }
      // print('서버에 이거 보냄 : $certificatePem');

      print('원본 데이터: $certificatePemRaw');
      print('처리된 데이터: $certificatePem');

      
      // 4. 은행 및 카드사 코드 리스트
      final orgList = [
        "BOK", "KDB", "IBK", "KB", "NH", "WOORI", "SC", "CITI", "DGB", "KJB",
        "JJB", "JB", "BNK", "MG", "HANA", "SHINHAN", "KAKAO", "SSAFY",
        "1001", "1002", "1003", "1004", "1005", "1006", "1007", "1008", "1009", "1010"
      ];
      
      // 반환할 데이터 패키지
      return {
        'signedData': signedData,
        'originalText': originalText,
        'halfUserKey': halfUserKey,
        'certificatePem': certificatePem,
        'orgList': orgList
      };
    } catch (e) {
      print('전자서명 생성 실패: $e');
      rethrow;
    }
  }
}