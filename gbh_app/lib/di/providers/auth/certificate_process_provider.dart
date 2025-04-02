/*
  mm 인증서 생성 상태
*/
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:marshmellow/core/constants/storage_keys.dart';
import 'package:marshmellow/core/services/advanced_certificate_service.dart';
import 'package:marshmellow/core/services/certificate_service.dart';
import 'package:marshmellow/data/repositories/auth/certificate_repository.dart';
import 'package:marshmellow/di/providers/core_providers.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/mydata/auth_mydata_cert_email_page.dart';

class CertificateProcessState {
  final bool isLoading;
  final String email;
  final String? error;
  final bool isCompleted;
  final String? certificatePem;

  CertificateProcessState({
    this.isLoading = false,
    this.email = '',
    this.error,
    this.isCompleted = false,
    this.certificatePem,
  });

  CertificateProcessState copyWith({
    bool? isLoading,
    String? email,
    String? error,
    bool? isCompleted,
    String? certificatePem,
  }) {
    return CertificateProcessState(
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      error: error,
      isCompleted: isCompleted ?? this.isCompleted,
      certificatePem: certificatePem ?? this.certificatePem,
    );
  }
}

/*
  mm 인증서 생성 상태 감지
*/
class CertificateProcessNotifier extends StateNotifier<CertificateProcessState> {
  final CertificateRepository _repository;
  final CertificateService _certificateService;
  final FlutterSecureStorage _secureStorage; // 인증서 비밀번호를 암호화하여 저장합니다

  // 비밀번호는 상태에 저장하지 않고 메모리에만 잠시 저장
  // securestorage에 저장하고 이 메모리는 삭제됩니다
  String _password = '';

  CertificateProcessNotifier(this._repository, this._certificateService, this._secureStorage)
    : super(CertificateProcessState());

  // 이메일 설정
  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  // 비밀번호 설정 - 메모리에 임시 저장
  void setPassword(String password) {
    _password =  password;
  }

  // mm 인증서 비밀번호 저장 - 암호화하여 저장
  Future<void> saveCertificatePassword() async {
    if (_password.isEmpty) return;

    // FlutterSecureStorage는 저장전 데이터를 암호화합니다
    await _secureStorage.write(
      key: StorageKeys.certificatePassword, 
      value: _password
    );

    // 메모리에서 비밀번호 제거
    _password = '';
  }

   // 인증서 발급 요청
  Future<bool> issueCertificate() async {
    print("======== 인증서 발급 프로세스 시작 ========");
    if (state.email.isEmpty) {
      print("오류: 이메일이 비어있음");
      state = state.copyWith(error: '이메일을 입력해주세요.', isLoading: false);
      return false;
    }

    if (_password.isEmpty) {
      print("오류: 비밀번호가 비어있음");
      state = state.copyWith(error: '비밀번호를 설정해주세요.', isLoading: false);
      return false;
    }
    print("상태: 로딩 시작");
    state = state.copyWith(isLoading: true, error: null);

    try {
      print("1. CSR 생성 시작");
      if (!(await _certificateService.hasKeyPair())) {
        print('1. 키페어 없으면 그거 먼저 만들고 있겠습니다');
        final keyPair = await _certificateService.generateRSAKeyPair();
        print('혹시 여기가?');
        await _certificateService.storeKeyPair(keyPair);
      }

      // 1. CSR 생성
      final csrPem = await _certificateService.generateCSR(
        commonName: state.email,
        organization: 'GBH',
        country: 'KR'
      );
      print("1. CSR 생성 결과: ${csrPem.substring(0, 30)}...");

      // 2. mm인증서 발급 API 호출
      print("2. 인증서 발급 API 호출 시작: ${state.email}");
      final certificatePem = await _repository.issueCertificate(
        csrPem: csrPem,
        userEmail: state.email,
      );
      print("2. 인증서 발급 API 응답: ${certificatePem != null}");

      if (certificatePem != null) {
        // 인증서 발급 성공시 비밀번호 저장
        await saveCertificatePassword();

        // 인증서 PEM 저장
        await _secureStorage.write(
          key: StorageKeys.certificatePem, 
          value: certificatePem
        );

        state = state.copyWith(
          isLoading: false,
          isCompleted: true,
          certificatePem: certificatePem,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '인증서 발급에 실패했습니다.'
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '인증서 발급 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  // 저장된 인증서 비밀번호 가져오기
  Future<String?> getSaveCertificatePassword() async {
    return await _secureStorage.read(key: StorageKeys.certificatePassword);
  }
}

/*
  mm 인증서 생성 프로세스 프로바이더
*/
final certificateProcessProvider = StateNotifierProvider<CertificateProcessNotifier, CertificateProcessState>((ref) {
  final repository = ref.watch(CertificateRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final certificateService = CertificateService(secureStorage);

  // 이메일 값 가져와서 초기 상태 설정
  final email = ref.watch(emailProvider);
  
  final notifier = CertificateProcessNotifier(repository, certificateService, secureStorage);
  notifier.setEmail(email);

  return notifier;
});