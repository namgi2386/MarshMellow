/*
  mm인증서 프로세스 상태
*/
class MydataState {
  final bool isAuthenticated;
  final bool isInAuthFlow;
  final int authStep; // 0:시작전, 1:이메일입력완료, 2:비밀번호설정완료, 3:인증서발급완료
  final String? email;

  MydataState({
    this.isAuthenticated = false,
    this.isInAuthFlow = false,
    this.authStep = 0,
    this.email,
  });

  MydataState copyWith({
    bool? isAuthenticated,
    bool? isInAuthFlow,
    int? authStep,
    String? email,
  }) {
    return MydataState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInAuthFlow: isInAuthFlow ?? this.isInAuthFlow,
      authStep: authStep ?? this.authStep,
      email: email ?? this.email,
    );
  }
}

/*
  mm인증서 비밀번호 생성 상태
*/
class MydataPasswordstate {
  final String password;
  final int currentDigit;
  final bool isConfirmingPassword;

  MydataPasswordstate({
    this.password = '',
    this.currentDigit = 0,
    this.isConfirmingPassword = false,
  });

  MydataPasswordstate copyWith({
    String? password,
    int? currentDigit,
    bool? isConfirmingPassword,
  }) {
    return MydataPasswordstate(
      password: password ?? this.password,
      currentDigit: currentDigit ?? this.currentDigit,
      isConfirmingPassword: isConfirmingPassword ?? this.isConfirmingPassword,
    );
  }
}

/*
  mm인증서 로그인 상태
*/
class MydataLoginState {
  final String password;
  final int currentDigit;
  final bool isLoading;
  final String? errorMessage;

  MydataLoginState({
    this.password = '',
    this.currentDigit = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  MydataLoginState copyWith({
    String? password,
    int? currentDigit,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MydataLoginState(
      password: password ?? this.password,
      currentDigit: currentDigit ?? this.currentDigit,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/*
  mm인증서 전자서명 원문 상태
*/
class AgreementState {
  final bool isAtBottom;
  final bool firstAgreement;
  final bool secondAgreement;
  final bool isButtonEnabled;

  AgreementState({
    this.isAtBottom = false,
    this.firstAgreement = false,
    this.secondAgreement = false,
    this.isButtonEnabled = false,
  });

  AgreementState copyWith({
    bool? isAtBottom,
    bool? firstAgreement,
    bool? secondAgreement,
    bool? isButtonEnabled,
  }) {
    return AgreementState(
      isAtBottom: isAtBottom ?? this.isAtBottom,
      firstAgreement: firstAgreement ?? this.firstAgreement,
      secondAgreement: secondAgreement ?? this.secondAgreement,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
    );
  }
}