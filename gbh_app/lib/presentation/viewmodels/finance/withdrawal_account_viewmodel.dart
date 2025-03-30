import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/finance_api.dart';
import 'package:marshmellow/data/models/finance/withdrawal_account_model.dart';
import 'package:marshmellow/di/providers/api_providers.dart';

// 출금계좌 등록 과정의 단계를 정의하는 열거형
enum WithdrawalAccountRegistrationStep {
  initial,        // 초기 상태
  termsAgreement, // 약관 동의 단계
  verification,   // 인증번호 검증 단계
  loading,        // 로딩 중 단계
  complete,       // 완료 단계
}

// 출금계좌 등록 상태 클래스
class WithdrawalAccountState {
  // 현재 등록 단계
  final WithdrawalAccountRegistrationStep step;
  
  // 약관 동의 상태
  final bool isAllTermsAgreed;
  final bool isFirstTermAgreed;
  final bool isSecondTermAgreed;
  final bool isThirdTermAgreed;
  
  // 계좌 및 인증 정보
  final String accountNo;
  final String? authCode;
  final String enteredAuthCode;
  
  // 상태 및 에러 정보
  final bool isLoading;
  final String? error;
  final int wrongAttempts;
  
  // 타이머 관련
  final int remainingSeconds;

  // 생성자
  WithdrawalAccountState({
    this.step = WithdrawalAccountRegistrationStep.initial,
    this.isAllTermsAgreed = false,
    this.isFirstTermAgreed = false,
    this.isSecondTermAgreed = false,
    this.isThirdTermAgreed = false,
    this.accountNo = '',
    this.authCode,
    this.enteredAuthCode = '',
    this.isLoading = false,
    this.error,
    this.wrongAttempts = 0,
    this.remainingSeconds = 60,
  });

