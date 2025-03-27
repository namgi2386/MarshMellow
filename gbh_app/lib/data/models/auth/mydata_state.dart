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