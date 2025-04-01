import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/di/providers/auth/certificate_process_provider.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/etc/certification_card.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/router/routes/auth_routes.dart';

/*
  mm인증서 생성 성공 UI
*/
class AuthMydataCertCompletePage extends ConsumerWidget {
  const AuthMydataCertCompletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final certProcessState = ref.watch(certificateProcessProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // 상단 여백 - 화면 크기에 비례하게 조정
                        SizedBox(height: screenHeight * 0.15),
                        
                        //인증서 카드
                        const CertificateCard(
                          userName: '손효자', 
                          expiryDate: '2028. 03. 14.',
                          shieldSvgPath: 'assets/icons/etc/shield.svg',
                        ),
                        
                        // 중간 여백 - 화면 크기에 비례하게 조정
                        SizedBox(height: screenHeight * 0.05),
                        
                        // 텍스트 섹션
                        const Text(
                          '손효자 님의 MM 인증서',
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '발급 완료!',
                          style: AppTextStyles.bodyLarge,
                        ),
                        
                        // 남은 공간을 차지하는 Spacer
                        const Spacer(),
                        
                        // 하단 여백 추가
                        const SizedBox(height: 16),
                        
                        // 버튼
                        Button(
                          text: '다음',
                          width: screenWidth * 0.9,
                          height: 56, // 약간 줄임
                          onPressed: () {
                            context.go(SignupRoutes.getMyDataSplashPath());
                          },
                        ),
                        
                        // 버튼 아래 여백
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}