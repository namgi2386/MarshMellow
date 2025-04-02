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

  // 반쪽 키 생성 (UUID 형식의 문자열을 반으로 나눔)
  Future<String> generateHalfUserKey() async {
    final uuid = const Uuid().v4();
    // UUID를 반으로 나누어 반쪽만 저장
    final halfUserKey = uuid.substring(0, uuid.length ~/ 2);
    
    // 반쪽 키 저장
    await _secureStorage.write(key: 'half_user_key', value: halfUserKey);
    
    return halfUserKey;
  }

  // 전자서명 생성
  Future<Map<String, dynamic>> generateDigitalSignature(String originalText) async {
    try {
      // 1. 반쪽 키 생성
      final halfUserKey = await generateHalfUserKey();
      print('$halfUserKey');
      
      // 2. 원문 서명
      final signedData = await _certificateService.signData(originalText);
      if (signedData == null) {
        throw Exception('전자서명 생성에 실패했습니다.');
      }
      print('$signedData');

      
      // 3. 인증서 가져오기
      final certificatePem = await _secureStorage.read(key: StorageKeys.certificatePem);
      if (certificatePem == null) {
        throw Exception('인증서를 찾을 수 없습니다.');
      }
      print('$certificatePem');

      
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