import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:marshmellow/data/models/auth/pin_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pinStateProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier();
});

final previousPinProvider = StateProvider<String>((ref) => '');

class PinNotifier extends StateNotifier<PinState> {
  PinNotifier() : super(PinState()) {
    _initialize();
  }

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _initialize() async {
    await _checkBiometrics();
    await _loadSavedPin();
  }

  // 생체인식 가능 여부 확인
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
        await _localAuth.getAvailableBiometrics();

      state = state.copyWith(
        isBiometricsAvailable: canCheckBiometrics &&
          (availableBiometrics.contains(BiometricType.fingerprint) ||
            availableBiometrics.contains(BiometricType.face))
      );
    } on PlatformException catch (e) {
      print('생체인식 확인 실패: $e');
      state = state.copyWith(isBiometricsAvailable: false);
    }
  }

  // 저장된 PIN 불러오기
  Future<void> _loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin');
    final useBio = prefs.getBool('use_biometrics') ?? false;

    state = state.copyWith(
      isPinSet: savedPin != null,
      useBiometrics: savedPin != null && useBio,
    );
  }

  // PIN 입력 처리
  void addDigit(String digit) {
    if (state.pin.length < 4) {
      final newPin = state.pin + digit;
      state = state.copyWith(
        pin: newPin,
        currentDigit: state.currentDigit + 1,
        errorMessage: ''
      );
    }
  }

  // PIN 한자리 삭제
  void removeLastDigit() {
    if (state.pin.isNotEmpty) {
      final newPin = state.pin.substring(0, state.pin.length - 1);
      state = state.copyWith(
        pin: newPin,
        currentDigit: state.currentDigit - 1
      );
    }
  }

  // PIN 초기화
  void resetPin() {
    state = state.copyWith(pin:'', currentDigit: 0, errorMessage: '');
  }

  // PIN 확인 모드 설정
  void setConfirmMode(bool isConfirming) {
    state = state.copyWith(
      isConfirmingPin: isConfirming,
      pin: '',
      currentDigit: 0,
      errorMessage: '',
    );
  }

  // PIN 저장
  Future<bool> savePin(String confirmedPin) async {
    if (state.pin != confirmedPin) {
      state = state.copyWith(errorMessage: 'PIN이 일치하지 않습니다');
      resetPin();
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', state.pin);
      state = state.copyWith(
        isPinSet: true,
        errorMessage: '',
        isConfirmingPin: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: '저장 실패: $e');
      return false;
    }
  }

  // 생체인식 사용 설정
  Future<void> toggleBiometrics(bool value) async {
    if (state.isPinSet) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_biometrics', value);
      state = state.copyWith(useBiometrics: value);
    }
  }

  // 생체인식 인증하기
  Future<bool> authenticateWithBiometrics() async {
    if (!state.isBiometricsAvailable || !state.useBiometrics) {
      return false;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: '생체 인식으로 인증해 주세요',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      state = state.copyWith(errorMessage: '생체인식 인증 실패: $e');
      return false;
    }
  }
}