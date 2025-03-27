import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/etc/certification_card.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/router/routes/auth_routes.dart';

/*
  금융인증서 생성 성공 UI
*/
class AuthMydataCertCompletePage extends ConsumerWidget {
  const AuthMydataCertCompletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // 인증서 카드
              const CertificateCard(
                userName: '손효자', 
                expiryDate: '2028. 03. 14.',
              ),
              const SizedBox(height: 24),
              const Text(
                '손호자 님의 MM 인증서',
                style: AppTextStyles.bodyMedium,
              ),
              const Text(
                '발급 완료!',
                style: AppTextStyles.bodyMedium,
              ),
              const Spacer(),
              Button(
                text: '다음',
                width: screenWidth * 0.9,
                height: 60,
                onPressed: () {
                  context.go(SignupRoutes.getMyDataSplashPath());
                },
              )
            ],
          ),
        )
      ),
    );
  }
}