  // 복사 생성자 (상태 불변성 유지를 위함)
  WithdrawalAccountState copyWith({
    WithdrawalAccountRegistrationStep? step,
    bool? isAllTermsAgreed,
    bool? isFirstTermAgreed,
    bool? isSecondTermAgreed,
    bool? isThirdTermAgreed,
    String? accountNo,
    String? authCode,
    String? enteredAuthCode,
    bool? isLoading,
    String? error,
    int? wrongAttempts,
    int? remainingSeconds,
  }) {
    return WithdrawalAccountState(
      step: step ?? this.step,
      isAllTermsAgreed: isAllTermsAgreed ?? this.isAllTermsAgreed,
      isFirstTermAgreed: isFirstTermAgreed ?? this.isFirstTermAgreed,
      isSecondTermAgreed: isSecondTermAgreed ?? this.isSecondTermAgreed,
      isThirdTermAgreed: isThirdTermAgreed ?? this.isThirdTermAgreed,
      accountNo: accountNo ?? this.accountNo,
      authCode: authCode ?? this.authCode,
      enteredAuthCode: enteredAuthCode ?? this.enteredAuthCode,
      isLoading: isLoading ?? this.isLoading,
      error: error,  // error는 null을 허용해야 해서 ?? this.error 패턴을 사용하지 않음
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

// 출금계좌 등록 ViewModel
class WithdrawalAccountViewModel extends StateNotifier<WithdrawalAccountState> {
  final Ref _ref;
  Timer? _timer;

  WithdrawalAccountViewModel(this._ref) : super(WithdrawalAccountState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 계좌번호 설정
  void setAccountNo(String accountNo) {
    state = state.copyWith(accountNo: accountNo);
  }

  // 약관 동의 단계로 이동
  void moveToTermsAgreement() {
    state = state.copyWith(step: WithdrawalAccountRegistrationStep.termsAgreement);
  }

  // 첫 번째 약관 동의 상태 토글
  void toggleFirstTermAgreement() {
    final newValue = !state.isFirstTermAgreed;
    state = state.copyWith(
      isFirstTermAgreed: newValue,
      // 모든 약관이 동의되었는지 확인
      isAllTermsAgreed: newValue && state.isSecondTermAgreed && state.isThirdTermAgreed,
    );
  }

  // 두 번째 약관 동의 상태 토글
  void toggleSecondTermAgreement() {
    final newValue = !state.isSecondTermAgreed;
    state = state.copyWith(
      isSecondTermAgreed: newValue,
      isAllTermsAgreed: state.isFirstTermAgreed && newValue && state.isThirdTermAgreed,
    );
  }

  // 세 번째 약관 동의 상태 토글
  void toggleThirdTermAgreement() {
    final newValue = !state.isThirdTermAgreed;
    state = state.copyWith(
      isThirdTermAgreed: newValue,
      isAllTermsAgreed: state.isFirstTermAgreed && state.isSecondTermAgreed && newValue,
    );
  }

  // 모든 약관 동의 토글
  void toggleAllTermsAgreement() {
    final newValue = !state.isAllTermsAgreed;
    state = state.copyWith(
      isAllTermsAgreed: newValue,
      isFirstTermAgreed: newValue,
      isSecondTermAgreed: newValue,
      isThirdTermAgreed: newValue,
    );
  }

  // 인증번호 발송 요청
  Future<void> sendVerificationCode() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final financeApi = _ref.read(financeApiProvider);
      final response = await financeApi.sendAccountAuth(
        userKey: "2c2fd595-4118-4b6c-9fd7-fc811910bb75", // 임시 하드코딩
        accountNo: state.accountNo,
      );
      
      // 인증 단계로 이동하고 타이머 시작
      state = state.copyWith(
        step: WithdrawalAccountRegistrationStep.verification,
        authCode: response.data.authCode,
        isLoading: false,
        remainingSeconds: 60,
      );
      
      // 타이머 시작
      startTimer();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "인증번호 발송에 실패했습니다: ${e.toString()}",
      );
    }
  }

  // 타이머 시작
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 1) {
        timer.cancel();
        // 시간 초과 시 초기 단계로 돌아감
        state = WithdrawalAccountState();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  // 인증번호 입력
  void updateEnteredAuthCode(String code) {
    state = state.copyWith(enteredAuthCode: code.toString());
  }

  // 인증번호 검증
  Future<bool> verifyAuthCode() async {
    // 입력한 인증번호와 서버에서 받은 인증번호 비교 (개발 편의를 위해 직접 비교)
    if (state.enteredAuthCode != state.authCode) {
      final attempts = state.wrongAttempts + 1;
      state = state.copyWith(
        wrongAttempts: attempts,
        error: "인증번호가 일치하지 않습니다. (${attempts}/5)",
        enteredAuthCode: '', // 입력값 초기화
      );
      
      // 5회 이상 오류 시 초기 상태로 돌아감
      if (attempts >= 5) {
        _timer?.cancel();
        state = WithdrawalAccountState();
      }
      
      return false;
    }
    
    // 인증번호가 일치하면 실제 API 호출하여 출금계좌 등록
    try {
      state = state.copyWith(
        isLoading: true, 
        error: null,
        step: WithdrawalAccountRegistrationStep.loading,
      );
      
      final financeApi = _ref.read(financeApiProvider);
      final response = await financeApi.verifyAccountAuth(
        userKey: "2c2fd595-4118-4b6c-9fd7-fc811910bb75", // 임시 하드코딩
        accountNo: state.accountNo,
        authCode: state.enteredAuthCode,
      );
      
      // 등록 완료 상태로 변경
      if (response.data.status == "SUCCESS") {
        _timer?.cancel(); // 타이머 중지
        state = state.copyWith(
          step: WithdrawalAccountRegistrationStep.complete,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "계좌 등록에 실패했습니다.",
        );
        return false;
      }
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "계좌 등록 중 오류가 발생했습니다: ${e.toString()}",
      );
      return false;
    }
  }

  // 출금계좌 목록에서 특정 계좌 존재 여부 확인
  Future<bool> isAccountRegisteredAsWithdrawal(String accountNo) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final financeApi = _ref.read(financeApiProvider);
      final response = await financeApi.getWithdrawalAccounts(1); // userPk 1로 고정
      
      // 목록에서 해당 계좌번호 검색
      final isRegistered = response.data.withdrawalAccountList
          .any((account) => account.accountNo == accountNo);
      
      state = state.copyWith(
        isLoading: false,
        accountNo: accountNo,
      );
      
      return isRegistered;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "출금계좌 목록 조회 중 오류가 발생했습니다: ${e.toString()}",
      );
      return false;
    }
  }

  // 등록 프로세스 리셋
  void reset() {
    _timer?.cancel();
    state = WithdrawalAccountState();
  }
}

// Provider 정의
final withdrawalAccountProvider = StateNotifierProvider<WithdrawalAccountViewModel, WithdrawalAccountState>(
  (ref) => WithdrawalAccountViewModel(ref),
);