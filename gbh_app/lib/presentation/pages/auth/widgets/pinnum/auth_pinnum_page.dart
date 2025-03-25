import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/router/routes/auth_routes.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/di/providers/auth/pin_provider.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/pinnum/biometric_option.dart';
import 'package:marshmellow/presentation/widgets/dots_input/dots_input.dart';
import 'package:marshmellow/presentation/widgets/keyboard/index.dart';

/*
  핀넘버 설정 시작 UI
*/
class AuthPinnumPage extends ConsumerWidget {
    const AuthPinnumPage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final pinState = ref.watch(pinStateProvider);

        void showKeyboard() {
          KeyboardModal.showSecureNumericKeyboard(
            context: context, 
            onValueChanged: (value) {
              // 입력값이 바뀔 때마다 프로바이더 호출
              final notifier = ref.read(pinStateProvider.notifier);
              // PIN 초기화
              notifier.resetPin();
              // 각자리 순차적으로 입력
              for (int i=0; i < value.length && i < 4; i++) {
                notifier.addDigit(value[i]);
              }

              // PIN 4자리 되면 자동으로 다음 단계로 이동
              if (value.length == 4) {
                if (!pinState.isConfirmingPin) {
                  // 첫 입력 후 확인 모드로 전환
                  final tempPin = value;
                  Future.delayed(const Duration(microseconds: 300), () {
                    ref.read(previousPinProvider.notifier).state = tempPin;
                    notifier.setConfirmMode(true);
                  });
                } else {
                  // 확인 모드에서 PIN 저장 시도
                  final previousPin = ref.read(previousPinProvider);
                  Future.delayed(const Duration(milliseconds: 1000), () async {
                    final success = await notifier.savePin(previousPin);
                    if (success) {
                      context.go(SignupRoutes.getPinCompletePath());
                    }
                  });
                }
              }
            }, 
            initialValue: pinState.pin,
            maxLength: 4,
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
                            pinState.isConfirmingPin
                              ? '비밀번호를 \n한 번 더 눌러주세요'
                              : 'MM을 안전하게 쓰려면 \n 비밀번호가 필요해요',
                            style: AppTextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50,),
                          PinDotsRow(currentDigit: pinState.currentDigit, onTap: showKeyboard,),
                          const Spacer(),
                          if (pinState.isBiometricsAvailable)
                            BiometricOption(),
                        ],
                    )
                )
            )
        );
    }
}