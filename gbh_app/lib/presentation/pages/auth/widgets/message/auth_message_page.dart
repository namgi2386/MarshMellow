import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/router/routes/auth_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/etc/custom_button.dart';

/*
  본인인증 메세지 전송 UI
*/
class AuthMessagePage extends ConsumerWidget {
  final String name;
  final String idNum;
  final String phone;
  final String carrier;

  const AuthMessagePage({
    Key? key,
    required this.name,
    required this.idNum,
    required this.phone,
    required this.carrier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 상단 설명 텍스트
            const SizedBox(height: 130),
            const Text('본인인증을 위해', style: AppTextStyles.mainTitle),
            const Text('문자를 보내주세요', style: AppTextStyles.mainTitle),
            const SizedBox(height: 10),
            Text('내용은 mm이 써두었으니', style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled)),
            Text('[문자 보내기]만 눌러주세요', style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled)),
            const Spacer(),

            // 이미지
            Image.asset(
              'assets/images/userverification.png',
              fit:BoxFit.contain,
            ),

            // 문자 보내기 버튼
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: CustomButton(
                text: '문자 보내기', 
                onPressed: () => _sendAuthMessage(context),
                isEnabled: true,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  void _sendAuthMessage(BuildContext context) async {
    // 문자 내용
    final messageBody = '[MM]본인 확인을 위해 인증을 요청합니다.';

    // SMS 앱 열기
    final uri = Uri(
      scheme: 'sms',
      path: '6004', // 문자 보낼 사람
      queryParameters: {'body': messageBody},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);

        // 인증중 로딩 페이지로 이동
        context.go(SignupRoutes.getAuthLoadingPath());
      } else {
        // SMS 앱 못 열 경우 클립보드에 복사 후 안내하기
        await Clipboard.setData(ClipboardData(text: messageBody));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 앱을 열 수 없어 메시지를 클립보드에 복사했습니다.'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '확인', 
              onPressed: () {
                // 인증중 로딩 페이지로 이동
                context.go(SignupRoutes.getAuthLoadingPath());
              },
            ),
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 앱을 열 수 없습니다: $e'),)
      );
    }
  }
}