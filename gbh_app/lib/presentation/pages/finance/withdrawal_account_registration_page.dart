import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/presentation/viewmodels/finance/withdrawal_account_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/loading/loading_manager.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';

class WithdrawalAccountRegistrationPage extends ConsumerStatefulWidget {
  final String accountNo;

  const WithdrawalAccountRegistrationPage({
    Key? key,
    required this.accountNo,
  }) : super(key: key);

  @override
  ConsumerState<WithdrawalAccountRegistrationPage> createState() => _WithdrawalAccountRegistrationPageState();
}

class _WithdrawalAccountRegistrationPageState extends ConsumerState<WithdrawalAccountRegistrationPage> {
  final TextEditingController _authCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 계좌번호 설정 및 약관 동의 단계로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(withdrawalAccountProvider.notifier);
      viewModel.setAccountNo(widget.accountNo);
      viewModel.moveToTermsAgreement();
    });
  }

  @override
  void dispose() {
    _authCodeController.dispose();
    LoadingManager.hide(); // 페이지 종료 시 로딩 강제 숨김
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawalAccountProvider);
    final viewModel = ref.read(withdrawalAccountProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.isLoading) {
        LoadingManager.show(context, text: '처리 중...' , opacity: 1.0, backgroundColor: AppColors.background);
      } else {
        LoadingManager.hide();
      }
    });

    // 에러 메시지 표시 (있는 경우)
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
      });
    }

    // 완료 단계에서 자동으로 계좌 상세 페이지로 이동
    if (state.step == WithdrawalAccountRegistrationStep.complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 2초 후 뒤로가기 (계좌 상세 페이지로 이동)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop(); // 뒤로가기
            // 여기서 인증서 로그인 모달을 표시하는 함수를 호출할 수 있음
            // showCertificateLoginModal(context);
          }
        });
      });
    }

    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 버튼 처리 - 상태 초기화
        viewModel.reset();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('출금계좌 등록'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              viewModel.reset();
              context.pop();
            },
          ),
        ),
        body: _buildBody(context, state, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WithdrawalAccountState state, WithdrawalAccountViewModel viewModel) {
    // 현재 단계에 따라 적절한 위젯 반환
    switch (state.step) {
      case WithdrawalAccountRegistrationStep.termsAgreement:
        return _buildTermsAgreementWidget(context, state, viewModel);
      case WithdrawalAccountRegistrationStep.verification:
        return _buildVerificationWidget(context, state, viewModel);
      case WithdrawalAccountRegistrationStep.loading:
        // Line 수정: 로딩 단계에서는 빈 컨테이너 반환 (LoadingManager가 오버레이로 표시됨)
        return Container();
      case WithdrawalAccountRegistrationStep.complete:
        return _buildCompleteWidget(context);
      case WithdrawalAccountRegistrationStep.initial:
      default:
        // Line 수정: 초기 단계에서도 빈 컨테이너 반환
        return Container();
    }
  }

  // 약관 동의 위젯
  Widget _buildTermsAgreementWidget(BuildContext context, WithdrawalAccountState state, WithdrawalAccountViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '출금계좌 등록 약관 동의',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // 전체 동의 체크박스
          CheckboxListTile(
            title: const Text('전체 동의하기', style: TextStyle(fontWeight: FontWeight.bold)),
            value: state.isAllTermsAgreed,
            onChanged: (_) => viewModel.toggleAllTermsAgreement(),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          const Divider(),
          
          // 개별 약관 체크박스
          CheckboxListTile(
            title: const Text('출금이체 약관 동의 (필수)'),
            value: state.isFirstTermAgreed,
            onChanged: (_) => viewModel.toggleFirstTermAgreement(),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('개인정보 제3자 제공 동의 (필수)'),
            value: state.isSecondTermAgreed,
            onChanged: (_) => viewModel.toggleSecondTermAgreement(),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('개인정보 수집 및 이용 동의 (필수)'),
            value: state.isThirdTermAgreed,
            onChanged: (_) => viewModel.toggleThirdTermAgreement(),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          const Spacer(),
          
          // 확인 버튼
          ElevatedButton(
            onPressed: state.isAllTermsAgreed
                ? () => viewModel.sendVerificationCode()
                : null,
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 인증번호 검증 위젯
  Widget _buildVerificationWidget(BuildContext context, WithdrawalAccountState state, WithdrawalAccountViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '1원 송금 계좌 인증',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          const Text(
            '입력하신 계좌로 1원이 송금되었습니다.\n계좌에서 입금내역을 확인하고 인증번호를 입력해주세요.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // 개발 편의를 위한 임시 인증번호 표시 (실제 앱에서는 제거해야 함)
          Text(
            '인증번호: ${state.authCode}',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          
          // 인증번호 입력 필드
          TextField(
            controller: _authCodeController,
            decoration: InputDecoration(
              labelText: '인증번호 4자리',
              hintText: '인증번호를 입력하세요',
              errorText: state.wrongAttempts > 0
                  ? '인증번호가 일치하지 않습니다. (${state.wrongAttempts}/5)'
                  : null,
              suffixText: '남은 시간: ${state.remainingSeconds}초',
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
            onChanged: viewModel.updateEnteredAuthCode,
          ),
          
          const Spacer(),
          
          // 확인 버튼
          ElevatedButton(
            onPressed: state.enteredAuthCode.length == 4
                ? () => viewModel.verifyAuthCode()
                : null,
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 등록 완료 위젯
  Widget _buildCompleteWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            '출금계좌 등록이 완료되었습니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('잠시 후 계좌 상세 페이지로 이동합니다'),
        ],
      ),
    );
  }
}