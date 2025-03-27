import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/di/providers/auth/mydata_pw_provider.dart';
import 'package:marshmellow/presentation/widgets/dots_input/dots_input.dart';
import 'package:marshmellow/presentation/widgets/keyboard/index.dart';
import 'package:marshmellow/router/routes/auth_routes.dart';

/*
  금융인증서 비밀번호 설정 시작 UI
*/
class AuthMydataCertPwPage extends ConsumerWidget {
  const AuthMydataCertPwPage({Key? key}) : super(key: key);

  @override
 Widget build(BuildContext context, WidgetRef ref) {
  final passwordState = ref.watch(MydataPasswordProvider);

  void showKeyboard() {
    KeyboardModal.showSecureNumericKeyboard(
      context: context, 
      onValueChanged: (value) {
        // 입력값이 바뀔 때마다 프로바이더 호출
        final notifier = ref.read(MydataPasswordProvider.notifier);
        // 비밀번호 초기화
        notifier.resetPassword();
        // 각자리 순차적으로 입력
        for (int i=0; i < value.length && i < 6; i++) {
          notifier.addDigit(value[i]);
        }

        // 비밀번호 6자리 되면 자동으로 다음 단계로 이동
        if (value.length == 6) {
          if (!passwordState.isConfirmingPassword) {
            // 첫 입력 후 확인 모드로 전환
            final tempPassword = value;
            Future.delayed(const Duration(microseconds: 300), () {
              ref.read(previousPasswordProvider.notifier).state = tempPassword;
              notifier.setConfirmMode(true);
            });
          } else {
            // 확인 모드에서 비밀번호 저장 시도
            final previousPassword = ref.read(previousPasswordProvider);
            Future.delayed(const Duration(milliseconds: 1000), () async {
              final success = await notifier.savePassword(previousPassword);
              if (success) {
                context.go(SignupRoutes.getMyDataCompletePath());
              }
            });
          }
        }
      }, 
      initialValue: passwordState.password,
      maxLength: 6,
    );
  }
  return Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Text(
              passwordState.isConfirmingPassword
                ? '인증서 비밀번호를 \n한 번 더 입력해 주세요'
                : '인증서 비밀번호 설정\n비밀번호 6자리를 입력해 주세요',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            PinDotsRow(
              currentDigit: passwordState.currentDigit,
              totalDigits: 6,
              onTap: showKeyboard,
            ),
            const Spacer(),
          ],
        ),
      )
    ),
  );
 }
}