import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/auth/mydata_state.dart';
import 'package:marshmellow/data/repositories/auth/auth_mydata_respository.dart';
import 'package:marshmellow/di/providers/core_providers.dart';

/*
  금융인증서 의존성 provider
*/
// API 서비스 provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

// 금융인증서 repository provider
final MydataRespositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MydataRespository(apiClient);
});

/*
  금융인증서 비밀번호 provider
*/
// 이전에 입력한 비밀번호 저장 provider
final previousPasswordProvider = StateProvider<String>((ref) => ''); 

// 인증서 비밀번호 상태 관리 provider
final MydataPasswordProvider = StateNotifierProvider<MydataPasswordNotifier, MydataPasswordstate>((ref) {
  final repository = ref.watch(MydataRespositoryProvider);
  return MydataPasswordNotifier(repository);
});

/*
  금융인증서 비밀번호 notifier
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