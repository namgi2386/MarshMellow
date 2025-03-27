import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/auth/mydata_state.dart';
import 'package:marshmellow/data/repositories/auth/auth_mydata_respository.dart';
import 'package:marshmellow/di/providers/core_providers.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/banner_ad_widget.dart';

/*
  mm인증서 의존성 provider
*/
// API 서비스 provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

// mm인증서 repository provider
final MydataRespositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MydataRespository(apiClient);
});

/*
  mm인증서 비밀번호 생성 provider
*/
// 이전에 입력한 비밀번호 저장 provider
final previousPasswordProvider = StateProvider<String>((ref) => ''); 

// 인증서 비밀번호 상태 관리 provider
final MydataPasswordProvider = StateNotifierProvider<MydataPasswordNotifier, MydataPasswordstate>((ref) {
  final repository = ref.watch(MydataRespositoryProvider);
  return MydataPasswordNotifier(repository);
});

/*
  mm인증서 비밀번호 notifier
*/
class MydataPasswordNotifier extends StateNotifier<MydataPasswordstate> {
  final MydataRespository _respository;

  MydataPasswordNotifier(this._respository) : super(MydataPasswordstate());

  void addDigit(String digit) {
    if (state.currentDigit < 6) {
      final newPassword = state.password + digit;
      state = state.copyWith(
        password: newPassword,
        currentDigit: state.currentDigit + 1,
      );
    }
  }

  void resetPassword() {
    state = state.copyWith(
      password: '',
      currentDigit: 0,
    );
  }

  void setConfirmMode(bool isConfirming) {
    state = state.copyWith(
      isConfirmingPassword: isConfirming,
      password: '',
      currentDigit: 0,
    );
  }

  // api 연동할 때 열어서 쓰세요
  // Future<bool> savePassword(String previousPassword) async {
  //   // 이전 입력과 일치하는지 확인
  //   if (state.password != previousPassword) {
  //     // 일치하지 않으면 초기화 후 실패 반환
  //     resetPassword();
  //     setConfirmMode(false);
  //     return false;
  //   }
  //   try {
  //     // 비밀번호 해싱하여 백엔드로 전송
  //     final hashedPassword = _hashPassword(state.password);
  //     final email = _getUserEmail(); // 사용자 이메일 가져오는 메서드 필요!!!!!!!

  //     final success = await _respository.createCertificateWithPW(
  //       email: email, 
  //       hashedPW: hashedPassword,
  //     );
  //     return success;
  //   } catch (e) {
  //     return false;
  //   }
  // }


    Future<bool> savePassword(String previousPassword) async {
    // 이전 입력과 일치하는지 확인
    if (state.password != previousPassword) {
      // 일치하지 않으면 초기화 후 실패 반환
      resetPassword();
      setConfirmMode(false);
      return false;
    }
    try {
      final success = true;
      
      state = state.copyWith(
        isConfirmingPassword: false,
      );
      return success;
    } catch (e) {
      return false;
    }
  }

  // 비밀번호 해싱함수!!!!!!!!
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 사용자 이메일 가져오기!!!!!구현해라!
  String _getUserEmail() {
    // 다른 provider나 저장소에서 사용자 이메일 가져오기
    return 'user@example.com';
  }
}

/*
  mm인증서 로그인 provider
*/
class MydataLoginNotifier extends StateNotifier<MydataLoginState> {
  MydataLoginNotifier() : super(MydataLoginState());

  // 비밀번호 초기화
  void resetPassword() {
    state = state.copyWith(
      password: '',
      currentDigit: 0,
    );
  }

  // 숫자 추가
  void addDigit(String digit) {
    if (state.currentDigit < 6) {
      final newPassword = state.password + digit;
      state = state.copyWith(
        password: newPassword,
        currentDigit: newPassword.length,
      );
    }
  }

  // 로그인 처리
  Future<bool> login(String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // TODO: 실제 로그인 인증 로직 구현
      // 서버 API 호출 등의 로그인 처리 구현
      await Future.delayed(const Duration(seconds: 1));

      // 실제 구현시 서버에서 받아온거로 비교
      final isSuccess = password == '123456';

      if (!isSuccess) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '비밀번호 안맞자나요!'
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return isSuccess;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인중 오류 발생: ${e.toString()}'
      );
      return false;
    }
  }
}

final MydataLoginProvider = StateNotifierProvider<MydataLoginNotifier, MydataLoginState>((ref) {
  return MydataLoginNotifier();
});

/*
  mm인증서 전자서명 원문 notifier
*/
class AgreementStateNotifier extends StateNotifier<AgreementState> {
  AgreementStateNotifier() : super(AgreementState());

  void setAtBottom(bool value) {
    state = state.copyWith(isAtBottom: value);
  }

  void toggleFirstAgreement() {
    final newValue = !state.firstAgreement;
    state = state.copyWith(
      firstAgreement: newValue,
      isButtonEnabled: newValue && state.secondAgreement,
    );
  }

  void toggleSecondAgreement() {
    final newValue = !state.secondAgreement;
    state = state.copyWith(
      secondAgreement: newValue,
      isButtonEnabled: newValue && state.firstAgreement,
    );
  }
}

/*
  mm인증서 전자서명 원문 provider
*/
final agreementStateProvider = StateNotifierProvider<AgreementStateNotifier, AgreementState>((ref) {
  return AgreementStateNotifier();
});

