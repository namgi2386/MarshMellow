import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:marshmellow/core/constants/storage_keys.dart';
import 'package:marshmellow/core/services/certificate_service.dart';
import 'package:marshmellow/core/services/digital_signatures_service.dart';
import 'package:marshmellow/di/providers/core_providers.dart';

/*
  전자서명 생성 및 검증 레포지토리
*/
class DigitalSignatureRepository {
  final Dio _dio;
  final DigitalSignatureService _signatureService;
  final FlutterSecureStorage _secureStorage;

  DigitalSignatureRepository(this._dio, this._signatureService, this._secureStorage);

  // 전자서명 검증 API 호출
  Future<Map<String, dynamic>> verifyDigitalSignature(String originalText) async {
    try {
      // 전자서명 생성
      final signatureData = await _signatureService.generateDigitalSignature(originalText);
      final accessToken = await _secureStorage.read(key: StorageKeys.accessToken);
      // API 요청
      final response = await _dio.post(
        '/api/mm/auth/digital-signature',
        data: {
          'signedData': signatureData['signedData'],
          'originalText': signatureData['originalText'],
          'halfUserKey': signatureData['halfUserKey'],
          'certificatePem': signatureData['certificatePem'],
          'orgList': signatureData['orgList'],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken'
          }
        )
      );
      
      // 검증 성공 시 전체 userKey 저장
      if (response.data['code'] == 200 && 
          response.data['data']['verified'] == true && 
          response.data['data']['userKey'] != null) {
        await _secureStorage.write(
          key: StorageKeys.userkey, 
          value: response.data['data']['userKey']
        );
      }

      print('🍀🍀🍀유저키 발급 성공! : ${response.data['data']['userKey']}');
      
      return response.data;
    } catch (e) {
      print('전자서명 검증 API 호출 실패: $e');
      rethrow;
    }
  }
}

/*
  전자서명 생성 및 검증 레포지토리 프로바이더
*/
final digitalSignatureRepositoryProvider = Provider<DigitalSignatureRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final certificateService = CertificateService(secureStorage);
  final signatureService = DigitalSignatureService(certificateService, secureStorage);
  
  return DigitalSignatureRepository(dio, signatureService, secureStorage);
});

/*
  전자서명 상태 관리 프로바이더
*/
final DigitalSignatureStateProvider = StateProvider<AsyncValue<Map<String, dynamic>>>((ref) {
  return const AsyncValue.data({});
});